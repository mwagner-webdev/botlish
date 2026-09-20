# Run from repository root with tclsh9.0.
source native/native.tcl
source surface/surface.tcl
foreach name {fib sum-refined loop-count} {
    set hir [native::buildProgramHir [core::loadProgramFile "bench/$name.ir"]]
    set out [open "native/tests/fixtures/$name.nir" w]
    puts $out [string trimright [native::nir $hir] "\n"]
    close $out
}
set buildSource {fn build(n):
    if n < 1:
        return ""
    prefix = concat("x", "y")
    concat(prefix, build(n - 1))

build(400)}
set hir [surface::compile $buildSource bench-build.bot -strict 0]
set out [open "native/tests/fixtures/build400.nir" w]
puts $out [string trimright [native::nir $hir] "\n"]
close $out
