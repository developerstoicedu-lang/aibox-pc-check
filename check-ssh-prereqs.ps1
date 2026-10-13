# Read-only: collects what is needed to decide how to install the OpenSSH server on this computer.
# Changes nothing. Shown on screen and saved to the Desktop as aibox-ssh-check.txt (no passwords, no keys).
$ErrorActionPreference = 'SilentlyContinue'
$out = New-Object System.Collections.Generic.List[string]
function Say($k, $v) { $line = ('{0,-34} {1}' -f $k, $v); $out.Add($line); Write-Host $line }
function Head($t) { $out.Add(''); $out.Add("== $t"); Write-Host ''; Write-Host "== $t" -ForegroundColor Cyan }

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$os = Get-CimInstance Win32_OperatingSystem

Head 'This computer'
Say 'Computer name' $env:COMPUTERNAME
Say 'Run as administrator' $admin
if (-not $admin) { Say '' '(some checks below need administrator; they say "needs admin")' }
Say 'Windows' "$($os.Caption), build $($os.BuildNumber), $($os.OSArchitecture)"
Say 'Edition' (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').EditionID
Say 'Domain joined' (Get-CimInstance Win32_ComputerSystem).PartOfDomain
Say 'PowerShell' $PSVersionTable.PSVersion.ToString()
Say 'Accounts that are administrators' ((Get-LocalGroupMember -Group 'Administrators' | ForEach-Object { $_.Name }) -join ', ')
Say 'Signed-in user' ($env:USERDOMAIN + [char]92 + $env:USERNAME)

Head 'OpenSSH: what is installed already'
foreach ($n in 'sshd', 'ssh-agent') {
    $s = Get-Service $n
    Say "Service $n" $(if ($s) { "$($s.Status), start type $($s.StartType)" } else { 'not installed' })
}
Say 'ssh.exe (client)' $(if (Get-Command ssh.exe) { (Get-Command ssh.exe).Source } else { 'not found' })
Say 'sshd.exe' $(if (Test-Path "$env:WINDIR\System32\OpenSSH\sshd.exe") { 'present' } else { 'not present' })
if ($admin) {
    foreach ($c in Get-WindowsCapability -Online -Name 'OpenSSH*') { Say $c.Name $c.State }
} else { Say 'OpenSSH capability state' 'needs admin' }
Say 'Port 22 listening' $(if (Get-NetTCPConnection -LocalPort 22 -State Listen) { 'yes' } else { 'no' })
Say 'C:\ProgramData\ssh' $(if (Test-Path "$env:ProgramData\ssh") { (Get-ChildItem "$env:ProgramData\ssh" | ForEach-Object { $_.Name }) -join ', ' } else { 'does not exist' })
$fw = Get-NetFirewallRule -DisplayName '*ssh*' | ForEach-Object { "$($_.DisplayName) [$($_.Enabled), $($_.Direction), $($_.Action)]" }
Say 'Firewall rules about ssh' $(if ($fw) { $fw -join '; ' } else { 'none' })
Say 'Network profile' ((Get-NetConnectionProfile | ForEach-Object { "$($_.InterfaceAlias)=$($_.NetworkCategory)" }) -join ', ')
Say 'IPv4 address' ((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' -and $_.InterfaceAlias -notmatch 'vEthernet|WSL|Loopback' } | ForEach-Object { $_.IPAddress }) -join ', ')

Head 'How OpenSSH could be installed here'
Say 'winget' $(if (Get-Command winget.exe) { (winget --version) } else { 'not found' })
$pol = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
$wsus = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
Say 'Updates come from a WSUS server' $(if ($pol.UseWUServer -eq 1) { "YES ($($wsus.WUServer)): Add-WindowsCapability may fail" } else { 'no' })
Say 'Optional-feature source policy' $(if ((Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System').RepairContentServerSource) { 'set by policy' } else { 'default' })
Say 'Windows Update service' $(if ($s = Get-Service wuauserv) { "$($s.Status), $($s.StartType)" } else { 'not found' })
Say 'Reach github.com:443' (Test-NetConnection github.com -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)
Say 'Reach download.windowsupdate.com' (Test-NetConnection download.windowsupdate.com -Port 80 -InformationLevel Quiet -WarningAction SilentlyContinue)
Say 'Proxy' $(if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyEnable -eq 1) { 'in use: ' + (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer } else { 'none' })
Say 'Free disk C: (GB)' ([math]::Round((Get-PSDrive C).Free / 1GB, 1))
Say 'Restart pending' $(if ((Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')) { 'YES (restart first)' } else { 'no' })
Say 'PowerShell script policy' ((Get-ExecutionPolicy -List | ForEach-Object { "$($_.Scope)=$($_.ExecutionPolicy)" }) -join ', ')
Say 'Antivirus' ((Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct | ForEach-Object { $_.displayName }) -join ', ')

$out | Set-Content -Encoding UTF8 "$env:USERPROFILE\Desktop\aibox-ssh-check.txt"
Write-Host ''
Write-Host 'Saved to Desktop\aibox-ssh-check.txt. Send me its contents (or the screen).' -ForegroundColor Green
Read-Host 'Press Enter to close'
