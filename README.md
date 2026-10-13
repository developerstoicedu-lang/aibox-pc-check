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

## install-ssh (changes the computer)

`install-ssh.cmd` / `install-ssh.ps1` installs the OpenSSH server and sets the network to Private. It asks you to
paste one public key and lets only that key log in to administrator accounts (empty = none). Read
`install-ssh.ps1` first: the top lines say what it does and how to undo it. Download both files into one folder,
double-click `install-ssh.cmd`, press **Yes**, paste the key when asked.

## check-ssh-status (read-only)

After `install-ssh`, if the other computer still cannot connect: `check-ssh-status.cmd` shows whether sshd runs
and listens, the network profile, the Windows Firewall rules for SSH and any security software with its own
firewall (Norton and the like). It changes nothing and saves `aibox-ssh-status.txt` on the Desktop.
