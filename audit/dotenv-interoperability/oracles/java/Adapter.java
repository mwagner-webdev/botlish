// audit/dotenv-interoperability: the dotenv-java adapter (cdimascio/dotenv-java).
//
//   java -cp dotenv-java-VERSION.jar:BUILD Adapter --manifest FILE --config NAME
//
// The public API: Dotenv.configure().directory(DIR).filename(NAME)[...].load().
// load() parses and keeps the pairs; it writes no process state unless
// systemProperties() is configured (it is not). Three observations of one
// load (the distinction matters: README.md, "Java's three views"):
//
//   assignments          entries(Dotenv.Filter.DECLARED_IN_ENV_FILE): the
//                        pairs the file declared, the last of a duplicate
//   views.get            dotenv.get(KEY) for every declared key: what an
//                        application reads -- System.getenv first, then the file
//   views.entries_all    entries(): the file's pairs overlaid by the whole
//                        process environment (counted, not listed)
//
// Configurations: default (throwIfMalformed, the library default) and lenient
// (ignoreIfMalformed()). Output: the adapter protocol's JSON lines, every
// UTF-16 unit outside printable ASCII escaped.
import io.github.cdimascio.dotenv.Dotenv;
import io.github.cdimascio.dotenv.DotenvBuilder;
import io.github.cdimascio.dotenv.DotenvEntry;

import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public final class Adapter {
    private static final PrintStream OUT = new PrintStream(System.out, true, StandardCharsets.US_ASCII);

    static void quote(StringBuilder sb, String s) {
        if (s == null) { sb.append("null"); return; }
        sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '"') sb.append("\\\"");
            else if (c == '\\') sb.append("\\\\");
            else if (c >= 0x20 && c < 0x7f) sb.append(c);
            else sb.append(String.format("\\u%04x", (int) c));
        }
        sb.append('"');
    }

    static void pairs(StringBuilder sb, List<String[]> ps) {
        sb.append('[');
        for (int i = 0; i < ps.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append('[');
            quote(sb, ps.get(i)[0]);
            sb.append(',');
            quote(sb, ps.get(i)[1]);
            sb.append(']');
        }
        sb.append(']');
    }

    static String arg(String[] args, String name, String fallback) {
        for (int i = 0; i + 1 < args.length; i++) if (args[i].equals(name)) return args[i + 1];
        return fallback;
    }

    // The manifest the harness writes: {"fixtures":[{"id":"...","path":"..."},...]}.
    static List<String[]> fixtures(String manifest) throws Exception {
        String s = new String(Files.readAllBytes(Paths.get(manifest)), StandardCharsets.UTF_8);
        List<String[]> out = new ArrayList<>();
        String id = null, path = null;
        int[] at = {0};
        while (at[0] < s.length()) {
            if (s.charAt(at[0]) != '"') { at[0]++; continue; }
            String key = string(s, at);
            while (s.charAt(at[0]) != ':') at[0]++;
            at[0]++;
            while (Character.isWhitespace(s.charAt(at[0]))) at[0]++;
            if (key.equals("fixtures")) continue;
            String value = string(s, at);
            if (key.equals("id")) id = value;
            else if (key.equals("path")) path = value;
            if (id != null && path != null) { out.add(new String[]{id, path}); id = null; path = null; }
        }
        return out;
    }

    static String string(String s, int[] at) {
        int i = at[0] + 1;
        StringBuilder sb = new StringBuilder();
        while (s.charAt(i) != '"') {
            char c = s.charAt(i++);
            if (c != '\\') { sb.append(c); continue; }
            char e = s.charAt(i++);
            switch (e) {
                case 'n': sb.append('\n'); break;
                case 'r': sb.append('\r'); break;
                case 't': sb.append('\t'); break;
                case 'b': sb.append('\b'); break;
                case 'f': sb.append('\f'); break;
                case 'u': sb.append((char) Integer.parseInt(s.substring(i, i + 4), 16)); i += 4; break;
                default: sb.append(e);
            }
        }
        at[0] = i + 1;
        return sb.toString();
    }

    // The version Maven recorded in the jar (META-INF/maven/.../pom.properties).
    static String libraryVersion() {
        try (java.io.InputStream in = Dotenv.class.getResourceAsStream(
                "/META-INF/maven/io.github.cdimascio/dotenv-java/pom.properties")) {
            if (in == null) return null;
            java.util.Properties p = new java.util.Properties();
            p.load(in);
            return p.getProperty("version");
        } catch (java.io.IOException e) {
            return null;
        }
    }

    public static void main(String[] args) throws Exception {
        String config = arg(args, "--config", "default");
        String target = arg(args, "--target", "java");
        String version = libraryVersion();
        StringBuilder meta = new StringBuilder("{\"type\":\"meta\",\"target\":");
        quote(meta, target);
        meta.append(",\"config\":"); quote(meta, config);
        meta.append(",\"runtime\":"); quote(meta, "Java " + System.getProperty("java.version") + " (" + System.getProperty("java.vendor") + ")");
        meta.append(",\"library\":\"dotenv-java\",\"library_version\":"); quote(meta, version);
        meta.append(",\"options\":{\"api\":\"Dotenv.configure().directory(d).filename(f)")
            .append(config.equals("lenient") ? ".ignoreIfMalformed()" : "")
            .append(".load(); entries(DECLARED_IN_ENV_FILE)\",\"default_charset\":");
        quote(meta, java.nio.charset.Charset.defaultCharset().name());
        meta.append("}}");
        OUT.println(meta);

        for (String[] f : fixtures(arg(args, "--manifest", null))) {
            Path p = Paths.get(f[1]).toAbsolutePath();
            StringBuilder sb = new StringBuilder("{\"type\":\"result\",\"id\":");
            quote(sb, f[0]);
            try {
                DotenvBuilder b = Dotenv.configure()
                    .directory(p.getParent().toString())
                    .filename(p.getFileName().toString());
                if (config.equals("lenient")) b = b.ignoreIfMalformed();
                Dotenv d = b.load();
                Map<String, String> declared = new TreeMap<>();
                for (DotenvEntry e : d.entries(Dotenv.Filter.DECLARED_IN_ENV_FILE)) declared.put(e.getKey(), e.getValue());
                List<String[]> assignments = new ArrayList<>();
                List<String[]> got = new ArrayList<>();
                for (Map.Entry<String, String> e : declared.entrySet()) {
                    assignments.add(new String[]{e.getKey(), e.getValue()});
                    got.add(new String[]{e.getKey(), d.get(e.getKey())});
                }
                sb.append(",\"status\":\"ok\",\"assignments\":");
                pairs(sb, assignments);
                sb.append(",\"error\":null,\"warnings\":[],\"views\":{\"get\":");
                pairs(sb, got);
                sb.append(",\"entries_all_count\":[[\"count\",\"").append(d.entries().size()).append("\"]]}}");
            } catch (Throwable t) {
                sb.append(",\"status\":\"error\",\"assignments\":[],\"error\":{\"class\":");
                quote(sb, t.getClass().getName());
                sb.append(",\"message\":");
                quote(sb, String.valueOf(t.getMessage()));
                sb.append("},\"warnings\":[],\"views\":{}}");
            }
            OUT.println(sb);
        }
    }
}
