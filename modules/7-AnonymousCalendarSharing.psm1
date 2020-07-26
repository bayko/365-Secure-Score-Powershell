
<#
 .Description
  Disable anonymous calendar sharing feature for 365 calendars

 .Parameter Enabled
  False by default, pass true to enable audit log ingestion
  
 .Example
  Set-AnonymousCalendarSharing -Enabled $true
#>

function Set-AnonymousCalendarSharing {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $Calendars = Get-SharingPolicy -identity "Default Sharing Policy"
    $Calendars = $Calendars.Domains
    if ($Calendars -contains 'Anonymous:CalendarSharingFreeBusyReviewer')  { 
      Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusyReviewer'}  
      Write-Host '***Anonymous Calendar Sharing Has Now Been Disabled' -ForegroundColor Green
    } elseif ($Calendars -contains 'Anonymous:CalendarSharingFreeBusySimple')  {
      Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusySimple'}  
      Write-Host '***Anonymous Calendar Sharing Has Now Been Disabled' -ForegroundColor Green
    } elseif ($Calendars -contains 'Anonymous:CalendarSharingFreeBusyDetail')  {
      Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusyDetail'}  
      Write-Host '***Anonymous Calendar Sharing Has Now Been Disabled' -ForegroundColor Green
    } else {
      Write-Host '***Anonymous Calendar Sharing Is Already Disabled' -ForegroundColor Blue
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing Set-MailboxAuditing (Set-MailboxAuditing -Enabled $true)" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-AnonymousCalendarSharing