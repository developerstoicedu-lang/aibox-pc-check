# Read-only: why can't another computer connect to this one over SSH? Changes nothing.
# Shown on screen and saved to the Desktop as aibox-ssh-status.txt.
$ErrorActionPreference = 'SilentlyContinue'
$out = New-Object System.Collections.Generic.List[string]
function Say($k, $v) { $line = ('{0,-34} {1}' -f $k, $v); $out.Add($line); Write-Host $line }
function Head($t) { $out.Add(''); $out.Add("== $t"); Write-Host ''; Write-Host "== $t" -ForegroundColor Cyan }

Head 'The service'
$s = Get-Service sshd
Say 'sshd' $(if ($s) { "$($s.Status), start type $($s.StartType)" } else { 'NOT INSTALLED' })
$l = Get-NetTCPConnection -LocalPort 22 -State Listen
Say 'Listening on port 22' $(if ($l) { ($l | ForEach-Object { $_.LocalAddress }) -join ', ' } else { 'NO' })
Say 'sshd_config exists' (Test-Path "$env:ProgramData\ssh\sshd_config")
$k = "$env:ProgramData\ssh\administrators_authorized_keys"
Say 'administrators_authorized_keys' $(if (Test-Path $k) { "$((Get-Content $k | Measure-Object).Count) key line(s); starts with: " + ((Get-Content $k | Select-Object -First 1) -split ' ')[0] } else { 'missing' })

Head 'The network'
foreach ($p in Get-NetConnectionProfile) { Say "Network $($p.InterfaceAlias)" $p.NetworkCategory }
Say 'IPv4' ((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' -and $_.InterfaceAlias -notmatch 'vEthernet|WSL|Loopback' } | ForEach-Object { "$($_.IPAddress) ($($_.InterfaceAlias))" }) -join ', ')

Head 'Windows Firewall'
foreach ($p in Get-NetFirewallProfile) { Say "Profile $($p.Name)" "enabled=$($p.Enabled), default inbound=$($p.DefaultInboundAction)" }
foreach ($r in Get-NetFirewallRule -DisplayName '*ssh*') {
    $port = ($r | Get-NetFirewallPortFilter).LocalPort
    Say "Rule $($r.DisplayName)" "enabled=$($r.Enabled), profile=$($r.Profile), $($r.Direction), $($r.Action), port=$port"
}
$block = Get-NetFirewallRule -Direction Inbound -Action Block -Enabled True | Where-Object { ($_ | Get-NetFirewallPortFilter).LocalPort -contains '22' }
Say 'Inbound BLOCK rules for port 22' $(if ($block) { ($block | ForEach-Object { $_.DisplayName }) -join '; ' } else { 'none' })

Head 'Other firewalls / security software'
Say 'Antivirus products' ((Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct | ForEach-Object { $_.displayName }) -join ', ')
Say 'Firewall products' ((Get-CimInstance -Namespace root/SecurityCenter2 -ClassName FirewallProduct | ForEach-Object { $_.displayName }) -join ', ')
Say 'Norton services running' ((Get-Service | Where-Object { $_.Status -eq 'Running' -and $_.DisplayName -match 'Norton|Symantec|NortonLifeLock|Gen Digital' } | ForEach-Object { $_.DisplayName }) -join '; ')
Say 'Answers ping from this PC' 'ask the other side; this computer cannot tell'

$out | Set-Content -Encoding UTF8 "$env:USERPROFILE\Desktop\aibox-ssh-status.txt"
Write-Host ''
Write-Host 'Saved to Desktop\aibox-ssh-status.txt. Send me its contents (or the screen).' -ForegroundColor Green
Read-Host 'Press Enter to close'
