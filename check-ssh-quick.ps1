# Read-only: is the SSH server running, is anything listening on port 22, and is the network Private?
# Changes nothing, sends nothing. Saves the result as aibox-ssh-quick.txt on the Desktop.
$out = Join-Path ([Environment]::GetFolderPath('Desktop')) 'aibox-ssh-quick.txt'
$r = & {
  "== Get-Service sshd";                                      Get-Service sshd -ErrorAction Continue | Format-Table -AutoSize | Out-String
  "== Get-NetTCPConnection -LocalPort 22 -State Listen";     Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction Continue | Format-Table -AutoSize | Out-String
  "== Get-NetConnectionProfile";                              Get-NetConnectionProfile | Format-Table Name, InterfaceAlias, NetworkCategory -AutoSize | Out-String
  "== IPv4";                                                  (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' }).IPAddress
} *>&1 | Out-String
$r | Tee-Object -FilePath $out
"Saved to $out"
Read-Host 'Press Enter to close'
