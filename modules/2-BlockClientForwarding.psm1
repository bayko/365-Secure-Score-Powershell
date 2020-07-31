<#
 .Synopsis
  Prevent users from creating mailbox forwarding rules

 .Description
  Create an EAC transport rule that automatically blocks any outgoing message sent via a client mailbox rule

 .Parameter Enabled
  False by default, pass true to create the rule

 .Example
   Set-BlockClientForwarding -Enabled $true

#>
function Set-BlockClientForwarding {
  param(
    [bool]$Enabled = $false
  )
  if ($Enabled) {
    $Clientrules = Get-TransportRule | Select-Object Name
    if ($Clientrules.Name -Like "Client Rules Forwarding Block") {
      Write-Host '***Client Rules Forwarding Block Already Exists' -ForegroundColor Blue
    } else {
        New-TransportRule "Client Rules Forwarding Block" `
        -FromScope "InOrganization" `
        -MessageTypeMatches "AutoForward" `
        -SentToScope "NotInOrganization" `
        -RejectMessageReasonText "External Email Forwarding via Client Rules is not permitted"
        Write-Host '***Client Rules Forwarding Block has now been created' -ForegroundColor Green
    }
  } else {
    Write-Host "You must provide a true boolean value for Enabled when executing cmdlet" -ForegroundColor Red
  }
}
Export-ModuleMember -Function Set-BlockClientForwarding
