#!/bin/bash
# callvalue-coverage.sh TREE OUT.log -- run the whole test suite (interpreter backend) on a copy of TREE with every `callvalue` emission logged as "test<TAB>file<TAB>callvalue". Used on the previous tree and this one, then compared with callvalue-coverage-diff.py: it shows which tests stopped exercising the generic callable-value path. TREE is not modified.
set -eu
tree=$(cd "$1" && pwd); log=$2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
(cd "$tree" && tar --exclude=.git --exclude=native/target -cf - .) | (cd "$work" && tar xf -)
ln -s "$tree/native/target" "$work/native/target"
cd "$work"
python3 - <<'PY'
p = 'native/lower.tcl'
s = open(p).read()
old = '    dict lappend fn calls [list value]\n    return [list [Assign fn [string trimright "callvalue'
assert old in s, 'callvalue emission site not found'
s = s.replace(old, '    dict lappend fn calls [list value]\n    catch {::CovLog callvalue}\n    return [list [Assign fn [string trimright "callvalue')
open(p, 'w').write(s)
p = 'tests/helpers.tcl'
s = open(p).read()
s += '''
proc ::CovLog {what} {
    set f [open $::env(COV_LOG) a]
    puts $f "[expr {[info exists ::curTest] ? $::curTest : {-}}]\\t[file tail [info script]]\\t$what"
    close $f
}
trace add execution ::tcltest::test enter {apply {{cmd op} {set ::curTest [lindex $cmd 1]}}}
'''
open(p, 'w').write(s)
PY
export LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=interp COV_LOG=$log
rm -f "$log"
tclsh9.0 tests/all.tcl > /dev/null 2>&1 || true
echo "wrote $log: $(wc -l < "$log") callvalue emissions"
