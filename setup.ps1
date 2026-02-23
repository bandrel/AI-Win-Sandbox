$progressPreference = 'silentlyContinue'
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet... You will see an error but it still needed to run"
Repair-WinGetPackageManager -AllUsers
Write-Host "Done."

Write-Host "=== Claude Sandbox Setup ===" -ForegroundColor Cyan

Write-Host "`n[1/4] Installing Git..." -ForegroundColor Yellow
winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements --source winget

Write-Host "`n[2/4] Installing VS Code..." -ForegroundColor Yellow
winget install --id Microsoft.VisualStudioCode -e --silent --accept-package-agreements --accept-source-agreements --source winget

$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + `
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

Write-Host "`n[3/4] Installing Claude Code..." -ForegroundColor Yellow
irm https://claude.ai/install.ps1 | iex

# Refresh PATH so claude/git/code are immediately usable in this window
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + `
            [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + `
            "C:\Users\WDAGUtilityAccount\.local\bin"

Write-Host "`n[4/4] Copying Claude config (credentials, skills, settings, plugins...)..." -ForegroundColor Yellow
$dest = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item "C:\ClaudeHostConfig\*" $dest -Recurse -Force

# Copy .claude.json (first-run/onboarding state) from setup folder
Copy-Item "C:\setup\.claude.json" "$env:USERPROFILE\.claude.json" -Force -ErrorAction SilentlyContinue
mkdir C:\claudework
cd C:\claudework
claude /login --dangerously-skip-permissions

Write-Host "`n=== Done! Run 'claude' to get started. ===" -ForegroundColor Green
