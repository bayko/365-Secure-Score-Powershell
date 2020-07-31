
<#
 .Description
  Enable Office 365 audit log ingestion

 .Parameter Enabled
  False by default, pass true to enable audit log ingestion
  
 .Example
  Set-AuditLogIngestion -Enabled $true
#>

function Set-AuditLogIngestion {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $Auditdata = Get-AdminAuditLogConfig
    if ($Auditdata.UnifiedAuditLogIngestionEnabled -eq $true) {
      Write-Host '***Audit Log Ingestion is Already Enabled' -ForegroundColor Blue
    } else {
      Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true;
      Write-Host '***Audit Log Ingestion is now Enabled' -ForegroundColor Green
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-AuditLogIngestion