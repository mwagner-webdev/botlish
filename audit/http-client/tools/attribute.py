"""attribute.py -- instruction counts of a callgrind profile by where they
are spent (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, section 11): libc copying
and zeroing, allocation, the Botlish runtime (layout decoding, the rest),
compiled Botlish code, Hyper/h2/the bridge, BoringSSL. Run the program
twice under callgrind, with 1 and N+1 operations, and subtract:

    valgrind --tool=callgrind --callgrind-out-file=A ./bench latency URL CA 1
    valgrind --tool=callgrind --callgrind-out-file=B ./bench latency URL CA 201
    python3 -I attribute.py A B 200

Categories are read from symbol names (the executable keeps them).
"""
import re, subprocess, sys
def profile(f):
    out = subprocess.run(['callgrind_annotate','--inclusive=no','--auto=no','--threshold=100',f],capture_output=True,text=True).stdout
    d = {}
    for line in out.splitlines():
        m = re.match(r'\s*([\d,]+) \([\s\d.]+%\)\s+(.*)$', line)
        if not m or 'PROGRAM TOTALS' in line: continue
        ir = int(m.group(1).replace(',','')); name = m.group(2)
        d[name] = d.get(name,0)+ir
    return d
def cat(name):
    n = name
    if re.search(r'memcpy|memmove|memset', n): return 'copying and zeroing (libc)'
    if re.search(r'malloc|_int_free|free\b|arena\.c|__rdl_alloc|__rdl_dealloc|unlink_chunk|realloc|calloc|alloc::alloc', n): return 'allocation (libc malloc)'
    if re.search(r'botlish_fn_', n): return 'Botlish code (compiled)'
    if re.search(r'bin_extent|bin_decode|rt_bin_load|bin_encode|rt_bin_store|nview|layout', n): return 'Botlish runtime: layout decoding'
    if re.search(r'botlish_native::runtime|rt_[a-z]|runtime/', n): return 'Botlish runtime: other'
    if re.search(r'hyper|h2::|botlish_http|::http::|bytes::|futures|tokio|tracing|bridge/|client\.rs|body\.rs', n): return 'Hyper, h2 and the bridge (Rust)'
    if re.search(r'bssl|X509|x509|EVP_|SSL_|ssl|aes|gcm|GCM|sha|SHA|base64|BN_|bn_|ec_|EC_|asn1|ASN1|CRYPTO|ChaCha|chacha|poly1305|OPENSSL|PEM|pem|CBS|CBB|crypto/', n): return 'BoringSSL'
    if re.search(r'libc\.so|libstdc\+\+|ld-linux|libgcc', n): return 'libc and others'
    return 'other'
a = profile(sys.argv[1]); b = profile(sys.argv[2]); n = int(sys.argv[3])
cats = {}
for k in set(a)|set(b):
    c = cat(k); cats[c] = cats.get(c,0) + b.get(k,0) - a.get(k,0)
total = sum(cats.values())
print('per request: %.0f instructions' % (total/n))
for c,v in sorted(cats.items(), key=lambda x:-x[1]):
    print('%-40s %8.0f  %5.1f%%' % (c, v/n, 100.0*v/total))
