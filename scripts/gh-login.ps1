$env:Path = "$env:LOCALAPPDATA\Programs\GitHubCLI\bin;$env:Path"
Write-Host ""
Write-Host "=== Embers iOS - GitHub Device Login ===" -ForegroundColor Yellow
Write-Host "1. Copy the one-time code shown below"
Write-Host "2. Press Enter to open browser: github.com/login/device"
Write-Host "3. Sign in, enter code, click Authorize"
Write-Host ""
gh auth login --hostname github.com --git-protocol https --web
Write-Host ""
Write-Host "Login OK - you can close this window" -ForegroundColor Green