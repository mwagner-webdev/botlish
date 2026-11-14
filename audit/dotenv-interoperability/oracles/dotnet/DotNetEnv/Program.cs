// audit/dotenv-interoperability: the DotNetEnv adapter (tonerdo/dotnet-env),
// the most downloaded .NET dotenv library on NuGet (a supplement to
// dotenv.net: README.md, "Reference implementations").
//
// DotNetEnv's documented API loads into the process: Env.Load(PATH) parses
// and calls Environment.SetEnvironmentVariable for every pair (clobbering
// existing values by default) and returns the parsed pairs. The harness runs
// this adapter in a fresh process per fixture (isolation "process"), so a load
// never reaches another fixture. Configurations:
//
//   default  Env.Load(FILE) with LoadOptions.DEFAULT (SetEnvVars, clobber)
//            -- assignments: Environment.GetEnvironmentVariable(KEY) after the
//            load for every key the parse returned (what a program reads);
//            views.parsed: the returned pairs, duplicates included
//   noenv    Env.Load(FILE, Env.NoEnvVars()) -- the pairs only; the library
//            keeps them in its static Env.FakeEnvVars for interpolation
using System;
using System.Collections.Generic;
using DotNetEnv;

namespace DotenvCensus
{
    public static class Program
    {
        public static int Main(string[] args)
        {
            string config = Census.Arg(args, "--config", "default");
            string target = Census.Arg(args, "--target", "dotnetenv");
            var options = new Dictionary<string, string>
            {
                {"api", config == "default" ? "Env.Load(path)" : "Env.Load(path, Env.NoEnvVars())"},
                {"SetEnvVars", (config == "default").ToString()},
                {"ClobberExistingVars", "True"},
                {"OnlyExactPath", "True"},
            };
            var version = typeof(Env).Assembly.GetName().Version.ToString();
            Census.Meta(target, config, "DotNetEnv", version, options);
            foreach (var f in Census.Fixtures(Census.Arg(args, "--manifest", null)))
            {
                var o = new Outcome();
                var before = Census.SnapshotEnvironment();
                Env.FakeEnvVars.Clear();
                var parsed = new List<KeyValuePair<string, string>>();
                try
                {
                    var opts = config == "default" ? LoadOptions.DEFAULT : Env.NoEnvVars();
                    foreach (var kv in Env.Load(f.Value, opts)) parsed.Add(kv);
                }
                catch (Exception e)
                {
                    Census.Fail(o, e);
                }
                o.Views["parsed"] = parsed;
                var after = Census.SnapshotEnvironment();
                o.Views["environment_delta"] = Census.Delta(before, after);
                if (o.Status == "ok")
                {
                    var seen = new Dictionary<string, string>(StringComparer.Ordinal);
                    var order = new List<string>();
                    foreach (var kv in parsed)
                    {
                        if (!seen.ContainsKey(kv.Key)) order.Add(kv.Key);
                        seen[kv.Key] = kv.Value;
                    }
                    foreach (var k in order)
                    {
                        string v = config == "default" ? Environment.GetEnvironmentVariable(k) : seen[k];
                        o.Assignments.Add(new KeyValuePair<string, string>(k, v));
                    }
                }
                Census.Result(f.Key, o);
            }
            return 0;
        }
    }
}
