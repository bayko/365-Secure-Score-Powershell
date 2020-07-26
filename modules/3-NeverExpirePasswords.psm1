
<#
 .Synopsis
  Set all 365 user passwords to 'never expire'

 .Description
  Set change the password policy for all users in microsoft online to 'never expire'

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
   Set-NeverExpirePasswords -Enabled $true
#>

function Set-NeverExpirePasswords {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $Userexpire = Get-MSOLUser | Where-Object {$_.PasswordNeverExpires -eq $false}
    if ($Userexpire.Count -eq "0") {
      Write-Host '***All user passwords are already set to never expire' -ForegroundColor Blue
    } else {
      $Userexpire | Set-MSOLUser -PasswordNeverExpires $true
      Write-Host '***All user passwords are now set to never expire' -ForegroundColor Green
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing Set-MailboxAuditing (Set-MailboxAuditing -Enabled $true)" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-NeverExpirePasswords