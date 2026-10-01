# callvalue-coverage-diff.py BEFORE.log AFTER.log -- compare two callvalue-coverage.sh logs: tests that lost / gained / emit fewer / emit more `callvalue` sites.
import sys, collections
def load(p):
    tests=collections.OrderedDict()
    for line in open(p):
        parts=line.rstrip('\n').split('\t')
        if len(parts)<3: continue
        tests.setdefault((parts[1],parts[0]),0)
        tests[(parts[1],parts[0])]+=1
    return tests
b=load(sys.argv[1]); a=load(sys.argv[2])
lost=[k for k in b if k not in a]
gained=[k for k in a if k not in b]
fewer=[(k,b[k],a[k]) for k in b if k in a and a[k]<b[k]]
more=[(k,b[k],a[k]) for k in b if k in a and a[k]>b[k]]
print("tests emitting callvalue: base=%d after=%d  (callvalue emissions: base=%d after=%d)"%(len(b),len(a),sum(b.values()),sum(a.values())))
print("\nLOST callvalue entirely (%d):"%len(lost))
for k in lost: print("  %s :: %s  (base emitted %d)"%(k[0],k[1],b[k]))
print("\nGAINED callvalue (%d):"%len(gained))
for k in gained: print("  %s :: %s  (after emitted %d)"%(k[0],k[1],a[k]))
print("\nFEWER callvalue sites (%d):"%len(fewer))
for k,x,y in fewer: print("  %s :: %s  %d -> %d"%(k[0],k[1],x,y))
print("\nMORE callvalue sites (%d):"%len(more))
for k,x,y in more: print("  %s :: %s  %d -> %d"%(k[0],k[1],x,y))
