
<#
 .Description
  Creates an exchange DataLoss Prevention policy based on a template

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
  Set-DataLossPrevention -Enabled $true -TemplateName "Canada Financial Data"
#>

function Set-DataLossPrevention {
  param(
    [bool]$Enabled = $false,
    [string]$TemplateName = "Canada Financial Data"
  )
  if ($Enabled) {
    $Clientdlp = Get-DlpPolicy
    if ($Clientdlp.Name -Like $TemplateName) {
        Write-Host "***DLP for $($TemplateName) Already Exists" -ForegroundColor Blue
    } else {
        New-DlpPolicy -Name $TemplateName -Mode AuditAndNotify -Template $TemplateName;
        Write-Host "***Added DLP for $($TemplateName)" -ForegroundColor Green
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing command)" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-DataLossPrevention