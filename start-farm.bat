@echo off
rem ============================================================================
rem  Farming game untuk badge Discord.
rem  copyright by: jaune
rem
rem  Secara default script akan MENANYAKAN berapa game yang mau difarm DAN
rem  berapa lama tiap game, tepat sebelum mulai. Tekan Enter untuk memakai
rem  nilai default (GAME_COUNT / SECONDS di bawah).
rem
rem  Atur di bawah:
rem    ASK_COUNT      = 1 tanya jumlah & durasi saat dijalankan (default)
rem                     0 pakai GAME_COUNT & SECONDS di bawah tanpa bertanya
rem    GAME_COUNT     = jumlah game (dipakai sebagai default / saat ASK_COUNT=0)
rem    SECONDS        = durasi per game dalam detik (default / saat ASK_COUNT=0)
rem    PAKAI_FILE     = 1 pakai daftar sendiri dari games.txt, 0 = daftar bawaan
rem    IGNORE_HISTORY = 0 hanya farm game yang BELUM pernah dimainkan (default)
rem                     1 farm ulang game yang sudah ada di riwayat
rem    IN_ORDER       = 0 urutan acak (default), 1 urutan sesuai daftar
rem
rem  Selama farming: tekan [S] untuk melewati game yang sedang berjalan.
rem ============================================================================

set "ASK_COUNT=1"
set "GAME_COUNT=100"
set "SECONDS=45"
set "PAKAI_FILE=0"
set "IGNORE_HISTORY=0"
set "IN_ORDER=0"

set "ARGS="
if "%ASK_COUNT%"=="1"      set "ARGS=%ARGS% -Ask"
if not "%ASK_COUNT%"=="1" if not "%GAME_COUNT%"=="0" set "ARGS=%ARGS% -GameCount %GAME_COUNT%"
if not "%SECONDS%"=="0"    set "ARGS=%ARGS% -SecondsPerGame %SECONDS%"
if "%IGNORE_HISTORY%"=="1" set "ARGS=%ARGS% -IgnoreHistory"
if "%IN_ORDER%"=="1"       set "ARGS=%ARGS% -InOrder"

if "%PAKAI_FILE%"=="1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0discord-badge-farm.ps1" %ARGS% -GamesFile "%~dp0games.txt"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0discord-badge-farm.ps1" %ARGS%
)
pause
