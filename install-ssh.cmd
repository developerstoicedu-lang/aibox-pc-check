@echo off
rem Opens PowerShell as administrator (Windows asks Yes/No) and runs install-ssh.ps1 from this folder.
powershell.exe -NoProfile -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0install-ssh.ps1\"'"
