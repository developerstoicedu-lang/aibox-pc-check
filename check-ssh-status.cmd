@echo off
rem Opens PowerShell as administrator (Windows asks Yes/No). It only reads.
powershell.exe -NoProfile -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0check-ssh-status.ps1\"'"
