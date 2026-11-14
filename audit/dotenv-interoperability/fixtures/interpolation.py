# Interpolation: references to earlier, later, undefined and environment
# variables, defaults, nesting, cycles, escaping and quoting.
# The environment modes matter here: CENSUS_REF and friends exist only in the
# conflict mode (common.CONFLICT).

I = "interpolation"

F("interp-dollar-name", I, "$NAME referencing an earlier assignment", "BASE=one\nKEY=$BASE\n", intended=None)
F("interp-braced", I, "${NAME} referencing an earlier assignment", "BASE=one\nKEY=${BASE}\n", intended=None)
F("interp-braced-suffix", I, "${NAME} followed by text", "BASE=one\nKEY=${BASE}x\n", intended=None)
F("interp-dollar-suffix", I, "$NAME followed by letters (longest name)", "BASE=one\nKEY=$BASEx\n", intended=None)
F("interp-dollar-punct", I, "$NAME followed by punctuation", "BASE=one\nKEY=$BASE/x\n", intended=None)
F("interp-double-quoted", I, "${NAME} inside double quotes", 'BASE=one\nKEY="${BASE}-x"\n', intended=None)
F("interp-single-quoted", I, "${NAME} inside single quotes", "BASE=one\nKEY='${BASE}-x'\n", intended=None)
F("interp-backtick-quoted", I, "${NAME} inside backticks", "BASE=one\nKEY=`${BASE}-x`\n", intended=None)
F("interp-later", I, "A reference to a later assignment", "KEY=${LATER}\nLATER=two\n", intended=None)
F("interp-undefined", I, "A reference to an undefined variable", "KEY=${UNDEFINED_CENSUS}\n", intended=None)
F("interp-undefined-dollar", I, "$NAME of an undefined variable inside text", "KEY=a$UNDEFINED_CENSUS-b\n", intended=None)
F("interp-empty-var", I, "A reference to an empty variable", "EMPTY=\nKEY=x${EMPTY}y\n", intended=None)
F("interp-default", I, "${NAME:-default} with NAME undefined", "KEY=${UNDEFINED_CENSUS:-fallback}\n", intended=None)
F("interp-default-defined", I, "${NAME:-default} with NAME defined", "BASE=one\nKEY=${BASE:-fallback}\n", intended=None)
F("interp-default-empty", I, "${NAME:-default} with NAME empty", "EMPTY=\nKEY=${EMPTY:-fallback}\n", intended=None)
F("interp-dash-default-empty", I, "${NAME-default} with NAME empty", "EMPTY=\nKEY=${EMPTY-fallback}\n", intended=None)
F("interp-dash-default-undefined", I, "${NAME-default} with NAME undefined", "KEY=${UNDEFINED_CENSUS-fallback}\n", intended=None)
F("interp-default-spaces", I, "A default containing spaces", "KEY=${UNDEFINED_CENSUS:-a b}\n", intended=None)
F("interp-default-nested", I, "A default that is itself a reference", "BASE=one\nKEY=${UNDEFINED_CENSUS:-${BASE}}\n", intended=None)
F("interp-alt", I, "${NAME:+alt} with NAME defined", "BASE=one\nKEY=${BASE:+alt}\n", intended=None)
F("interp-error-form", I, "${NAME:?message} with NAME undefined", "KEY=${UNDEFINED_CENSUS:?missing}\n", intended=None)
F("interp-assign-form", I, "${NAME:=value} with NAME undefined", "KEY=${UNDEFINED_CENSUS:=assigned}\n", intended=None)
F("interp-length-form", I, "${#NAME}", "BASE=one\nKEY=${#BASE}\n", intended=None)
F("interp-nested-name", I, "A nested reference in a name: ${A${B}}", "B=X\nAX=found\nKEY=${A${B}}\n", intended=None)
F("interp-self", I, "A self-reference: KEY=$KEY", "KEY=$KEY\n", intended=None)
F("interp-self-append", I, "Appending to an earlier value of the same key", "KEY=one\nKEY=${KEY}-two\n", intended=None)
F("interp-cycle", I, "A two-variable cycle", "A=$B\nB=$A\n", intended=None)
F("interp-escaped-dollar", I, "An escaped reference: \\$NAME", "BASE=one\nKEY=\\$BASE\n", intended=None)
F("interp-escaped-braced-double", I, "An escaped reference in double quotes", 'BASE=one\nKEY="\\${BASE}"\n', intended=None)
F("interp-double-dollar", I, "$$ (the shell's process id)", "KEY=a$$b\n", intended=None)
F("interp-dollar-alone", I, "A lone $ at the end of a value", "KEY=price$\n", intended=None)
F("interp-dollar-space", I, "A $ followed by a space", "KEY=a $ b\n", intended=None)
F("interp-dollar-digit", I, "$1 (a positional parameter)", "KEY=a$1b\n", intended=None)
F("interp-empty-braces", I, "${} (no name)", "KEY=a${}b\n", intended=None)
F("interp-unclosed-brace", I, "${NAME without a closing brace", "BASE=one\nKEY=${BASE\n", intended=None)
F("interp-lowercase", I, "A reference to a lowercase name", "base=low\nKEY=${base}\n", intended=None)
F("interp-dotted", I, "A reference to a dotted name", "my.base=dot\nKEY=${my.base}\n", intended=None)
F("interp-percent-windows", I, "Windows-style %NAME%", "BASE=one\nKEY=%BASE%\n", intended=None)
F("interp-literal-template", I, "A literal ${NAME} the author wants kept", 'KEY="${NOT_A_VAR}"\n',
  intended={"KEY": "${NOT_A_VAR}"})
F("interp-env-ref", I, "A reference to an environment variable", "KEY=${CENSUS_REF}\n", intended=None)
F("interp-env-ref-default", I, "A default for an environment variable", "KEY=${CENSUS_REF:-fallback}\n", intended=None)
F("interp-env-empty-default", I, "A default for an empty environment variable",
  "KEY=${CENSUS_EMPTY_ENV:-fallback}\n", intended=None)
F("interp-env-vs-file", I, "A reference to a key both the environment and the file define",
  "CENSUS_PRESET=from-file\nKEY=${CENSUS_PRESET}\n", intended=None)
F("interp-env-spaces", I, "A reference to an environment value with spaces", "KEY=$CENSUS_SPACES\n", intended=None)
