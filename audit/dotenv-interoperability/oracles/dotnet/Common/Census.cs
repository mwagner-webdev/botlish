// audit/dotenv-interoperability: the .NET side of the adapter protocol
// (tools/README in ../../../README.md, "Adapter protocol").
//
//   ADAPTER --manifest FILE --config NAME
//
// FILE is a JSON object {"fixtures": [{"id": ID, "path": PATH}, ...]}; the
// adapter writes one JSON line per fixture to standard output, after one
// "meta" line. Every string is written with every UTF-16 code unit outside
// printable ASCII escaped (\uXXXX), so a lone surrogate or a control character
// crosses losslessly. The manifest is read with a minimal reader of exactly
// the shape the harness writes (no JSON library: the adapters depend on
// nothing but the library under test).
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace DotenvCensus
{
    public sealed class Outcome
    {
        public string Status = "ok";
        public List<KeyValuePair<string, string>> Assignments = new List<KeyValuePair<string, string>>();
        public string ErrorClass;
        public string ErrorMessage;
        public List<string> Warnings = new List<string>();
        public Dictionary<string, List<KeyValuePair<string, string>>> Views =
            new Dictionary<string, List<KeyValuePair<string, string>>>();
    }

    public static class Census
    {
        public static string Arg(string[] args, string name, string fallback)
        {
            for (int i = 0; i + 1 < args.Length; i++)
                if (args[i] == name) return args[i + 1];
            return fallback;
        }

        public static void Quote(StringBuilder sb, string s)
        {
            if (s == null) { sb.Append("null"); return; }
            sb.Append('"');
            foreach (char c in s)
            {
                if (c == '"') sb.Append("\\\"");
                else if (c == '\\') sb.Append("\\\\");
                else if (c >= 0x20 && c < 0x7f) sb.Append(c);
                else sb.Append("\\u").Append(((int)c).ToString("x4"));
            }
            sb.Append('"');
        }

        static void Pairs(StringBuilder sb, List<KeyValuePair<string, string>> pairs)
        {
            sb.Append('[');
            for (int i = 0; i < pairs.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.Append('[');
                Quote(sb, pairs[i].Key);
                sb.Append(',');
                Quote(sb, pairs[i].Value);
                sb.Append(']');
            }
            sb.Append(']');
        }

        public static void Meta(string target, string config, string library, string libraryVersion,
                                IDictionary<string, string> options)
        {
            var sb = new StringBuilder();
            sb.Append("{\"type\":\"meta\",\"target\":"); Quote(sb, target);
            sb.Append(",\"config\":"); Quote(sb, config);
            sb.Append(",\"runtime\":"); Quote(sb, ".NET " + Environment.Version.ToString());
            sb.Append(",\"library\":"); Quote(sb, library);
            sb.Append(",\"library_version\":"); Quote(sb, libraryVersion);
            sb.Append(",\"options\":{");
            bool first = true;
            foreach (var kv in options)
            {
                if (!first) sb.Append(',');
                first = false;
                Quote(sb, kv.Key); sb.Append(':'); Quote(sb, kv.Value);
            }
            sb.Append("}}");
            Emit(sb);
        }

        public static void Result(string id, Outcome o)
        {
            var sb = new StringBuilder();
            sb.Append("{\"type\":\"result\",\"id\":"); Quote(sb, id);
            sb.Append(",\"status\":"); Quote(sb, o.Status);
            sb.Append(",\"assignments\":"); Pairs(sb, o.Assignments);
            sb.Append(",\"error\":");
            if (o.ErrorClass == null) sb.Append("null");
            else
            {
                sb.Append("{\"class\":"); Quote(sb, o.ErrorClass);
                sb.Append(",\"message\":"); Quote(sb, o.ErrorMessage);
                sb.Append('}');
            }
            sb.Append(",\"warnings\":[");
            for (int i = 0; i < o.Warnings.Count; i++)
            {
                if (i > 0) sb.Append(',');
                Quote(sb, o.Warnings[i]);
            }
            sb.Append("],\"views\":{");
            bool first = true;
            foreach (var kv in o.Views)
            {
                if (!first) sb.Append(',');
                first = false;
                Quote(sb, kv.Key); sb.Append(':'); Pairs(sb, kv.Value);
            }
            sb.Append("}}");
            Emit(sb);
        }

        static readonly Stream Stdout = Console.OpenStandardOutput();

        static void Emit(StringBuilder sb)
        {
            sb.Append('\n');
            byte[] bytes = Encoding.ASCII.GetBytes(sb.ToString());
            Stdout.Write(bytes, 0, bytes.Length);
            Stdout.Flush();
        }

        // The manifest: {"fixtures":[{"id":"...","path":"..."},...]} with
        // JSON string escapes; nothing else is accepted.
        public static List<KeyValuePair<string, string>> Fixtures(string manifest)
        {
            string s = File.ReadAllText(manifest, new UTF8Encoding(false, true));
            var list = new List<KeyValuePair<string, string>>();
            int i = 0;
            string id = null, path = null;
            while (i < s.Length)
            {
                if (s[i] != '"') { i++; continue; }
                string key = ReadString(s, ref i);
                SkipTo(s, ref i, ':');
                i++;
                while (i < s.Length && char.IsWhiteSpace(s[i])) i++;
                if (key == "fixtures") continue;
                string value = ReadString(s, ref i);
                if (key == "id") id = value;
                else if (key == "path") path = value;
                if (id != null && path != null)
                {
                    list.Add(new KeyValuePair<string, string>(id, path));
                    id = null; path = null;
                }
            }
            return list;
        }

        static void SkipTo(string s, ref int i, char c)
        {
            while (i < s.Length && s[i] != c) i++;
        }

        static string ReadString(string s, ref int i)
        {
            if (s[i] != '"') throw new FormatException("manifest: string expected at " + i);
            i++;
            var sb = new StringBuilder();
            while (s[i] != '"')
            {
                char c = s[i++];
                if (c != '\\') { sb.Append(c); continue; }
                char e = s[i++];
                switch (e)
                {
                    case 'n': sb.Append('\n'); break;
                    case 'r': sb.Append('\r'); break;
                    case 't': sb.Append('\t'); break;
                    case 'b': sb.Append('\b'); break;
                    case 'f': sb.Append('\f'); break;
                    case 'u': sb.Append((char)Convert.ToInt32(s.Substring(i, 4), 16)); i += 4; break;
                    default: sb.Append(e); break;
                }
            }
            i++;
            return sb.ToString();
        }

        public static Dictionary<string, string> SnapshotEnvironment()
        {
            var d = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (DictionaryEntry e in Environment.GetEnvironmentVariables())
                d[(string)e.Key] = (string)e.Value;
            return d;
        }

        // The variables whose value a load changed or added, in key order.
        public static List<KeyValuePair<string, string>> Delta(Dictionary<string, string> before,
                                                               Dictionary<string, string> after)
        {
            var keys = new List<string>(after.Keys);
            keys.Sort(StringComparer.Ordinal);
            var delta = new List<KeyValuePair<string, string>>();
            foreach (var k in keys)
            {
                string old;
                if (!before.TryGetValue(k, out old) || old != after[k])
                    delta.Add(new KeyValuePair<string, string>(k, after[k]));
            }
            return delta;
        }

        public static void Fail(Outcome o, Exception e)
        {
            o.Status = "error";
            o.ErrorClass = e.GetType().FullName;
            o.ErrorMessage = e.Message;
        }
    }
}
