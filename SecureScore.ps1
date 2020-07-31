Import-Module './modules/1-MailboxAuditing.psm1'
Import-Module './modules/2-BlockClientForwarding.psm1'
Import-Module './modules/3-NeverExpirePasswords.psm1'
Import-Module './modules/4-AnonymousSharingLinks.psm1'
Import-Module './modules/5-ExpireSharingLinks.psm1'
Import-Module './modules/6-AuditLogIngestion.psm1'
Import-Module './modules/7-AnonymousCalendarSharing.psm1'
Import-Module './modules/8-SharepointVersioning.psm1'
Import-Module './modules/9-SharepointIRMPolicies.psm1'
Import-Module './modules/10-ProvisionOneDrive.psm1'
Import-Module './modules/11-DataLossPrevention.psm1'
Import-Module './modules/12-AdvancedThreatProtection.psm1'
Import-Module './modules/13-DisableUserConsent.psm1'

if ((Get-Module -ListAvailable -Name MSOnline) -and (Get-Module -ListAvailable -Name Microsoft.Online.Sharepoint.Powershell)) {
} else {
    Write-Host "This script requires the Microsoft Online, Microsoft Exchange, and Sharepoint Online powershell modules"
    Exit
}

function Connect-Office365 {
  # Get secure creds
  param(
    [System.Management.Automation.PSCredential]$UserCredential
  )
  # Microsoft Online
  Connect-MsolService -Credential $UserCredential
  # Exchange Online
  $Session = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -Credential $UserCredential -Authentication Basic -AllowRedirection
  Import-Module (Import-PSSession -Session $Session -DisableNameChecking -AllowClobber) -Global
  # Sharepoint Online
  $Clientdomains = Get-MsolDomain | Select-Object Name
  $Msdomain = $Clientdomains.name | Select-String -Pattern 'onmicrosoft.com' | Select-String -Pattern 'mail' -NotMatch
  $Msdomain = $Msdomain -replace ".onmicrosoft.com",""
  $SPOSite = "https://" + $Msdomain + "-admin.sharepoint.com"
  Connect-SPOService -Url $SPOSite -Credential $UserCredential
  # AzureAD
  # Connect-AzureAD -Credential $UserCredential
}

$Credentials = Get-Credential
Connect-Office365 -UserCredential $Credentials

# modules/1-MailboxAuditing.psm1
Set-MailboxAuditing -Enabled $true

# modules/2-ClientForwardingBlock.psm1
Set-BlockClientForwarding -Enabled $true

# modules/3-NeverExpirePasswords.psm1
Set-NeverExpirePasswords -Enabled $true

# modules/4-AnonymousSharingLinks.psm1
Set-AnonymousSharingLinks -Enabled $true

# modules/5-ExpireSharingLinks.psm1
Set-ExpireSharingLinks -Enabled $true -Days 14

# modules/6-AuditLogIngestion.psm1
Set-AuditLogIngestion -Enabled $true

# modules/7-AnonymousCalendarSharing.psm1
Set-AnonymousCalendarSharing -Enabled $true

# modules/8-SharepointVersioning.psm1
Set-SharepointVersioning -Enabled $true -UserCredential $Credentials

# modules/9-SharepointIRMPolicies.psm1
Set-SharepointIRMPolicies -Enabled $true -UserCredential $Credentials -PolicyName "My IRM Policy"

# modules/10-ProvisionOneDrive.psm1
Set-ProvisionOneDrive -Enabled $true

# modules/11-DataLossPrevention.psm1
#Set-DataLossPrevention -Enabled $true -TemplateName "Canada Financial Data"

# modules/12-AdvancedThreatProtection.psm1
Set-AdvancedThreatProtection -Enabled $true

# modules/13-DisableUserConsent.psm1
# Set-DisableUserConsent -Enabled $true

Exit-Pssession
Write-Host 'Base SecureScore Configuration Is Now Completed' -ForegroundColor Green
