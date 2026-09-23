# Auto Git Push Script for SQL Server Management Studio 22 files
$workingDir = "c:\Users\sailenmondal\Documents\SQL Server Management Studio 22"
$gitBin = "C:\Users\sailenmondal\AppData\Local\Programs\Git\cmd\git.exe"
$logFile = "$workingDir\auto_push.log"

Set-Location -Path $workingDir
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $logFile -Value "=========================================="
Add-Content -Path $logFile -Value "[$timestamp] Starting daily auto-push check..."

# Check if git binary exists
if (-not (Test-Path $gitBin)) {
    # Fallback to PATH lookup
    $gitBin = "git"
}

# Add untracked and modified files
& $gitBin add .

# Check git status for changes
$status = & $gitBin status --porcelain
if ($status) {
    $commitMsg = "Auto-update SQL files [$timestamp]"
    & $gitBin commit -m $commitMsg
    Add-Content -Path $logFile -Value "[$timestamp] Changes committed: $commitMsg"
} else {
    Add-Content -Path $logFile -Value "[$timestamp] No local changes detected."
}

# Push to remote repository
$pushOutput = & $gitBin push origin main 2>&1 | Out-String
Add-Content -Path $logFile -Value "[$timestamp] Push result:`n$pushOutput"
Add-Content -Path $logFile -Value "=========================================="
