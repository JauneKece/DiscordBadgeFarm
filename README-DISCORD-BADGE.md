# Discord Badge Farmer (Game Time & Game Variety)

**copyright by: jaune**

Script PowerShell untuk farming badge aktivitas Discord **Game Time** (total jam
bermain) dan **Game Variety** (jumlah game unik) dengan cara *process-name spoofing*.

## Cara kerja (singkat)

Aplikasi Discord desktop mendeteksi game yang sedang Anda mainkan dengan **memindai
nama proses (file `.exe`)** yang berjalan dan mencocokkannya dengan database game
internalnya. Jam bermain & jumlah game di profil dihitung dari deteksi itu.

Script ini membuat **proses dummy yang hanya tidur (CPU +-0%)** tetapi nama filenya
disamakan dengan nama `.exe` game populer, sehingga Discord menganggap Anda sedang
bermain game tersebut. Rotasi antar game dilakukan otomatis untuk badge Game Variety.

## Status tiap badge - jujur & jangan tertipu

| Badge | Bisa dimanipulasi? | Keterangan |
|---|---|---|
| **Game Time** | Ya | Difarm dengan script ini |
| **Game Variety** | Ya | Rotasi daftar game di script |
| **Streaming** | Terbatas | Harus ada sesi stream sungguhan (Go Live / share screen) - lihat bagian bawah |
| **Account Age** | **Mustahil** | Umur akun tersimpan di server Discord sesuai tanggal akun dibuat. Tool/jasa/script apa pun yang mengaku bisa mengubahnya = **penipuan atau malware**. Jangan pernah memberikan token Anda |

## Persyaratan

1. Windows + Windows PowerShell bawaan (`powershell.exe`, bukan pwsh).
2. **Discord desktop berjalan dan sudah login** selama farming berlangsung.
3. Discord, Settings, **Activity Privacy**: pastikan berbagi aktivitas terdeteksi aktif
   (agar jam main tercatat ke profil).
4. PC tidak boleh tidur/hibernate selama farming (atur *Power & sleep* ke Never).
5. Antivirus tidak perlu dimatikan - script hanya membuat proses lokal biasa.

## Cara pakai

Buka Command Prompt / PowerShell di folder ini:

```bat
:: 0) Menu interaktif (paling ramah - tinggal pilih nomor):
menu.bat

:: 1) Uji cepat (45 detik) - pastikan Discord terbuka, lalu pantau profil/status Anda:
test.bat

:: 2) Farming 100 game, 45 detik per game (+- 1 jam 15 menit):
start-farm.bat

:: 3) Atau langsung dari PowerShell, atur sendiri:
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -GameCount 100 -SecondsPerGame 45

:: 4) Daftar game sendiri (satu .exe per baris di games.txt):
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -GamesFile .\games.txt -SecondsPerGame 30

:: 5) Lihat dulu rencananya tanpa menjalankan apa pun:
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -GameCount 100 -Preview

:: 6) Lihat semua nama game yang tersedia (200 nama):
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -ListGames

:: 7) Berhenti total & bersih-bersih:
clean.bat
```

### Tampilan

- Banner + kotak ringkasan berwarna, daftar game rapi, dan **progress bar** dengan
  hitung mundur per game serta persentase keseluruhan.
- `menu.bat` membuka menu interaktif: mulai farming, preview, riwayat, hapus
  riwayat, daftar game, bersih-bersih, keluar.
- Konfirmasi `Mulai sekarang? [Y/n]` muncul setelah jumlah game dipilih.
- Kalau console Anda menampilkan karakter kotak sebagai simbol aneh, tambahkan
  `-Ascii` (tampilan tetap rapi dengan `+ - | #`).

### Opsi penting

| Opsi | Arti |
|---|---|
| `-Ask` | **Tanya jumlah game + durasi per game sebelum farming dimulai.** Enter = default. |
| `-GameCount 100` | Farm 100 game tanpa bertanya (dihitung setelah game lama dilewati). `0`/tanpa opsi = semua. |
| `-SecondsPerGame 45` | Durasi per game dalam **detik** (default; bisa `-Ask`). |
| `-HoursPerGame 0.02` | Alternatif: durasi per game dalam jam. |
| `-InOrder` | Jangan acak urutan (**default: acak**). |
| `-SkipGames "a.exe,b.exe"` | Lewati game tertentu. |
| `-SkipFile .\skip.txt` | Lewati game yang tercantum di file (satu per baris). |
| `-IgnoreHistory` | Farm ulang game yang sudah pernah dimainkan. |
| `-ShowHistory` | Tampilkan game yang sudah pernah difarm. |
| `-ResetHistory` | Hapus riwayat "sudah dimainkan". |
| `-GamesFile .\games.txt` | Pakai daftar sendiri; hanya isi file itu yang difarm. |
| `-Games "a.exe,b.exe"` | Pilih game langsung dari command line. |
| `-Preview` | Tampilkan rencana + estimasi total waktu, tanpa menjalankan proses. |
| `-ListGames` | Tampilkan semua nama game yang dikenali daftar bawaan. |
| `-Ascii` | Tampilan ASCII sederhana (kalau karakter kotak di console Anda rusak). |
| `-Hidden` | Mode lama tanpa window (sering tidak terdeteksi; default sekarang terlihat). |

## Menentukan jumlah game sebelum mulai

Dua cara:

1. **Interaktif (paling gampang).** Jalankan `start-farm.bat`, lalu script bertanya:
   ```text
   Game siap difarm: 88.
   Berapa game yang mau difarm? [1-88, default 88]:
   ```
   Ketik angka, atau tekan **Enter** untuk memakai semua yang tersedia. Angka yang
   lebih besar dari jumlah tersedia otomatis dibatasi, dan input bukan angka akan
   ditanya ulang. Di PowerShell bisa juga: `... -Ask`.
2. **Langsung di parameter.** `-GameCount 25` tanpa pertanyaan (bagus untuk
   otomatisasi / shortcut sendiri).

## Mengatur durasi tiap game

Tiga cara, dari yang paling gampang:

1. **Interaktif.** Setelah jumlah game, `start-farm.bat` (mode `-Ask`) menanyakan:
   ```text
   Durasi per game sekarang: 45 dtk.
   Berapa lama tiap game? [default 45 dtk; contoh: 30 / 45s / 2m / 1m30s]:
   ```
   Format yang diterima: `30` (detik), `45s`, `2m`, `1m30s`, `0.5h`. Tekan **Enter**
   untuk memakai default. Nilai di bawah 5 detik ditolak agar sempat terdeteksi.
2. **Lewat parameter.**
   ```powershell
   ... -SecondsPerGame 60          # 60 detik per game
   ... -SecondsPerGame 90          # 1,5 menit
   ... -HoursPerGame 0.5           # 30 menit
   ```
3. **Durasi berbeda untuk tiap game** lewat `-GamesFile` (kolom kedua, dipisah `|`):
   ```text
   Terraria.exe | 45
   Stardew Valley.exe | 2m | Stardew Valley
   Celeste.exe | 1m30s
   hl2p.exe
   ```
   Game tanpa kolom durasi memakai `-SecondsPerGame`/`-HoursPerGame`. Ringkasan akan
   menampilkan `campuran (45 dtk s/d 2 mnt)` bila durasinya tidak seragam, dan estimasi
   total dihitung dari durasi sebenarnya.


## Skip game & riwayat "sudah dimainkan"

Badge **Game Variety** hanya menghitung game **unik**. Karena itu, menjalankan ulang
game yang sama tidak menambah variasi apa pun - hanya membuang waktu. Script ini
membantu dengan tiga cara:

1. **Riwayat otomatis.** Setiap game yang selesai difarm dicatat ke
   `%LOCALAPPDATA%\DiscordBadgeFarm\played.txt`. Pada eksekusi berikutnya, game itu
   dilewati otomatis, jadi setiap kali `start-farm.bat` dijalankan Anda langsung
   menggarap game **baru**. Tidak perlu setting apa pun.
2. **Skip manual.** `-SkipGames "Terraria.exe"` atau file `skip.txt` + `-SkipFile`.
3. **Tombol S saat berjalan.** Tekan `S` di jendela console untuk langsung melewati
   game yang sedang aktif dan lanjut ke game berikutnya.

```powershell
:: lihat apa saja yang sudah pernah dimainkan
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -ShowHistory

:: mulai dari nol lagi (anggap semua game belum pernah dimainkan)
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -ResetHistory

:: farm ulang semuanya, termasuk yang sudah pernah
powershell -ExecutionPolicy Bypass -File discord-badge-farm.ps1 -GameCount 100 -IgnoreHistory
```

Catatan penting: riwayat ini **catatan lokal**, bukan data dari Discord. Discord tetap
yang menentukan apakah sebuah game benar-benar terdeteksi. Kalau sebuah game gagal
terdeteksi, game itu tetap tercatat di riwayat - hapus barisnya di `played.txt` atau
pakai `-IgnoreHistory` bila ingin mengulangnya.

- Default sekarang: **72 detik per game**, urutan **acak**, proses dummy **selalu tampil**.
- Jangan memakai durasi di bawah ~15 detik: Discord butuh beberapa detik untuk mendeteksi.
- Tekan `Ctrl+C` kapan saja untuk stop - sisa proses otomatis dimatikan.
- Statistik/badge di profil butuh waktu (menit sampai +-24-48 jam) untuk refresh.
- Jangan jalankan dua instance script bersamaan.
- Daftar bawaan berisi **200 nama game**. Nama `.exe` bersifat "best effort": kalau game
  tertentu tidak muncul sebagai "Playing ..." saat diuji, nama itu mungkin tidak ada di
  database deteksi Discord - hapus dari daftar / ganti dengan game lain.

## Menambah game sendiri

Cara paling gampang: copy `games.example.txt` jadi `games.txt`, lalu isi satu game per
baris, dan jalankan dengan `-GamesFile`.

```text
hl2p.exe | 60 | Portal
Terraria.exe
Celeste.exe | 2m
```

Kolom kedua adalah durasi khusus game itu (opsional). Format lama
`nama.exe = Judul` juga tetap didukung.

Bisa juga menambah langsung ke `$GameList` dalam `discord-badge-farm.ps1`:

```powershell
'Among Us.exe' = 'Among Us'
```

## Streaming badge (terbatas, manual)

Jam streaming dihitung dari **sesi stream yang benar-benar berjalan**, jadi tidak bisa
dipalsukan dengan proses dummy. Cara farming yang umum (manual, tanpa script):

1. Buat server privat sendiri, lalu masuk voice channel.
2. Klik **Share Your Screen / Go Live**, bagikan window statis (misal folder).
3. Biarkan sesi berjalan selama yang diinginkan.

Catatan: kalau jam tidak bertambah tanpa penonton, Discord mungkin hanya menghitung
stream yang ditonton orang lain - gunakan akun kedua / device lain untuk menonton.
Script ini sengaja **tidak** mengotomatiskan klik di aplikasi Discord: UI automation
rapuh (tampilan Discord sering berubah) dan menambah risiko pelanggaran ToS.

## Desain keamanan script ini

- Tidak menyentuh file instalasi Discord - aman dari update/rusaknya client.
- Tidak menyentuh token, email, atau password - bukan self-bot, tidak ada akses ke
  akun selain lewat deteksi proses biasa (sama seperti game sungguhan).
- Tidak memanggil API Discord sama sekali.
- Tidak ada persistence - tidak ada startup/autorun; hanya aktif saat dijalankan.
- Proses dummy CPU +-0%, RAM kecil, mudah dimatikan (`clean.bat` atau `-Clean`).
- Kode terbuka dan bisa dibaca penuh - tidak ada unduhan atau ekstensi tersembunyi.

Folder kerja: `%LOCALAPPDATA%\DiscordBadgeFarm` (berisi `sleeper.exe`, salinan per
game, dan `farm.log`). Hapus kapan saja dengan `clean.bat`.

## Risiko yang perlu Anda pahami

- Ini tetap **inflasi statistik buatan** sehingga berpotensi melanggar Discord Terms
  of Service. Karena metodenya hanya "proses game lokal" (tidak dibedakan dari game
  sungguhan oleh Discord), risiko akun diblokir **rendah**, tetapi **tidak nol**.
- Tips memperkecil risiko: jangan farm 24 jam nonstop (jam mustahil bisa dicurigai).
  Gunakan durasi realistis, misalnya maksimal 6-8 jam per hari.
- Gunakan hanya di akun Anda sendiri, dengan tanggung jawab Anda sendiri.
- Hindari alat "badge unlocker" yang meminta login/token - itu malware.

---

copyright by: **jaune**
