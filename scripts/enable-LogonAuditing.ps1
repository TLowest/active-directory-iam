<#
.SYNOPSIS
  Enables logon event auditing (success and/or failure) on the local system using auditpol.

.PARAMETERS
  $Subcategory   - The audit subcategory to modify (default: Logon)
  $Success       - Enable auditing on success (default: $true)
  $Failure       - Enable auditing on failure (default: $true)
#>

param (
    [string]$Subcategory = "Logon",
    [bool]$Success = $true,
    [bool]$Failure = $true
)

function Set-LogonAuditPolicy {
    $successFlag = if ($Success) { "enable" } else { "disable" }
    $failureFlag = if ($Failure) { "enable" } else { "disable" }

    $command = "AuditPol /set /subcategory:`"$Subcategory`" /success:$successFlag /failure:$failureFlag"
    Invoke-Expression $command

Write-Host "`n=== Logon Audit Policy Updated ==="
Write-Host ("{0,-15}: {1}" -f "Subcategory", $Subcategory)
Write-Host ("{0,-15}: {1}" -f "Success",     $successFlag)
Write-Host ("{0,-15}: {1}" -f "Failure",     $failureFlag)
Write-Host "==================================`n"

}

# Run the function
Set-LogonAuditPolicy
