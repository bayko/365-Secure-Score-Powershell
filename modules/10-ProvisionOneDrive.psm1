
<#
 .Description
  Pre-provision Onedrive Storage for all users

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
   Set-ProvisionOneDrive -Enabled $true
#>

function Set-ProvisionOneDrive {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {    
    $OneDriveUsers = Get-MSOLUser -All | Select-Object UserPrincipalName,islicensed | Where-Object {$_.islicensed -eq "True"}
    Request-SPOPersonalSite -UserEmails $OneDriveUsers.UserPrincipalName -NoWait
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing Set-MailboxAuditing (Set-MailboxAuditing -Enabled $true)" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-ProvisionOneDrive