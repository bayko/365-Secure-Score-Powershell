
<#
 .Description
  Enabled IRM policy for sharepoint document libraries

 .Parameter Enabled
  False by default, pass true to enable audit log ingestion
  
 .Example
  Set-SharepointIRMPolicies -Enabled $true -UserCredential $UserCredential -PolicyName "My Policy Name"
#>

function Set-SharepointIRMPolicies {
  param(
    [bool]$Enabled = $false,
    [System.Management.Automation.PSCredential]$UserCredential,
    [string]$PolicyName = 'My IRM Policy'
  )
  if ($Enabled) {
    $Sites = Get-SPOSite | Select-Object Url
    foreach ($Site in $Sites) {
      try{
        if (($Site.Url -notlike "*-my.*") -and ($Site.Url -notlike "*/portals/*") -and ($Site.Url -notlike "*/search")) {
          Write-Host "Sharepoint Site:" $Site.Url -ForegroundColor Green
          $Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site.Url)
          $Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserCredential.UserName, $UserCredential.Password)
          $Context.Credentials = $Creds
          $Lists = $Context.Web.Lists
          $Context.Load($Lists)
          $Context.ExecuteQuery()
          $List = $Lists.GetByTitle("Documents")
          $Context.Load($List)
          $Context.ExecuteQuery()
          $List.IrmEnabled = $true
          $List.InformationRightsManagementSettings.PolicyDescription = $PolicyName
          $List.InformationRightsManagementSettings.PolicyTitle = $PolicyName
          $List.InformationRightsManagementSettings.AllowPrint = $true
          $List.InformationRightsManagementSettings.AllowWriteCopy = $true
          $List.InformationRightsManagementSettings.DocumentAccessExpireDays = 14
          $List.InformationRightsManagementSettings.EnableDocumentAccessExpire = $true
          $List.InformationRightsManagementSettings.EnableDocumentBrowserPublishingView = $true
          $List.Update()
          $Context.ExecuteQuery()
          $List.InformationRightsManagementSettings
        }
      } catch {
          Write-Host "Error: $($_.Exception.Message)" -foregroundcolor Red
      }
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing Set-MailboxAuditing (Set-MailboxAuditing -Enabled $true)" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-SharepointIRMPolicies