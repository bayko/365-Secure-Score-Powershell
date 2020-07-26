<#
 .Synopsis
  Enables mailbox auditing for all Exchange online mailboxes.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.

 .Parameter Enabled
  False by default, pass true to enable mailbox auditing

 .Example
   Set-MailboxAuditing -Enabled $true

#>
function Set-MailboxAuditing {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $Audited = Get-Mailbox -ResultSize Unlimited -Filter {AuditEnabled -eq $false}
    if ($Audited.Count -eq "0") {
      Write-Host '***Auditing is already enabled on all mailboxes' -ForegroundColor Blue
    } else {
      $Audited | Set-Mailbox `
        -AuditEnabled $true `
        -AuditLogAgeLimit 180 `
        -AuditAdmin Update, MoveToDeletedItems, SoftDelete,HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission `
        -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf `
        -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems 
      Write-Host '***MailboxAuditing has now enabled' -ForegroundColor Green
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing Set-MailboxAuditing (Set-MailboxAuditing -Enabled $true)" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-MailboxAuditing
