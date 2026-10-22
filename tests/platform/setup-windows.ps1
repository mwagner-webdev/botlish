# setup-windows.ps1 -- the Windows x86-64 counterpart of .devcontainer/setup.sh
# for the Windows workflow (.github/workflows/windows-x86_64.yml;
# WINDOWS-X86-64-MILESTONE-1.md, section 7): this repository's baseline Tcl
# 9.0.1, built from its pinned source release with MSVC's nmake (no package
# ships it), and the stable Rust toolchain for x86_64-pc-windows-msvc, the
# one native Windows target.
#
#   pwsh tests/platform/setup-windows.ps1 [-Prefix DIR] [-PathFile FILE]
#
# Tcl is installed into PREFIX (default C:\botlish-tcl) unless PREFIX\bin
# already holds it (a cache hit): tclsh90.exe, and tclsh9.0.exe beside it
# for the name the repository's documentation uses. With -PathFile (the
# workflow's $GITHUB_PATH) PREFIX\bin is appended to it. Visual Studio's C++
# tools are found with vswhere and entered only for the Tcl build: the
# native driver and its executables link without a Developer Command Prompt
# (rustc finds link.exe and the Windows SDK itself).
param(
    [string]$Prefix = "C:\botlish-tcl",
    [string]$PathFile = ""
)
$ErrorActionPreference = "Stop"
$version = "9.0.1"
$sha256 = "a72b1607d7a399c75148c80fcdead88ed3371a29884181f200f2200cdee33bbc"

if (-not (Test-Path "$Prefix\bin\tclsh90.exe")) {
    $work = Join-Path ([IO.Path]::GetTempPath()) "botlish-tcl-build-$PID"
    New-Item -ItemType Directory -Force $work | Out-Null
    Push-Location $work
    try {
        # curl.exe (Windows' own): SourceForge answers a browser-like
        # client such as Invoke-WebRequest with an HTML mirror page.
        $urls = @("https://downloads.sourceforge.net/project/tcl/Tcl/$version/tcl$version-src.tar.gz",
                  "https://prdownloads.sourceforge.net/tcl/tcl$version-src.tar.gz")
        $fetched = $false
        foreach ($url in $urls) {
            curl.exe -fsSL --retry 3 -o tcl-src.tar.gz $url
            if ($LASTEXITCODE -eq 0) { $fetched = $true; break }
            Write-Host "failed: $url"
        }
        if (-not $fetched) { throw "cannot download Tcl $version" }
        $hash = (Get-FileHash tcl-src.tar.gz -Algorithm SHA256).Hash.ToLower()
        if ($hash -ne $sha256) { throw "Tcl $version source: sha256 $hash, expected $sha256" }
        tar -xzf tcl-src.tar.gz
        if ($LASTEXITCODE -ne 0) { throw "cannot unpack the Tcl source" }
        $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * `
            -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if (-not $vs) { throw "no Visual Studio installation with the C++ x64 tools" }
        $vcvars = "$vs\VC\Auxiliary\Build\vcvars64.bat"
        # CC=cl on nmake's command line: nmake takes CC from the environment,
        # and rules.vc asks $(CC) for MSVC's version (vercl.x), so the
        # workflow's CC=clang (the C ABI facts' compiler) would leave
        # VCVERSION undefined: "rules.vc(508) : fatal error U1023".
        $build = "call `"$vcvars`" >nul && cd /d tcl$version\win && nmake /nologo /f makefile.vc release INSTALLDIR=$Prefix CC=cl && nmake /nologo /f makefile.vc install INSTALLDIR=$Prefix CC=cl"
        cmd /c $build
        if ($LASTEXITCODE -ne 0) { throw "the Tcl build failed" }
    } finally {
        Pop-Location
        Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    }
}
if (-not (Test-Path "$Prefix\bin\tclsh9.0.exe")) {
    Copy-Item "$Prefix\bin\tclsh90.exe" "$Prefix\bin\tclsh9.0.exe"
}
'puts "Tcl [info patchlevel], tcltest [package require tcltest 2.5], [encoding system], $tcl_platform(os) $tcl_platform(machine)"' | & "$Prefix\bin\tclsh90.exe"
if ($LASTEXITCODE -ne 0) { throw "the installed tclsh does not run" }

rustup toolchain install stable-x86_64-pc-windows-msvc --profile minimal
if ($LASTEXITCODE -ne 0) { throw "rustup failed" }
rustup default stable-x86_64-pc-windows-msvc
if ($LASTEXITCODE -ne 0) { throw "rustup failed" }
$hostTriple = (rustc -vV | Select-String '^host: ').ToString().Substring(6)
if ($hostTriple -ne "x86_64-pc-windows-msvc") { throw "rustc's host is $hostTriple, not x86_64-pc-windows-msvc" }

if ($PathFile -ne "") {
    "$Prefix\bin" | Out-File -FilePath $PathFile -Append -Encoding utf8
}
