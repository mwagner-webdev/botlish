// audit/dotenv-interoperability: the dotenv.net adapter (bolorundurowb/dotenv.net).
//
// The public API used is DotEnv.Read(DotEnvOptions): it returns the parsed
// pairs as a dictionary and does not write the process environment (Load
// does). Configurations, each an explicit DotEnvOptions:
//
//   default   new DotEnvOptions(envFilePaths: [FILE]) -- the library's
//             defaults: ignoreExceptions, no trimming, overwriteExistingVars,
//             no export syntax, inline comments, no variable expansion
//   strict    default + WithExceptions()
//   extended  strict + WithSupportExportSyntax() + WithVariableExpansion()
//
// Built once against dotenv.net 4.x and, with DOTENVNET3 defined, against the
// 3.x line (cross-version: 3.x has no inline-comment or expansion options).
using System;
using System.Collections.Generic;
using dotenv.net;

namespace DotenvCensus
{
    public static class Program
    {
        static DotEnvOptions Options(string config, string path)
        {
            var o = new DotEnvOptions(envFilePaths: new[] { path });
            switch (config)
            {
                case "default": return o;
                case "strict": return o.WithExceptions();
#if !DOTENVNET3
                case "extended": return o.WithExceptions().WithSupportExportSyntax().WithVariableExpansion();
#endif
                default: throw new ArgumentException("unknown config " + config);
            }
        }

        public static int Main(string[] args)
        {
            string config = Census.Arg(args, "--config", "default");
            string target = Census.Arg(args, "--target", "dotenvnet");
            var probe = Options(config, ".env");
            var options = new Dictionary<string, string>
            {
                {"api", "DotEnv.Read(DotEnvOptions)"},
                {"IgnoreExceptions", probe.IgnoreExceptions.ToString()},
                {"TrimValues", probe.TrimValues.ToString()},
                {"OverwriteExistingVars", probe.OverwriteExistingVars.ToString()},
                {"Encoding", probe.Encoding.WebName},
#if !DOTENVNET3
                {"SupportExportSyntax", probe.SupportExportSyntax.ToString()},
                {"SupportInlineComments", probe.SupportInlineComments.ToString()},
                {"SupportVariableExpansion", probe.SupportVariableExpansion.ToString()},
#endif
            };
            var version = typeof(DotEnv).Assembly.GetName().Version.ToString();
            Census.Meta(target, config, "dotenv.net", version, options);
            foreach (var f in Census.Fixtures(Census.Arg(args, "--manifest", null)))
            {
                var o = new Outcome();
                var before = Census.SnapshotEnvironment();
                try
                {
                    foreach (var kv in DotEnv.Read(Options(config, f.Value)))
                        o.Assignments.Add(kv);
                }
                catch (Exception e)
                {
                    Census.Fail(o, e);
                }
                var mutated = Census.Delta(before, Census.SnapshotEnvironment());
                if (mutated.Count > 0) o.Warnings.Add("process environment changed by Read: " + mutated.Count + " variables");
                Census.Result(f.Key, o);
            }
            return 0;
        }
    }
}
