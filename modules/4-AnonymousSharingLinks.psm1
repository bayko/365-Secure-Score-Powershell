
<#
 .Synopsis
  Enables anonymous sharing links in sharepoint

 .Description
  Enables users to create anonymous sharing links for any sharepoint site

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
   Set-AnonymousSharingLinks -Enabled $true
#>

function Set-AnonymousSharingLinks {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $sites = Get-sposite -template GROUP
    Foreach($site in $sites)
    {
      Set-SPOSite -Identity $site.Url -SharingCapability ExternalUserAndGuestSharing;
    }
    Write-Host '***Anonymous guest sharing links are now enabled' -ForegroundColor Green
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-AnonymousSharingLinks