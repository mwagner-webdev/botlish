# audit/dotenv-interoperability: the Ruby dotenv adapter (bkeepers/dotenv).
#
#   ruby -I GEM/lib adapter.rb --manifest FILE --config NAME [--trusted FILE]
#
# GEM is the pinned dotenv gem tools/setup.py installed with Bundler from
# Gemfile.lock (frozen, its CHECKSUMS verified); the adapter runs it without
# Bundler, so no Bundler variable enters the environment the parser reads.
#
# The public API used is Dotenv.parse(PATH): it returns a Hash and does not
# write ENV (Dotenv.load does). Two properties of the library shape the
# adapter:
#
# * Values that are not single-quoted go through Dotenv::Parser.substitutions,
#   which include Dotenv::Substitutions::Command: an unescaped $(...) is run
#   with Kernel#` (a shell) and replaced by its output. The census never lets
#   a fixture's text run. The library's own code finds and escapes the
#   substitution as it always does; only its last step, the backtick call on
#   the Command module, is answered by the adapter: it records the command
#   text and returns a placeholder (U+E000 "CMD" N U+E001) instead of running
#   it. In "trusted" mode a command is run only when its exact text is listed
#   for the fixture in the trusted-commands file (audited fixtures only).
#   Every other process-spawning method of Kernel, IO, Process and Open3 is
#   disabled for the whole adapter process as a second line of defense.
# * With overwrite: false (Dotenv.parse's default) a key that already exists
#   in ENV takes ENV's value, and $NAME substitution falls back to ENV: the
#   result depends on the process environment, which the harness controls.
#
# Configurations: default (Dotenv.parse, commands recorded, never run) and
# trusted (as default, with the listed commands of audited fixtures run).
require "json"
require "dotenv"
require "dotenv/version"

def arg(name, default = nil)
  i = ARGV.index(name)
  i ? ARGV[i + 1] : default
end

CONFIG = arg("--config", "default")
TRUSTED = arg("--trusted") ? JSON.parse(File.read(arg("--trusted"))) : {}

module CensusGuard
  BLOCKED = "audit/dotenv-interoperability: process creation is disabled in the Ruby adapter"
end

# The defense in depth: nothing in this process may start another process,
# except the one audited path below.
REAL_BACKTICK = Kernel.instance_method(:`)
[Kernel, Kernel.singleton_class].each do |m|
  %i[` system exec spawn fork].each do |name|
    m.send(:define_method, name) { |*| raise SecurityError, CensusGuard::BLOCKED }
  end
end
IO.singleton_class.send(:define_method, :popen) { |*| raise SecurityError, CensusGuard::BLOCKED }
Process.singleton_class.send(:define_method, :spawn) { |*| raise SecurityError, CensusGuard::BLOCKED }

$census_events = []
$census_trusted = []

Dotenv::Substitutions::Command.define_singleton_method(:`) do |command|
  index = $census_events.length
  if CONFIG == "trusted" && $census_trusted.include?(command)
    output = REAL_BACKTICK.bind_call(self, command)
    $census_events << {"kind" => "command-substitution", "command" => command, "executed" => true}
    output
  else
    $census_events << {"kind" => "command-substitution", "command" => command, "executed" => false}
    "\u{E000}CMD#{index}\u{E001}"
  end
end

def text(s)
  return nil if s.nil?
  s = s.dup.force_encoding(Encoding::UTF_8)
  s.valid_encoding? ? s : {"bytes_hex" => s.unpack1("H*")}
end

def emit(obj)
  $stdout.write(JSON.generate(obj, ascii_only: true) + "\n")
  $stdout.flush
end

emit({"type" => "meta", "target" => arg("--target", "ruby"), "config" => CONFIG,
      "runtime" => "Ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}", "library" => "dotenv",
      "library_version" => Dotenv::VERSION,
      "options" => {"api" => "Dotenv.parse(path)", "overwrite" => "false (default)",
                    "substitutions" => Dotenv::Parser.substitutions.map(&:to_s).join(","),
                    "command_substitution" => CONFIG == "trusted" ? "run when listed as trusted, else recorded" : "recorded, never run"}})

JSON.parse(File.read(arg("--manifest"), encoding: "utf-8"))["fixtures"].each do |fx|
  $census_events = []
  $census_trusted = TRUSTED.fetch(fx["id"], [])
  before = ENV.to_h
  out = {"type" => "result", "id" => fx["id"], "status" => "ok", "assignments" => [],
         "error" => nil, "warnings" => [], "views" => {}, "events" => []}
  begin
    Dotenv.parse(fx["path"]).each { |k, v| out["assignments"] << [text(k), text(v)] }
  rescue SecurityError
    raise
  rescue Exception => e # the parser's failure (FormatError < SyntaxError included), as data
    out["status"] = "error"
    out["error"] = {"class" => e.class.name, "message" => text(e.message)}
  end
  out["events"] = $census_events
  out["warnings"] << "process environment changed by Dotenv.parse" if ENV.to_h != before
  emit(out)
end
