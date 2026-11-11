@echo off
rem ============================================================================
rem  Uji cepat deteksi Discord (45 detik).
rem  Pastikan Discord sudah berjalan dan login, lalu pantau status/profil Anda
rem  - harus muncul "Playing Terraria".
rem
rem  copyright by: jaune
rem ============================================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0discord-badge-farm.ps1" -Games "Terraria.exe" -SecondsPerGame 45
pause
