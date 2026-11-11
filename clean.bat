@echo off
rem Matikan semua proses dummy yang tersisa dan hapus folder kerja.
rem copyright by: jaune
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0discord-badge-farm.ps1" -Clean
pause
