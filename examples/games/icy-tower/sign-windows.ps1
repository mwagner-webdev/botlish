# sign-windows.ps1 -- Authenticode signatures for the Icy Tower Windows build
# (ICY-TOWER-WINDOWS.md, "Signing"), on Windows with the Windows SDK's
# signtool:
#
#   pwsh examples/games/icy-tower/sign-windows.ps1 -Pfx CERT.pfx [-Password P]
#       [-TimestampUrl URL] [-Description TEXT] [-DescriptionUrl URL] FILE...
#   pwsh examples/games/icy-tower/sign-windows.ps1 -Verify FILE...
#
# The first form signs each FILE (icy-tower.exe, SDL3.dll) with the
# code-signing certificate and private key in the PFX file CERT.pfx: a
# SHA-256 file digest and an RFC 3161 timestamp, SHA-256 too, so the
# signature stays valid after the certificate expires; -TimestampUrl ""
# signs without one. It fails unless every FILE then carries a signature by
# that very certificate. The workflow's signing dry run uses it with a
# throwaway self-signed certificate; a release is signed by Azure Artifact
# Signing instead: since June 2023 a publicly trusted code-signing key must
# live in hardware, never in a file.
#
# The second form checks, for a release, that every FILE carries a valid
# Authenticode signature -- its certificate chaining to a root Windows
# trusts -- and a timestamp, whoever made it.
[CmdletBinding(PositionalBinding = $false)]
param(
    [string]$Pfx = "",
    [string]$Password = "",
    [string]$TimestampUrl = "http://timestamp.digicert.com",
    [string]$Description = "Icy Tower",
    [string]$DescriptionUrl = "",
    [switch]$Verify,
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$Files
)
$ErrorActionPreference = "Stop"
if (-not $Files) { throw "sign-windows.ps1: no files" }
$Files = $Files | ForEach-Object { (Resolve-Path $_).Path }

if ($Verify) {
    $failed = 0
    foreach ($file in $Files) {
        $signature = Get-AuthenticodeSignature $file
        $signer = $signature.SignerCertificate
        $stamp = $signature.TimeStamperCertificate
        Write-Host ("{0}: {1}; signed by {2}; timestamped by {3}" -f (Split-Path -Leaf $file), $signature.Status,
            $(if ($signer) { $signer.Subject } else { "nobody" }), $(if ($stamp) { $stamp.Subject } else { "nobody" }))
        if ($signature.Status -ne "Valid" -or -not $stamp) {
            Write-Host "  $($signature.StatusMessage)"
            $failed++
        }
    }
    if ($failed) { throw "sign-windows.ps1: $failed file(s) without a valid, timestamped signature" }
    return
}

if ($Pfx -eq "") { throw "sign-windows.ps1: -Pfx CERT.pfx (or -Verify)" }

# signtool.exe of the newest Windows SDK installed (Visual Studio's), x64.
$signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\*\x64\signtool.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.Directory.Parent.Name -match '^\d+(\.\d+)+$' } |
    Sort-Object { [version]$_.Directory.Parent.Name } -Descending | Select-Object -First 1
if (-not $signtool) { throw "sign-windows.ps1: no signtool.exe (install the Windows SDK)" }

# The certificate the signatures must name: the PFX's one with a private key.
$pfxPath = (Resolve-Path $Pfx).Path
$certificates = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certificates.Import($pfxPath, $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::EphemeralKeySet)
$certificate = $certificates | Where-Object { $_.HasPrivateKey } | Select-Object -First 1
if (-not $certificate) { throw "sign-windows.ps1: $Pfx holds no certificate with a private key" }
Write-Host "signing with $($certificate.Subject) ($($certificate.Thumbprint)), valid until $($certificate.NotAfter)"

$arguments = @("sign", "/fd", "SHA256", "/f", $pfxPath)
if ($Password) { $arguments += @("/p", $Password) }
if ($Description) { $arguments += @("/d", $Description) }
if ($DescriptionUrl) { $arguments += @("/du", $DescriptionUrl) }
if ($TimestampUrl) { $arguments += @("/tr", $TimestampUrl, "/td", "SHA256") }
& $signtool.FullName @arguments @Files
if ($LASTEXITCODE -ne 0) { throw "sign-windows.ps1: signtool sign failed ($LASTEXITCODE)" }

foreach ($file in $Files) {
    $signer = (Get-AuthenticodeSignature $file).SignerCertificate
    if (-not $signer -or $signer.Thumbprint -ne $certificate.Thumbprint) {
        throw "sign-windows.ps1: $file is not signed by $($certificate.Thumbprint)"
    }
    Write-Host "$(Split-Path -Leaf $file): signed by $($signer.Subject)"
}
