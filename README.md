# aibox-pc-check

A read-only PowerShell check: what this Windows computer is and what is needed to install the OpenSSH
server on it (Windows version, accounts, network, firewall, whether OpenSSH can be installed, blockers).
It changes nothing and sends nothing; it prints the result and saves `aibox-ssh-check.txt` on the Desktop.

## Run

1. Download `check-ssh-prereqs.ps1` and `check-ssh-prereqs.cmd` into the same folder.
2. Double-click `check-ssh-prereqs.cmd` and press **Yes** (it opens PowerShell as administrator so every
   check can run).
3. Send the contents of `aibox-ssh-check.txt`.

Read the script first: it is short.
