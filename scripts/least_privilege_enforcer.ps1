<#
.SYNOPSIS
  Removes all non-approved users from a privileged AD group (e.g., Domain Admins) and logs the changes. 

.PARAMETERS
  $GroupName         - The AD group to audit and clean up
  $ProtectedUsers    - List of usersnames (SamAccountName) to exclude from removal
  $LogDirectory      - Directory path where logs will be stored
#>

# === Editable Paraeters === 
$GroupName          = "Domain Admins"
$ProtectedUsers     = @("Administrator", "svc_backup", "gpo_automation")
$LogDirectory       = "C:\Scripts\Logs"

# === Script Logic ===
# Create timestamped log file
$Timestamp          = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath            = Join-Path $LogDirectory "removed-$($GroupName.Replace(' ', '_'))-$Timestamp.txt"

# Ensure log directory exists - if not, it creates it. 
if (!(Test-Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

# Get members to remove (excluding protected users)
$MembersToRemove = Get-ADGroupMember - Identity $GroupName | Where-Object {
    $ProtectedUsers -notcontains $_.SamAccountName
}

# Log and remove each user
foreach ($Member in $MembersToRemove) {
    $LogEntry = "$($Member.SamAccountName) - $($Member.ObjectClass)"
    $LogEntry | Out-File -FilePath $LogPath -Append
    Remove-ADGroupMember -Identity $GroupName -Members $Member -Confirm:$false
}

Write-Host "`nRemoved $($MembersToRemove.Count) user(s) from '$GroupName'."
Write-Host "Log saved to: $LogPath`n"
