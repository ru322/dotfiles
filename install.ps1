# install.ps1 - Windows dotfiles installer
# Creates symlinks from common/ and windows/ to appropriate locations

$ErrorActionPreference = "Stop"
$Dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Path

function Link-Files {
    param([string]$SrcDir)

    if (-not (Test-Path $SrcDir)) { return }

    Get-ChildItem -Path $SrcDir -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($SrcDir.Length + 1)
        $dest = Join-Path $env:USERPROFILE $rel
        $destDir = Split-Path -Parent $dest

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        if (Test-Path $dest) {
            if (-not (Get-Item $dest).Attributes.HasFlag([System.IO.FileAttributes]::ReparsePoint)) {
                Write-Host "Backing up $dest -> $dest.bak"
                Move-Item $dest "$dest.bak"
            } else {
                Remove-Item $dest
            }
        }

        New-Item -ItemType SymbolicLink -Path $dest -Target $_.FullName | Out-Null
        Write-Host "Linked $rel"
    }
}

Link-Files (Join-Path $Dotfiles "common")
Link-Files (Join-Path $Dotfiles "windows")

Write-Host "`nDone!"
