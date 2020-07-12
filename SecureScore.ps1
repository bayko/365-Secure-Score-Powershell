# CHECK FOR POWERSHELL PREREQUISITES

#########################################################################################

#Requires -RunAsAdministrator

Set-ExecutionPolicy RemoteSigned

if (Get-Module -ListAvailable -Name MSOnline) {
} else {
    Write-Host "Microsoft Online Powershell Module is Missing, Please install before re-running script"
    Exit
}

if (Get-Module -ListAvailable -Name Microsoft.Online.Sharepoint.Powershell) {
} else {
    Write-Host "Sharepoint Online Powershell Module is Missing, please install before re-running script"
    Exit
}

# DESCRIPTION

#########################################################################################

Write-Host '                  
 
This Script will set a base level SecureScore on 365 Tenant based on the available licensing SKUs.

The following changes will be applied:

All Tenants (+ 60 Points Total) (+55 Not Scored)

- Enable mailbox auditing for all mailboxes - 10 Points
- Set 365 account passwords to never expire - 10 Points
- Allow anonymous guest sharing links for sites and docs - 1 Point
- Create DLP policies - 20 Points
- Set Expiry time in days for external sharing links  -  2 Points
- Provision Onedrive Sites for all users - 10 Points
- Setup Versioning on Sharepoint Online Document Libraries - 2 Points
- Enable IRM Protection on Sharepoint Document Libraries - 5 Points
- Create transport rule for client auto forwarding rule block - 20 Points [not scored]
- Enable 365 Audit Data Recording - 15 Points [not scored]
- Disable Anonymous Calendar Sharing  - 10 Points [not scored]

ATP Licensed Tenants Only (+ 30 Points Additional)

- Enable Advanced Threat Protection safe links policy - 15 Points
- Enable Advanced Threat Protection safe attachments policy - 15 Points
 

Please pick option to continue

1 - Start Configuration
2 - Exit without making any changes

'

$Installmethod = Read-Host 'Please enter number 1 or 2 to select desired option'
if ($Installmethod -contains "1" ) {
  Write-Host 'Starting Script..';
} elseif ($Installmethod -contains "2" ) {
    Write-Host 'Exiting Script..'
    Exit
}  else {
    Write-Host 'Invalid selection. Exiting Script'
    Exit
}


# CONNECT TO 365 SERVICES

#########################################################################################

Write-Host '********************************'

$UserCredential = Get-Credential

Write-Host 'Connecting to MSOL';
connect-msolservice -Credential $UserCredential

Write-Host 'Connecting to EAC';
$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
  -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
  -Credential $UserCredential -Authentication Basic -AllowRedirection;  
Import-PSSession $Session;

Write-Host 'Connecting to SPO'
$Clientdomains = get-msoldomain | Select-Object Name
$Msdomain = $Clientdomains.name | Select-String -Pattern 'onmicrosoft.com' | Select-String -Pattern 'mail' -NotMatch
$Msdomain = $Msdomain -replace ".onmicrosoft.com",""
$SPOSite = "https://" + $Msdomain + "-admin.sharepoint.com"
Connect-SPOService -Url $SPOSite -Credential $UserCredential


## START SECURE SCORE BASIC CONFIGURATION ##

#########################################################################################
Write-Host '********************************'
Write-Host 'Starting Base Configuration'
Write-Host '********************************'

# Enable mailbox auditing for all mailboxes - 10 Points
Write-Host 'Enabling Mailbox Auditing for all Mailboxes - 10 Points'
$Audited = Get-Mailbox -ResultSize Unlimited -Filter {AuditEnabled -eq $false}
if ($Audited.Count -eq "0") {
  Write-Host '***Auditing is already enabled on all mailboxes'
} else {
  $Audited | Set-Mailbox `
    -AuditEnabled $true `
    -AuditLogAgeLimit 180 `
    -AuditAdmin Update, MoveToDeletedItems, SoftDelete,HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission `
    -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf `
    -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems 
  Write-Host '***Auditing now enabled'
  }

# Create transport rule for client auto forwarding block - 20 Points
Write-Host 'Creating Transport Rule for Blocking client rules auto forwarding - 20 Points';
$Clientrules = Get-TransportRule | Select Name
if ($Clientrules.Name -Like "Client Rules Forwarding Block") {
  Write-Host '***Client Rules Forwarding Block Already Exists'
} else {
    New-TransportRule "Client Rules Forwarding Block" `
      -FromScope "InOrganization" `
      -MessageTypeMatches "AutoForward" `
      -SentToScope "NotInOrganization" `
      -RejectMessageReasonText "External Email Forwarding via Client Rules is not permitted"
    Write-Host '***Client Rules Forwarding Block has now been created'
  }

# Set 365 account passwords to never expire - 10 Points
Write-Host 'Setting all 365 user passwords to Never Expire - 10 Points'
$Userexpire = Get-MSOLUser | Where-Object {$_.PasswordNeverExpires -eq $false}
if ($Userexpire.Count -eq "0") {
  Write-Host '***All user passwords are already set to never expire'
} else {
  $Userexpire | Set-MSOLUser -PasswordNeverExpires $true
  Write-Host '***All user passwords are now set to never expire'
  }

# Allow anonymous guest sharing links for sites and docs - 1 Point
Write-Host 'Allowing anonymous guest sharing links on Sharepoint Sites - 1 Point'
$sites = Get-sposite -template GROUP
Foreach($site in $sites)
{
Set-SPOSite -Identity $site.Url -SharingCapability ExternalUserAndGuestSharing;
}
Write-Host '***Anonymous guest sharing links are now enabled';

# Set Expiry time for external sharing links  -  2 Points
Write-Host 'Setting expiration time for external sharing links - 2 Points'
$Spolinks = Get-SpoTenant 
if ($Spolinks.RequireAnonymousLinksExpireInDays -gt "0") {
  Write-Host '***External sharing links are already set to expire after a time'
} else {
  $expirationinDays = 14;
  Set-SpoTenant -RequireAnonymousLinksExpireInDays $expirationinDays;
  Write-Host '***External sharing links now set to expire'
  }

# Enable 365 Audit Data Recording - 15 Points [not scored]
Write-Host 'Enabling Office365 Auditing Data Injestion - 15 Points'
$Auditdata = Get-AdminAuditLogConfig
if ($Auditdata.UnifiedAuditLogIngestionEnabled -eq $true) {
  Write-Host '***Audit Data Ingestion is Already Enabled'
} else {
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true;
    Write-Host '***Audit Data Ingestion is now Enabled'
  }

# Disable Anonymous Calendar Sharing - 10 Points [not scored]
Write-Host 'Disabling anonymous calendar sharing by default - 10 Points'
$Calendars = get-sharingpolicy -identity "Default Sharing Policy"
$Calendars = $Calendars.Domains
if ($Calendars -contains 'Anonymous:CalendarSharingFreeBusyReviewer')  { 
  Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusyReviewer'}  
  Write-Host '***Anonymous Calendar Sharing Has Now Been Disabled'
  
} elseif ($Calendars -contains 'Anonymous:CalendarSharingFreeBusySimple')  {
    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusySimple'}  
    Write-Host '***Anonymous Calendar Sharing Has Now Been Disabled'

} elseif ($Calendars -contains 'Anonymous:CalendarSharingFreeBusyDetail')  {
    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusyDetail'}  
    Write-Host '***Anonymous Calendar Sharing Has Now Been Disabled'

} else {
  Write-Host '***Anonymous Calendar Sharing Is Already Disabled'
}
Write-Host '********************************'

Write-Host 'Enabling Versioning on Sharepoint Libraries' -foregroundcolor Green
$Sites = Get-SPOSite | Select-Object Url
foreach ($Site in $Sites) {
    try{
        Write-Host "Sharepoint Site:" $Site.Url
        $Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site.Url)
        $Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Usercredential)
        $Context.Credentials = $Creds
        $Web = $Context.Web
        $Context.Load($Web)
        $Context.load($Web.lists)
        $Context.executeQuery()
        foreach($List in $Web.lists) {
            if (($List.hidden -eq $false) -and ($List.Title -notmatch "Style Library")) {
                $List.EnableVersioning = $true
                $LiST.MajorVersionLimit = 50
                $List.Update()
                $Context.ExecuteQuery() 
                Write-host "Versioning has been turned ON for :" $List.title -foregroundcolor Green
            }
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
}

# Enable IRM Policy on Primary Sharepoint Site Document Library
Write-Host 'Enabling IRM Policy on Sharepoint Documents Library'
try{
    $ShareSite = "https://" + $Msdomain + ".sharepoint.com"
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($ShareSite)
    $Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$SecureStringPwd)
    $Context.Credentials = $Creds
    $Lists = $Context.Web.Lists
    $Context.Load($Lists)
    $Context.ExecuteQuery()
    $List = $Lists.GetByTitle("Documents")
    $Context.Load($List)
    $Context.ExecuteQuery()
    $List.IrmEnabled = $true
    $List.InformationRightsManagementSettings.PolicyDescription = "STS IRM Policy"
    $List.InformationRightsManagementSettings.PolicyTitle = "STS IRM Policy"
    $List.InformationRightsManagementSettings.AllowPrint = $true
    $List.InformationRightsManagementSettings.AllowWriteCopy = $true
    $List.InformationRightsManagementSettings.DocumentAccessExpireDays = 14
    $List.InformationRightsManagementSettings.EnableDocumentAccessExpire = $true
    $List.InformationRightsManagementSettings.EnableDocumentBrowserPublishingView = $true
    $List.Update()
    $Context.ExecuteQuery()
    $List.InformationRightsManagementSettings
}
catch{
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

# Pre-provision Onedrive Storage for all licensed accounts
Write-Host 'Pre-Provisioning Onedrive for all licensed users'
$OneDriveUsers = Get-MSOLUser -All | Select-Object UserPrincipalName,islicensed | Where-Object {$_.islicensed -eq "True"}
Request-SPOPersonalSite -UserEmails $OneDriveUsers.UserPrincipalName -NoWait


# Create DLP policies - 20 Points
Write-Host 'Creating Data Loss Prevention Policies from Templates'
$Clientdlp = Get-DlpPolicy
if ($Clientdlp.Name -Like "Australia Financial Data") {
    Write-Host '***DLP for Australia Financial Data Already Exists'
} else {
    New-DlpPolicy -Name "Australia Financial Data" -Mode AuditAndNotify -Template 'Australia Financial Data';
    Remove-TransportRule -Identity "Australia Financial: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "Australia Financial: Attachment not supported" -Confirm:$false
    Write-Host '***Added DLP for Australia Financial Data'
}
if ($Clientdlp.Name -Like "Australia Health Records Act (HRIP Act)") {
    Write-Host '***DLP for Australia Health Records Act (HRIP Act) Already Exists'
} else {
    New-DlpPolicy -Name "Australia Health Records Act (HRIP Act)" -Mode AuditAndNotify -Template 'Australia Health Records Act (HRIP Act)'
    Remove-TransportRule -Identity "Australia HRIP: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "Australia HRIP: Attachment not supported" -Confirm:$false
    Write-Host '***Added DLP for Australia Health Records Act (HRIP Act)'
}
if ($Clientdlp.Name -Like "Australia Privacy Act") {
    Write-Host '***DLP for Australia Privacy Act Already Exists'
} else {
    New-DlpPolicy -Name "Australia Privacy Act" -Mode AuditAndNotify -Template "Australia Privacy Act"
    Remove-TransportRule -Identity "Australia Privacy: Scan text limit exceeded: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "Australia Privacy: Attachment not supported" -Confirm:$false
    Write-Host '***Added DLP for Australia Privacy Act'



## CHECK FOR ATP LICENSING AND APPLY ADDITIONAL SECURESCORE CONFIG ##

#########################################################################################
$Licensing = Get-MsolSubscription
if ($Licensing.SkuPartNumber -contains 'ATP_ENTERPRISE' ) {

  Write-Host 'Advanced Threat Protection Licensing Detected'
  Write-Host '********************************'
  
  # Enable Advanced Threat Protection safe links policy - 15 Points
  Write-Host 'Enabling ATP Safe Links Policy - 15 Points'
  $Safelinks = Get-SafeLinksPolicy
  if ($Safelinks.Enabled -eq $true) {
    Write-Host '***ATP Safe links Policy Already Enabled'
} elseif ($Safelinks.count -eq "0") {
    $Maildomains = get-msoldomain | Select-Object Name
    $Domains = $Maildomains.name;
    New-SafeLinksPolicy -Name 'Safe Links' -AdminDisplayName $null -IsEnabled:$true -AllowClickThrough:$false -TrackClicks:$false
    New-SafeLinksRule -Name 'Safe Links' -SafeLinksPolicy 'Safe Links' -RecipientDomainIs @($Domains)
    Write-Host '***ATP Safe links is now Enabled'
} else {
    Get-SafeLinksPolicy | Set-SafeLinksPolicy -Enabled $true
    Write-Host '***ATP Safe links is now Enabled'
  }
      
  # Enable Advanced Threat Protection safe attachments policy - 15 Points
  Write-Host 'Enabling ATP Safe Attachments Policy - 15 Points'
  $Safeattachments = Get-SafeAttachmentPolicy
  if ($Safeattachments.Enable -eq $true) {
    Write-Host '***ATP Safe Attachment Policy Already Enabled'
  } elseif ($Safelattachments.count -eq "0") {
      $Maildomains = get-msoldomain | Select-Object Name
      $Domains = $Maildomains.name;
      New-SafeAttachmentPolicy "Safe Attachments" -Enable:$true -Redirect:$false -Action: Block
      New-SafeAttachmentRule "Safe Attachments" -RecipientDomainIs @($Domains) -SafeAttachmentPolicy "Safe Attachments" -Enable:$true
      Write-Host '***ATP Safe Attachment Policy is now Enabled'    
    } else {
      Get-SafeAttachmentPolicy | Set-SafeAttachmentPolicy -Enable $true;
      Write-Host '***ATP Safe Attachment Policy is now Enabled'
    } 
}

if ($Licensing.SkuPartNumber -notcontains 'ATP_ENTERPRISE' ) {
    Write-Host 'No Advanced Threat Licensing Detected - Skipping'
    Write-Host '********************************' 
}

#########################################################################################

Exit-Pssession  

Write-Host 'Base SecureScore Configuration Is Now Completed'
