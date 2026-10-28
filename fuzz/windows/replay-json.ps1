# replay-json.ps1 -- the Windows half of the JSON campaign
# (FUZZING-JSON.md): emit the conformance target's Windows executable
# (x86_64-pc-windows-msvc, the host-native AOT path) and replay the same
# committed seed corpus through it, comparing each report against the
# Linux AOT expectations (fuzz/windows/expected-conformance.tsv, exported
# by fuzz/scripts/export-json-expectations.sh).
#
# Why replay and not fuzz: AFL++ has no Windows port, so there is no
# coverage-feedback fuzzer to drive here (the campaign's own brief bars
# dumb fuzzing). The differential replay oracle -- same input, same
# observable report, now across operating systems -- is what Windows can
# contribute today, and it runs the real native backend on the real OS.
#
# From the repository root (PowerShell):
#   powershell -ExecutionPolicy Bypass -File fuzz\windows\replay-json.ps1
param(
    [string]$Repo = ""
)
$ErrorActionPreference = 'Stop'
if (-not $Repo) { $Repo = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) }
Set-Location $Repo

# --- 1. Toolchain ------------------------------------------------------------
$tclsh = @("$env:LOCALAPPDATA\Apps\Tcl90\bin\tclsh90.exe",
           "$env:LOCALAPPDATA\Apps\Tcl90\bin\tclsh.exe",
           "C:\botlish-tcl\bin\tclsh9.0.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $tclsh) { Write-Output "NO-TCLSH (build it: tests/platform/setup-windows.ps1)"; exit 0 }
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { Write-Output "NO-CARGO"; exit 0 }
Write-Output "tclsh: $tclsh"

# --- 2. The native driver, if not built yet ---------------------------------
$driver = Join-Path $Repo "native\target\release\botlish-native.exe"
if (-not (Test-Path $driver)) {
    Write-Output "building the native driver (cargo build --release)..."
    & cargo build --release --manifest-path (Join-Path $Repo "native\Cargo.toml") | Out-Null
}

# --- 3. Emit the conformance executable (module files beside it) ------------
$work = Join-Path $Repo "fuzz\build\aot-win"
New-Item -ItemType Directory -Force -Path $work | Out-Null
foreach ($m in 'json.bot', 'json_lex.bot') {
    Copy-Item (Join-Path $Repo "examples\dfa\json\$m") (Join-Path $work $m) -Force
}
Copy-Item (Join-Path $Repo "fuzz\programs\conformance-win.bot") (Join-Path $work 'conformance-win.bot') -Force
$exe = Join-Path $work "conformance-win.exe"
& $tclsh (Join-Path $Repo "main.tcl") -emit-native-executable (Join-Path $work 'conformance-win.bot') | Out-Null
if (-not (Test-Path $exe)) { Write-Output "EMIT-FAILED"; exit 0 }
Write-Output "exe: $exe"

# --- 4. Replay the corpus ----------------------------------------------------
$expected = @{}
Get-Content (Join-Path $Repo "fuzz\windows\expected-conformance.tsv") | ForEach-Object {
    $p = $_ -split "`t", 2
    if ($p.Count -eq 2) { $expected[$p[0]] = $p[1] }
}
$agree = 0; $drift = 0; $missing = 0
Get-ChildItem (Join-Path $Repo "fuzz\seeds\conformance") | ForEach-Object {
    $name = $_.Name
    # The seed file is an argv vector (NUL-separated): argv-file.c's
    # semantics, PowerShell-side.
    $bytes = [IO.File]::ReadAllBytes($_.FullName)
    $args = New-Object System.Collections.Generic.List[string]
    $seg = New-Object System.Collections.Generic.List[byte]
    foreach ($b in $bytes) {
        if ($b -eq 0) { $args.Add([Text.Encoding]::UTF8.GetString($seg)); $seg.Clear() }
        else { $seg.Add($b) }
    }
    if ($seg.Count -gt 0) { $args.Add([Text.Encoding]::UTF8.GetString($seg)) }
    if ($args.Count -gt 0 -and $args[$args.Count - 1] -eq '') { $args.RemoveAt($args.Count - 1) }

    $out = & $exe @args 2>&1 | Where-Object { "$_" -ne '' }
    $lines = @($out | ForEach-Object { "$_".TrimEnd() })
    if ($lines.Count -gt 0) { $lines = $lines[0..($lines.Count - 2)] }  # drop the value line
    $report = 'result|report|' + ($lines -join ' / ')

    if (-not $expected.ContainsKey($name)) { $missing++; return }
    if ($expected[$name] -eq $report) { $agree++ }
    else {
        $drift++
        Write-Output "DRIFT ${name}:"
        Write-Output "  expected: $($expected[$name])"
        Write-Output "  windows : $report"
    }
}
Write-Output "windows-replay: $agree agree, $drift drifted, $missing without expectations (informational)"
exit 0
