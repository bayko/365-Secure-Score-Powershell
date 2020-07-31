
<#
 .Description
  Enabled versioning on every sharepoint library in the tenant account

 .Parameter Enabled
  False by default, pass true to enable audit log ingestion
  
 .Example
  Set-SharepointVersioning -Enabled $true -UserCredential $UserCredential
#>

function Set-SharepointVersioning {
  param(
    [bool]$Enabled = $false,
    [System.Management.Automation.PSCredential]$UserCredential
  )
  if ($Enabled) {
    $Sites = Get-SPOSite | Select-Object Url
    foreach ($Site in $Sites) {
      try{
        Write-Host "Sharepoint Site:" $Site.Url -ForegroundColor Green
        $pw = $UserCredential.Password | ConvertFrom-SecureString
        $Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site.Url)
        $Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserCredential.Username, $pw)
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
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-SharepointVersioning