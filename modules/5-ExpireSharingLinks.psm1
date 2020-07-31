
<#
 .Synopsis
  Set sharing links from sharepoint to expire

 .Description
  Sets a 14 day expiry time for sharepoint links

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing
  
 .Parameter Days
  14 days by default but can set custom

 .Example
  Set-ExpireSharingLinks -Enabled $true -Days 14
#>

function Set-ExpireSharingLinks {
  param(
    [bool]$Enabled = $false,
    [int]$Days = 14
  )
  if ($Enabled) {
    $Spolinks = Get-SpoTenant 
    if ($Spolinks.RequireAnonymousLinksExpireInDays -gt "0") {
      Write-Host '***External sharing links are already set to expire after a time' -ForegroundColor Blue
    } else {
      Set-SpoTenant -RequireAnonymousLinksExpireInDays $Days;
      Write-Host "***External sharing links now set to expire after $($Days) days" -ForegroundColor Green
      }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-ExpireSharingLinks