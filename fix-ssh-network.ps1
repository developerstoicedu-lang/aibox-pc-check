# CHANGES THIS COMPUTER. Makes the connected network "Private" and lets inbound SSH (port 22) through the
# Windows Firewall on Private and Domain networks, so another computer on your own network can connect.
# Windows blocks SSH on a "Public" network (a cafe, a hotel): only run this on a network you trust (home, office).
# Undo:  Set-NetConnectionProfile -InterfaceAlias '<name>' -NetworkCategory Public ; Remove-NetFirewallRule -Name 'AIBox-SSH'
$ErrorActionPreference = 'Stop'
$profiles = @(Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' -and $_.IPv4Connectivity -ne 'Disconnected' })
if (-not $profiles) { 'No connected Public network: nothing to change on the profile.' }
foreach ($p in $profiles) {
  "Network '$($p.Name)' on '$($p.InterfaceAlias)' is Public."
  if ((Read-Host 'Is this a network you trust (your home or office)? Make it Private? [y/N]') -match '^[yY]') {
    Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private
    "Set to Private."
  } else { 'Left as Public.' }
}
Remove-NetFirewallRule -Name 'AIBox-SSH' -ErrorAction SilentlyContinue
New-NetFirewallRule -Name 'AIBox-SSH' -DisplayName 'AI Box SSH (port 22)' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Private,Domain | Out-Null
''
Get-NetConnectionProfile | Format-Table Name, InterfaceAlias, NetworkCategory -AutoSize
Get-NetFirewallRule -Name '*ssh*' | Format-Table Name, Enabled, Profile, Action -AutoSize
Read-Host 'Press Enter to close'
