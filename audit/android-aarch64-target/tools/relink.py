#!/usr/bin/env python3
# Rewrites every absolute symbolic link under ROOT into a link relative to
# its own directory, so that ROOT works as a sysroot prefix (qemu -L).
import os, sys
root = os.path.abspath(sys.argv[1])
n = 0
for d, dirs, files in os.walk(root):
    for name in dirs + files:
        p = os.path.join(d, name)
        if os.path.islink(p):
            t = os.readlink(p)
            if t.startswith('/'):
                rel = os.path.relpath(root + t, d)
                os.unlink(p); os.symlink(rel, p); n += 1
print(n, 'links rewritten')
