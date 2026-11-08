#!/usr/bin/env python3
# Minimal reader of an Android dynamic-partition ("super") image's LP
# metadata (liblp's format): extracts each named partition's linear extents.
import struct, sys, os
src, offset, outdir = sys.argv[1], int(sys.argv[2]), sys.argv[3]
f = open(src, 'rb')
def rd(at, n): f.seek(offset + at); return f.read(n)
geo = rd(4096, 4096)
magic, gsize = struct.unpack('<II', geo[:8])
assert magic == 0x616c4467, hex(magic)
meta_max, slots, lbs = struct.unpack('<III', geo[8+4+32:8+4+32+12])
hdr_at = 4096 + 4096 * 2  # reserved + primary/backup geometry
h = rd(hdr_at, 256)
hmagic, major, minor, hsize = struct.unpack('<IHHI', h[:12])
assert hmagic == 0x414C5030, hex(hmagic)
tables_size = struct.unpack('<I', h[44:48])[0]
def desc(at): return struct.unpack('<III', h[at:at+12])  # offset, num, entry_size
parts, exts = desc(80), desc(92)
tables = rd(hdr_at + hsize, tables_size)
def entries(d):
    o, n, s = d
    return [tables[o + i*s: o + (i+1)*s] for i in range(n)]
E = [struct.unpack('<QIQI', e[:24]) for e in entries(exts)]
os.makedirs(outdir, exist_ok=True)
for p in entries(parts):
    name = p[:36].rstrip(b'\0').decode()
    attrs, first, num, group = struct.unpack('<IIII', p[36:52])
    if num == 0: continue
    with open(os.path.join(outdir, name + '.img'), 'wb') as out:
        for sectors, ttype, data, srcdev in E[first:first+num]:
            assert ttype == 0, 'non-linear extent'
            f.seek(offset + data * 512)
            left = sectors * 512
            while left:
                chunk = f.read(min(left, 1 << 22)); out.write(chunk); left -= len(chunk)
    print(name, sum(e[0] for e in E[first:first+num]) * 512)
