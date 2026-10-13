@echo off
rem Opens PowerShell as administrator (Windows asks Yes/No). Read fix-ssh-network.ps1 first: it changes the network profile.
powershell.exe -NoProfile -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0fix-ssh-network.ps1\"'"
