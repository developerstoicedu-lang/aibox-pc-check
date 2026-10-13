# Installs the OpenSSH server on this Windows computer. Run as administrator. It changes this computer:
#   1. adds the "OpenSSH Server" Windows feature and starts the sshd service (it starts with Windows)
#   2. sets the network profile to Private so the firewall rule for SSH (port 22) applies
#   3. ASKS you to paste ONE public key (a line starting "ssh-ed25519" or "ssh-rsa") and lets that key log in to
#      administrator accounts. Nothing is allowed unless you paste a key; leave it empty to allow none.
# To undo: Stop-Service sshd; Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
#          and delete C:\ProgramData\ssh\administrators_authorized_keys.
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Run this as administrator (right-click PowerShell > Run as administrator).' -ForegroundColor Red
    Read-Host 'Press Enter to close'; exit 1
}
if ((Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')) {
    Write-Host 'A restart is pending. Restart Windows first, then run this again.' -ForegroundColor Yellow
    Read-Host 'Press Enter to close'; exit 1
}
$key = Read-Host 'Paste the public key to allow (one line, starts with ssh-ed25519), or press Enter to allow none'
$key = $key.Trim()
if ($key -ne '' -and $key -notmatch '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp\d+) [A-Za-z0-9+/=]+( .*)?$') {
    Write-Host 'That does not look like a public key. Nothing was changed.' -ForegroundColor Red
    Read-Host 'Press Enter to close'; exit 1
}
if ((Get-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0).State -ne 'Installed') {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null
}
Set-Service sshd -StartupType Automatic
Start-Service sshd
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
if ($key -ne '') {
    $f = Join-Path $env:ProgramData 'ssh\administrators_authorized_keys'
    if (-not (Test-Path $f) -or -not (Select-String -Path $f -SimpleMatch $key -Quiet)) { Add-Content -Path $f -Value $key }
    icacls $f /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null
}
Write-Host ''
Get-Service sshd | Format-Table Status, StartType, Name -AutoSize
Write-Host ('Address: ' + ((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127|169\.254)\.' -and $_.InterfaceAlias -notmatch 'vEthernet|WSL|Loopback' } | ForEach-Object { $_.IPAddress }) -join ', ') + '   User: ' + $env:USERNAME)
Write-Host 'Done.' -ForegroundColor Green
Read-Host 'Press Enter to close'
