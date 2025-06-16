<#
.SYNOPSIS
  Backs up all GPOs in the current domain to a specified directory.

.PARAMETERS
  $BackupRoot      - Root path where GPO backups will be saved
  $Timestamped     - Whether to store backups in a timestamped subfolder
#>

# === Editable Parameters ===
$BackupRoot   = "C:\GPO-Backups"
$Timestamped  = $true

# === Script Logic ===
Import-Module GroupPolicy

# Create timestamped folder if enabled
if ($Timestamped) {
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $BackupPath = Join-Path $BackupRoot "GPO-Backup-$Timestamp"
} else {
    $BackupPath = $BackupRoot
}

# Ensure backup directory exists
if (!(Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

# Backup all GPOs
Backup-GPO -All -Path $BackupPath

Write-Host "`nAll GPOs backed up to: $BackupPath`n"
