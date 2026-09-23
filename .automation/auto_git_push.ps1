# Hardened Auto Git Push Script for SQL Server Management Studio 22
# Handles: Network outages, stale locks, log rotation, remote rebase sync, missed execution recovery

$workingDir = "c:\Users\sailenmondal\Documents\SQL Server Management Studio 22"
$gitBin = "C:\Users\sailenmondal\AppData\Local\Programs\Git\cmd\git.exe"
$automationDir = "$workingDir\.automation"
$logFile = "$automationDir\auto_push.log"
$lockFile = "$workingDir\.git\index.lock"

# Ensure automation directory exists
if (-not (Test-Path $automationDir)) {
    New-Item -ItemType Directory -Path $automationDir -Force | Out-Null
}

# Ensure Git is in Path
if (-not (Test-Path $gitBin)) {
    $gitBin = "git"
}
$env:Path += ";C:\Users\sailenmondal\AppData\Local\Programs\Git\cmd"

Set-Location -Path $workingDir
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Log Rotation: keep log file under 2 MB
if ((Test-Path $logFile) -and ((Get-Item $logFile).Length -gt 2MB)) {
    $recentLog = Get-Content $logFile -Tail 1000
    Set-Content -Path $logFile -Value $recentLog
}

Add-Content -Path $logFile -Value "=========================================="
Add-Content -Path $logFile -Value "[$timestamp] Starting daily auto-push process..."

# Edge Case 1: Check and cleanup stale git index.lock if older than 5 minutes
if (Test-Path $lockFile) {
    $lockAgeMinutes = ((Get-Date) - (Get-Item $lockFile).LastWriteTime).TotalMinutes
    if ($lockAgeMinutes -gt 5) {
        Remove-Item $lockFile -Force
        Add-Content -Path $logFile -Value "[$timestamp] WARNING: Removed stale git lock file older than $lockAgeMinutes minutes."
    } else {
        Add-Content -Path $logFile -Value "[$timestamp] ERROR: Git lock file is active. Skipping push to avoid collision."
        exit 1
    }
}

# Stage all new, modified, and deleted files
& $gitBin add -A

# Check for pending uncommitted changes
$status = & $gitBin status --porcelain
if ($status) {
    $commitMsg = "Auto-update SQL files [$timestamp]"
    $commitOutput = & $gitBin commit -m $commitMsg 2>&1 | Out-String
    Add-Content -Path $logFile -Value "[$timestamp] Committed local changes: $commitMsg"
} else {
    Add-Content -Path $logFile -Value "[$timestamp] No new uncommitted file changes."
}

# Edge Case 2: Pull remote changes with rebase before pushing to avoid non-fast-forward conflicts
$pullOutput = & $gitBin pull --rebase origin main 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    Add-Content -Path $logFile -Value "[$timestamp] WARNING: git pull --rebase reported notice/conflict:`n$pullOutput"
    & $gitBin rebase --abort 2>&1 | Out-Null
}

# Edge Case 3: Push with Network Retry Loop (3 attempts with 30s delay)
$maxRetries = 3
$pushed = $false

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    Add-Content -Path $logFile -Value "[$timestamp] Pushing to GitHub (Attempt $attempt of $maxRetries)..."
    $pushOutput = & $gitBin push origin main 2>&1 | Out-String
    
    if ($LASTEXITCODE -eq 0) {
        Add-Content -Path $logFile -Value "[$timestamp] SUCCESS: Push completed successfully.`n$pushOutput"
        $pushed = $true
        break
    } else {
        Add-Content -Path $logFile -Value "[$timestamp] Push attempt $attempt failed:`n$pushOutput"
        if ($attempt -lt $maxRetries) {
            Start-Sleep -Seconds 30
        }
    }
}

if (-not $pushed) {
    Add-Content -Path $logFile -Value "[$timestamp] ERROR: All push attempts failed. Will retry at next scheduled interval."
}

Add-Content -Path $logFile -Value "=========================================="
