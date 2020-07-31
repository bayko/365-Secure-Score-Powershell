
<#
 .Description
  Creates or enabled Safe Links and Safe Attachment policies for ATP

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
  Set-AdvancedThreatProtection -Enabled $true
#>
function Set-AdvancedThreatProtection {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $Licensing = Get-MsolSubscription
    if ($Licensing.SkuPartNumber -contains 'ATP_ENTERPRISE' ) {
      $Safelinks = Get-SafeLinksPolicy
      if ($Safelinks.Enabled -eq $true) {
        Write-Host '***ATP Safe links Policy Already Enabled' -ForegroundColor Blue
      } elseif ($Safelinks.count -eq "0") {
        $Maildomains = get-msoldomain | Select-Object Name
        $Domains = $Maildomains.name;
        New-SafeLinksPolicy -Name 'Safe Links' -AdminDisplayName $null -IsEnabled:$true -AllowClickThrough:$false -TrackClicks:$false
        New-SafeLinksRule -Name 'Safe Links' -SafeLinksPolicy 'Safe Links' -RecipientDomainIs @($Domains)
        Write-Host '***ATP Safe links is now Enabled' -ForegroundColor Green
      } else {
        Get-SafeLinksPolicy | Set-SafeLinksPolicy -Enabled $true
        Write-Host '***ATP Safe links is now Enabled' -ForegroundColor Green
      }
      $Safeattachments = Get-SafeAttachmentPolicy
      if ($Safeattachments.Enable -eq $true) {
        Write-Host '***ATP Safe Attachment Policy Already Enabled' -ForegroundColor Blue
      } elseif ($Safelattachments.count -eq "0") {
          $Maildomains = get-msoldomain | Select-Object Name
          $Domains = $Maildomains.name;
          New-SafeAttachmentPolicy "Safe Attachments" -Enable:$true -Redirect:$false -Action: Block
          New-SafeAttachmentRule "Safe Attachments" -RecipientDomainIs @($Domains) -SafeAttachmentPolicy "Safe Attachments" -Enable:$true
          Write-Host '***ATP Safe Attachment Policy is now Enabled' -ForegroundColor Green
        } else {
          Get-SafeAttachmentPolicy | Set-SafeAttachmentPolicy -Enable $true;
          Write-Host '***ATP Safe Attachment Policy is now Enabled' -ForegroundColor Green
        } 
    } else {
      Write-Host 'No Advanced Threat Licensing Detected - Skipping' -ForegroundColor Blue
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-AdvancedThreatProtection