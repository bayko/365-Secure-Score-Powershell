
<#
 .Description
  Remove ability for users to consent to sharing 365 data with 3rd party apps

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
  Set-DisableUserConsent -Enabled $true
#>
function Set-DisableUserConsent {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    Set-AzureADMSAuthorizationPolicy `
      -Id "authorizationPolicy" `
      -PermissionGrantPolicyIdsAssignedToDefaultUserRole @()
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-DisableUserConsent