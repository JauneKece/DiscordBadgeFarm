#Requires -Version 5.1
# Discord Badge Farmer - copyright by: jaune
<#
.SYNOPSIS
    Farming badge aktivitas Discord (Game Time & Game Variety) dengan process-name spoofing.

.DESCRIPTION
    Cara kerja: aplikasi Discord desktop mendeteksi "game yang sedang Anda mainkan"
    dengan memindai NAMA PROSES (file .exe) yang berjalan, lalu mencocokkannya dengan
    database game internalnya. Jam main & jumlah game unik yang muncul di profil
    dihitung dari deteksi tersebut.

    Script ini membuat proses dummy ringan (hanya tidur, CPU +-0%) yang NAMA FILE-nya
    disamakan dengan nama .exe game populer, sehingga Discord menghitungnya sebagai
    waktu bermain. Rotasi antar game otomatis = badge Game Variety.

    Untuk KEAMANAN, script ini secara sengaja:
      - TIDAK menyentuh / memodifikasi file instalasi Discord
      - TIDAK membaca token, email, password, atau cookie Discord
      - TIDAK memanggil API Discord (bukan self-bot)
      - TIDAK memasang persistence/autorun - hanya aktif saat dijalankan
      - Mudah dihentikan & dibersihkan (parameter -Clean)

    Catatan penting:
      - Jalankan dengan Windows PowerShell bawaan (powershell.exe), bukan pwsh.
      - Discord desktop harus berjalan & login, dan berbagi aktivitas terdeteksi
        aktif di Settings > Activity Privacy.
      - Nama .exe di daftar bawaan adalah "best effort" (lihat -ListGames). Kalau
        sebuah nama tidak dikenali Discord, game itu hanya tidak tercatat - tidak
        merusak apa pun. Verifikasi nama yang Anda butuhkan lewat Discord sendiri.
      - Badge Account Age TIDAK mungkin dimanipulasi siapa pun (data server-side).
      - Badge streaming butuh sesi stream sungguhan, tidak bisa dipalsukan proses.
      - Jangan jalankan dua instance script ini bersamaan.

.PARAMETER Games
    Daftar nama file .exe game yang dikenali Discord. Boleh juga berupa judul;
    nama file akan diambil otomatis. Contoh: -Games "Terraria.exe","Celeste.exe".

.PARAMETER GamesFile
    Path file teks berisi daftar game yang AKAN DIFARM (hanya isi file ini yang
    dijalankan). Satu game per baris, dipisah tanda '|':

        nama_file.exe
        nama_file.exe | 120
        nama_file.exe | 2m | Judul Game
        nama_file.exe = Judul Game          (format lama, tetap didukung)

    Kolom tengah adalah durasi khusus game itu (detik, atau 45s / 2m / 1m30s).
    Game tanpa durasi memakai -SecondsPerGame / -HoursPerGame.
    Baris kosong dan baris berawalan '#' diabaikan.

.PARAMETER GameCount
    Jumlah game yang ingin difarm. Script mengambil N game pertama dari daftar
    acak (default: seluruh daftar). Kalau N lebih besar dari jumlah nama yang
    tersedia, script akan memperingatkan dan memakai semua yang ada.
    Contoh: -GameCount 100

.PARAMETER Ask
    Tanya jumlah game DAN durasi per game secara interaktif tepat sebelum farming
    dimulai. Contoh: -Ask  ->  "Berapa game yang mau difarm? [1-101, default 101]:"
    lalu "Berapa lama tiap game? [default 1 mnt 12 dtk; contoh: 30 / 2m / 1m30s]:"
    Tekan Enter untuk memakai default masing-masing. Kalau -SecondsPerGame /
    -GameCount diisi, nilainya dipakai sebagai default di pertanyaan.

.PARAMETER Random
    Dipertahankan demi kompatibilitas. Urutan game sekarang SUDAH acak secara
    default; gunakan -InOrder kalau ingin tetap berurutan sesuai daftar.

.PARAMETER InOrder
    Jangan acak urutan; jalankan game sesuai urutan daftar.

.PARAMETER SkipGames
    Nama .exe game yang ingin dilewati (tidak difarm). Contoh:
    -SkipGames "Terraria.exe","Celeste.exe"

.PARAMETER SkipFile
    Path file teks berisi game yang ingin dilewati, satu per baris.
    Format sama seperti -GamesFile (baris '#' dan baris kosong diabaikan).

.PARAMETER IgnoreHistory
    Abaikan riwayat game yang sudah pernah difarm. Secara default, game yang
    sudah tercatat di riwayat otomatis dilewati supaya setiap kali dijalankan
    Anda menggarap game BARU (mempercepat badge Game Variety).

.PARAMETER ShowHistory
    Tampilkan daftar game yang sudah pernah difarm, lalu keluar.

.PARAMETER ResetHistory
    Hapus riwayat "sudah dimainkan", lalu keluar. Setelah ini semua game
    dianggap belum pernah dimainkan.

.PARAMETER HoursPerGame
    Durasi tiap game dijalankan, dalam jam. Default 0.02 (72 detik).

.PARAMETER SecondsPerGame
    Durasi tiap game dalam DETIK. Kalau diisi, menimpa -HoursPerGame.
    Contoh: -SecondsPerGame 45
    Bisa juga pakai -Ask untuk mengisinya secara interaktif.

.PARAMETER Rounds
    Berapa kali seluruh daftar game diputar (default 1).

.PARAMETER Test
    Mode uji cepat: jalankan 'Terraria.exe' dummy selama 60 detik saja.

.PARAMETER Visible
    Dipertahankan demi kompatibilitas. Sekarang proses dummy SELALU tampil
    (window terlihat) secara default, karena mode hidden sering tidak terdeteksi
    Discord. Gunakan -Hidden kalau tetap ingin mode tanpa window.

.PARAMETER Hidden
    Jalankan proses dummy tanpa window (mode lama). Bisa jadi tidak terdeteksi
    Discord; pakai hanya kalau -Visible bermasalah.

.PARAMETER ListGames
    Tampilkan seluruh nama game yang tersedia di daftar bawaan, lalu keluar.

.PARAMETER Ascii
    Pakai karakter ASCII sederhana (+, -, |, #) untuk tampilan kotak & progress
    bar. Gunakan ini kalau console Anda menampilkan karakter kotak sebagai
    simbol aneh/karakter rusak.

.PARAMETER Preview
    Tampilkan rencana farming (game apa saja, berapa lama, estimasi total) tanpa
    menjalankan satu proses pun. Berguna untuk cek dulu sebelum farming.

.PARAMETER Clean
    Matikan semua proses dummy yang tersisa, hapus folder kerja, lalu keluar.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\discord-badge-farm.ps1 -GameCount 100 -SecondsPerGame 45 -Preview

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\discord-badge-farm.ps1 -Test

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\discord-badge-farm.ps1 -GameCount 100 -SecondsPerGame 45

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\discord-badge-farm.ps1 -GamesFile .\games.txt -SecondsPerGame 60 -Random

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\discord-badge-farm.ps1 -Games "Terraria.exe","Celeste.exe" -SecondsPerGame 40

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\discord-badge-farm.ps1 -Clean

.NOTES
    copyright by: jaune

    Gunakan hanya pada akun Anda sendiri dan dengan bijak. Inflasi statistik buatan
    berpotensi melanggar Discord Terms of Service - risiko diblokir rendah, tapi
    tidak nol. Saran: jangan farm 24 jam nonstop; gunakan durasi realistis.
#>
[CmdletBinding()]
param(
    [string[]]$Games,
    [string]$GamesFile,
    [int]$GameCount = 0,
    [switch]$Ask,
    [double]$HoursPerGame = 0.02,
    [int]$SecondsPerGame = 0,
    [int]$Rounds = 1,
    [switch]$Random,
    [switch]$InOrder,
    [string[]]$SkipGames,
    [string]$SkipFile,
    [switch]$IgnoreHistory,
    [switch]$ShowHistory,
    [switch]$ResetHistory,
    [switch]$Test,
    [switch]$Visible,
    [switch]$Hidden,
    [switch]$Preview,
    [switch]$ListGames,
    [switch]$Ascii,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------------ konfigurasi
$WorkDir  = Join-Path $env:LOCALAPPDATA 'DiscordBadgeFarm'
$DummyExe = Join-Path $WorkDir 'sleeper.exe'
$LogFile  = Join-Path $WorkDir 'farm.log'
$HistoryFile = Join-Path $WorkDir 'played.txt'
$GameDurations = @{}   # exe -> durasi khusus (detik), dari -GamesFile

# ------------------------------------------------------------------ tampilan
$script:Ascii        = [bool]$Ascii
$script:Copyright    = 'copyright by: jaune'
$script:ConsoleWidth = 90
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
try {
    $winW = $Host.UI.RawUI.WindowSize.Width
    if ($winW -ge 50) { $script:ConsoleWidth = $winW }
} catch { }
$script:BoxWidth = [math]::Max(40, [math]::Min(60, $script:ConsoleWidth - 4))
$script:ProgressActive = $false

# Nama .exe game populer yang dikenal Discord -> judul (judul hanya untuk log).
# PENTING: daftar ini "best effort". Discord punya database sendiri; kalau sebuah
# nama tidak dikenali, game itu sekadar tidak tercatat. Silakan edit / tambah
# baris sendiri, atau pakai -GamesFile untuk daftar Anda sendiri.
$GameList = [ordered]@{
    # --- Valve / Source ---
    'hl2p.exe'                            = 'Portal'
    'portal2.exe'                         = 'Portal 2'
    'left4dead2.exe'                      = 'Left 4 Dead 2'
    'csgo.exe'                            = 'Counter-Strike: Global Offensive'
    'cs2.exe'                             = 'Counter-Strike 2'
    'tf_win64.exe'                        = 'Team Fortress 2'
    'dota2.exe'                           = 'Dota 2'

    # --- Indie ---
    'Terraria.exe'                        = 'Terraria'
    'Stardew Valley.exe'                  = 'Stardew Valley'
    'hollow_knight.exe'                   = 'Hollow Knight'
    'Celeste.exe'                         = 'Celeste'
    'Cuphead.exe'                         = 'Cuphead'
    'rimworldwin.exe'                     = 'RimWorld'
    'GeometryDash.exe'                    = 'Geometry Dash'
    'osu!.exe'                            = 'osu!'
    'Undertale.exe'                       = 'UNDERTALE'
    'Factorio.exe'                        = 'Factorio'
    'DeadCells.exe'                       = 'Dead Cells'
    'SlayTheSpire.exe'                    = 'Slay the Spire'
    'Hades.exe'                           = 'Hades'
    'Hades2.exe'                          = 'Hades II'
    'Among Us.exe'                        = 'Among Us'
    'Phasmophobia.exe'                    = 'Phasmophobia'
    'Lethal Company.exe'                  = 'Lethal Company'
    'Brawlhalla.exe'                      = 'Brawlhalla'
    'Valheim.exe'                         = 'Valheim'
    'VRising.exe'                         = 'V Rising'
    'ProjectZomboid64.exe'                = 'Project Zomboid'
    'dontstarve_steam.exe'                = "Don't Starve"
    'OxygenNotIncluded.exe'               = 'Oxygen Not Included'
    'Kenshi.exe'                          = 'Kenshi'

    # --- Sandbox / builder / survival ---
    'Raft.exe'                            = 'Raft'
    'Subnautica.exe'                      = 'Subnautica'
    'SubnauticaZero.exe'                  = 'Subnautica: Below Zero'
    'OuterWilds.exe'                      = 'Outer Wilds'
    'disco.exe'                           = 'Disco Elysium'
    'Balatro.exe'                         = 'Balatro'
    'FactoryGame-Win64-Shipping.exe'      = 'Satisfactory'
    'Cities.exe'                          = 'Cities: Skylines'
    'Cities2.exe'                         = 'Cities: Skylines II'
    'Stellaris.exe'                       = 'Stellaris'
    'hoi4.exe'                            = 'Hearts of Iron IV'
    'eu4.exe'                             = 'Europa Universalis IV'
    'ck3.exe'                             = 'Crusader Kings III'
    'victoria3.exe'                       = 'Victoria 3'
    'Palworld-Win64-Shipping.exe'         = 'Palworld'
    'SonsOfTheForest.exe'                 = 'Sons of the Forest'
    'TheForest.exe'                       = 'The Forest'

    # --- RPG / AAA ---
    'GTA5.exe'                            = 'Grand Theft Auto V'
    'RDR2.exe'                            = 'Red Dead Redemption 2'
    'Cyberpunk2077.exe'                   = 'Cyberpunk 2077'
    'witcher3.exe'                        = 'The Witcher 3: Wild Hunt'
    'SkyrimSE.exe'                        = 'The Elder Scrolls V: Skyrim SE'
    'Fallout4.exe'                        = 'Fallout 4'
    'FalloutNV.exe'                       = 'Fallout: New Vegas'
    'bg3.exe'                             = "Baldur's Gate 3"
    'eldenring.exe'                       = 'ELDEN RING'
    'DarkSoulsIII.exe'                    = 'DARK SOULS III'
    'sekiro.exe'                          = 'Sekiro: Shadows Die Twice'
    'NieRAutomata.exe'                    = 'NieR:Automata'
    'MonsterHunterWorld.exe'              = 'Monster Hunter: World'
    'MonsterHunterRise.exe'               = 'Monster Hunter Rise'
    'p5r.exe'                             = 'Persona 5 Royal'
    'Starfield.exe'                       = 'Starfield'
    'HogwartsLegacy.exe'                  = 'Hogwarts Legacy'
    'EoCApp.exe'                          = 'Divinity: Original Sin 2'

    # --- Shooter ---
    'Overwatch.exe'                       = 'Overwatch 2'
    'r5apex.exe'                          = 'Apex Legends'
    'FortniteClient-Win64-Shipping.exe'   = 'Fortnite'
    'TslGame.exe'                         = 'PUBG: BATTLEGROUNDS'
    'RainbowSix.exe'                      = 'Rainbow Six Siege'
    'EscapeFromTarkov.exe'                = 'Escape from Tarkov'
    'VALORANT-Win64-Shipping.exe'         = 'VALORANT'
    'destiny2.exe'                        = 'Destiny 2'
    'HaloInfinite.exe'                    = 'Halo Infinite'
    'MCC-Win64-Shipping.exe'              = 'Halo: The Master Chief Collection'
    'DOOMEternalx64vk.exe'                = 'DOOM Eternal'
    'Warframe.x64.exe'                    = 'Warframe'
    'FSD-Win64-Shipping.exe'              = 'Deep Rock Galactic'
    'SoTGame.exe'                         = 'Sea of Thieves'
    'rustclient.exe'                      = 'Rust'
    'DayZ_x64.exe'                        = 'DayZ'
    'arma3_x64.exe'                       = 'Arma 3'

    # --- Racing / sim ---
    'BeamNG.drive.exe'                    = 'BeamNG.drive'
    'eurotrucks2.exe'                     = 'Euro Truck Simulator 2'
    'amtrucks.exe'                        = 'American Truck Simulator'
    'acs.exe'                             = 'Assetto Corsa'
    'ForzaHorizon5.exe'                   = 'Forza Horizon 5'
    'FlightSimulator.exe'                 = 'Microsoft Flight Simulator'

    # --- MMO / lain-lain ---
    'League of Legends.exe'               = 'League of Legends'
    'RocketLeague.exe'                    = 'Rocket League'
    'FallGuys_client.exe'                 = 'Fall Guys'
    'GenshinImpact.exe'                   = 'Genshin Impact'
    'StarRail.exe'                        = 'Honkai: Star Rail'
    'ZenlessZoneZero.exe'                 = 'Zenless Zone Zero'
    'ffxiv_dx11.exe'                      = 'Final Fantasy XIV'
    'ESO64.exe'                           = 'The Elder Scrolls Online'
    'GuildWars2.exe'                      = 'Guild Wars 2'
    'Wow.exe'                             = 'World of Warcraft'
    'PathOfExile.exe'                     = 'Path of Exile'
    'Diablo IV.exe'                       = 'Diablo IV'

    # --- Tambahan: Valve / klasik ---
    'gmod.exe'                            = "Garry's Mod"
    'left4dead.exe'                       = 'Left 4 Dead'
    'BlackMesa.exe'                       = 'Black Mesa'

    # --- Tambahan: indie ---
    'Starbound.exe'                       = 'Starbound'
    'HyperLightDrifter.exe'               = 'Hyper Light Drifter'
    'OriDE.exe'                           = 'Ori and the Blind Forest'
    'OriAndTheWilloftheWisps.exe'         = 'Ori and the Will of the Wisps'
    'INSIDE.exe'                          = 'INSIDE'
    'Limbo.exe'                           = 'LIMBO'
    'GRIS.exe'                            = 'GRIS'
    'Journey.exe'                         = 'Journey'
    'Firewatch.exe'                       = 'Firewatch'
    'TheWitness.exe'                      = 'The Witness'
    'SuperMeatBoy.exe'                    = 'Super Meat Boy'
    'TheBindingOfIsaacRebirth.exe'        = 'The Binding of Isaac: Rebirth'
    'EnterTheGungeon.exe'                 = 'Enter the Gungeon'
    'RiskOfRain2.exe'                     = 'Risk of Rain 2'
    'VampireSurvivors.exe'                = 'Vampire Survivors'
    'DwarfFortress.exe'                   = 'Dwarf Fortress'
    'CoreKeeper.exe'                      = 'Core Keeper'
    'Tunic.exe'                           = 'Tunic'
    'PizzaTower.exe'                      = 'Pizza Tower'
    'Ultrakill.exe'                       = 'ULTRAKILL'
    'Deltarune.exe'                       = 'Deltarune'
    'Omori.exe'                           = 'OMORI'
    'CultOfTheLamb.exe'                   = 'Cult of the Lamb'
    'SlimeRancher.exe'                    = 'Slime Rancher'
    'SlimeRancher2.exe'                   = 'Slime Rancher 2'
    'DaveTheDiver.exe'                    = 'Dave the Diver'
    'Dredge.exe'                          = 'DREDGE'
    'GraveyardKeeper.exe'                 = 'Graveyard Keeper'
    'Spiritfarer.exe'                     = 'Spiritfarer'
    'Human Fall Flat.exe'                 = 'Human Fall Flat'
    'Gang Beasts.exe'                     = 'Gang Beasts'
    'Overcooked2.exe'                     = 'Overcooked! 2'
    'ItTakesTwo.exe'                      = 'It Takes Two'
    'BeatSaber.exe'                       = 'Beat Saber'

    # --- Tambahan: strategi / simulasi ---
    'Frostpunk.exe'                       = 'Frostpunk'
    'Frostpunk2.exe'                      = 'Frostpunk 2'
    'Anno1800.exe'                        = 'Anno 1800'
    'CivilizationVI.exe'                  = 'Sid Meier''s Civilization VI'
    'TotalWarWarhammer3.exe'              = 'Total War: WARHAMMER III'
    'PlanetZoo.exe'                       = 'Planet Zoo'
    'PlanetCoaster.exe'                   = 'Planet Coaster'
    'JurassicWorldEvolution2.exe'         = 'Jurassic World Evolution 2'
    'TwoPointHospital.exe'                = 'Two Point Hospital'
    'Timberborn.exe'                      = 'Timberborn'
    'AgainstTheStorm.exe'                 = 'Against the Storm'
    'ManorLords.exe'                      = 'Manor Lords'
    'TransportFever2.exe'                 = 'Transport Fever 2'

    # --- Tambahan: survival / crafting ---
    'TheLongDark.exe'                     = 'The Long Dark'
    'GreenHell.exe'                       = 'Green Hell'
    'Grounded-Win64-Shipping.exe'         = 'Grounded'
    'Minecraft.Windows.exe'               = 'Minecraft'
    'Astroneer.exe'                       = 'Astroneer'
    'DysonSphereProgram.exe'              = 'Dyson Sphere Program'
    'ShooterGame.exe'                     = 'ARK: Survival Evolved'
    'ConanSandbox.exe'                    = 'Conan Exiles'
    '7DaysToDie.exe'                      = '7 Days to Die'

    # --- Tambahan: aksi / AAA ---
    'ACOdyssey.exe'                       = "Assassin's Creed Odyssey"
    'ACOrigins.exe'                       = "Assassin's Creed Origins"
    'ACValhalla.exe'                      = "Assassin's Creed Valhalla"
    'FarCry6.exe'                         = 'Far Cry 6'
    'HITMAN3.exe'                         = 'HITMAN 3'
    'DEATHLOOP.exe'                       = 'DEATHLOOP'
    'Dishonored2.exe'                     = 'Dishonored 2'
    'Prey.exe'                            = 'Prey'
    'Control.exe'                         = 'Control'
    'BatmanAK.exe'                        = 'Batman: Arkham Knight'
    'MadMax.exe'                          = 'Mad Max'
    'ShadowOfWar.exe'                     = 'Middle-earth: Shadow of War'
    'MGSVTPP.exe'                         = 'Metal Gear Solid V: The Phantom Pain'
    'Sifu.exe'                            = 'Sifu'
    'GodOfWar.exe'                        = 'God of War'
    'HorizonZeroDawn.exe'                 = 'Horizon Zero Dawn'
    'DaysGone.exe'                        = 'Days Gone'
    'Returnal.exe'                        = 'Returnal'
    'DeathStranding.exe'                  = 'Death Stranding'

    # --- Tambahan: shooter / online ---
    'helldivers2.exe'                     = 'HELLDIVERS 2'
    'ContentWarning.exe'                  = 'Content Warning'
    'Smite.exe'                           = 'SMITE'
    'Paladins.exe'                        = 'Paladins'
    'aces.exe'                            = 'War Thunder'
    'WorldOfTanks.exe'                    = 'World of Tanks'
    'WorldOfWarships.exe'                 = 'World of Warships'
    'SCUM.exe'                            = 'SCUM'
    'Unturned.exe'                        = 'Unturned'
    'GooseGooseDuck.exe'                  = 'Goose Goose Duck'
    'DeadByDaylight-Win64-Shipping.exe'   = 'Dead by Daylight'
    're8.exe'                             = 'Resident Evil Village'
    're4.exe'                             = 'Resident Evil 4'
    'KillingFloor2.exe'                   = 'Killing Floor 2'
    'payday2_win32_release.exe'           = 'PAYDAY 2'
    'GTFO.exe'                            = 'GTFO'
    'ReadyOrNot-Win64-Shipping.exe'       = 'Ready or Not'
    'SquadGame.exe'                       = 'Squad'

    # --- Tambahan: lain-lain ---
    'RetroArch.exe'                       = 'RetroArch'
    'vrchat.exe'                          = 'VRChat'
    'MultiVersus.exe'                     = 'MultiVersus'
}

# ------------------------------------------------------------------ fungsi tampilan
function Get-Glyph {
    param([string]$Key)
    if ($script:Ascii) {
        $map = @{ tl = '+'; tr = '+'; bl = '+'; br = '+'; h = '-'; v = '|'; full = '#'; empty = '-'; arrow = '>' }
    }
    else {
        $map = @{
            tl    = [string][char]0x2554   # ╔
            tr    = [string][char]0x2557   # ╗
            bl    = [string][char]0x255A   # ╚
            br    = [string][char]0x255D   # ╝
            h     = [string][char]0x2550   # ═
            v     = [string][char]0x2551   # ║
            full  = [string][char]0x2588   # █
            empty = [string][char]0x2591   # ░
            arrow = [string][char]0x25B8   # ▸
        }
    }
    return $map[$Key]
}

function Write-BoxLine {
    param([string]$Text = '', [string]$Color = 'White', [switch]$Center)
    $w = $script:BoxWidth
    if ($Text.Length -gt $w) { $Text = $Text.Substring(0, $w) }
    if ($Center) {
        $pad   = $w - $Text.Length
        $left  = [int][math]::Floor($pad / 2)
        $Text  = (' ' * $left) + $Text + (' ' * ($pad - $left))
    }
    else {
        $Text = $Text.PadRight($w)
    }
    Write-Host ((Get-Glyph v) + ' ' + $Text + ' ' + (Get-Glyph v)) -ForegroundColor $Color
}

function Write-BoxEdge {
    param([string]$Kind = 'top', [string]$Color = 'Magenta')
    $left  = if ($Kind -eq 'top') { Get-Glyph tl } else { Get-Glyph bl }
    $right = if ($Kind -eq 'top') { Get-Glyph tr } else { Get-Glyph br }
    Write-Host ($left + ((Get-Glyph h) * ($script:BoxWidth + 2)) + $right) -ForegroundColor $Color
}

function Show-Banner {
    Write-Host ''
    Write-BoxEdge -Kind top -Color Magenta
    Write-BoxLine 'DISCORD BADGE FARMER' 'Magenta' -Center
    Write-BoxLine 'Game Time  &  Game Variety' 'DarkGray' -Center
    Write-BoxLine '' 'DarkGray'
    Write-BoxLine $script:Copyright 'Yellow' -Center
    Write-BoxEdge -Kind bottom -Color Magenta
    Write-Host ''
}

function Write-Section {
    param([string]$Title, [string]$Color = 'Cyan')
    Write-Host ''
    Write-Host ('  ' + (Get-Glyph arrow) + ' ' + $Title) -ForegroundColor $Color
    Write-Host ('  ' + ((Get-Glyph h) * [math]::Min($script:BoxWidth, $Title.Length + 8))) -ForegroundColor DarkGray
}

function Format-Bar {
    param([double]$Percent, [int]$Width = 22)
    if ($Percent -lt 0)   { $Percent = 0 }
    if ($Percent -gt 100) { $Percent = 100 }
    $filled = [int][math]::Round($Width * $Percent / 100.0)
    return '[' + ((Get-Glyph full) * $filled) + ((Get-Glyph empty) * ($Width - $filled)) + ']'
}

function Show-Progress {
    param([double]$Percent, [string]$Text)
    $line = '  ' + (Format-Bar -Percent $Percent) + (' {0,3:N0}%  ' -f $Percent) + $Text
    $max  = [math]::Max(30, $script:ConsoleWidth - 1)
    if ($line.Length -gt $max) { $line = $line.Substring(0, $max) }
    $script:ProgressActive = $true
    Write-Host ("`r" + $line.PadRight($max)) -NoNewline -ForegroundColor Cyan
}

function Clear-ProgressLine {
    if (-not $script:ProgressActive) { return }
    $max = [math]::Max(30, $script:ConsoleWidth - 1)
    Write-Host ("`r" + (' ' * $max) + "`r") -NoNewline
    $script:ProgressActive = $false
}

function Test-CanPrompt {
    try { return -not [Console]::IsInputRedirected } catch { return $false }
}

function Show-Menu {
    Write-Host '  MENU' -ForegroundColor Cyan
    $items = @(
        @('1', 'Mulai farming (tanya jumlah & durasi)'),
        @('2', 'Lihat rencana saja (preview, tanpa jalan)'),
        @('3', 'Lihat riwayat game yang sudah dimainkan'),
        @('4', 'Hapus riwayat'),
        @('5', 'Daftar semua game yang tersedia'),
        @('6', 'Bersih-bersih (hapus folder kerja)'),
        @('0', 'Keluar')
    )
    foreach ($it in $items) {
        Write-Host ('   ' + $it[0] + '. ') -NoNewline -ForegroundColor Yellow
        Write-Host $it[1]
    }
    Write-Host ''
    while ($true) {
        $raw = Read-Host '  Pilih menu [0-6, default 1]'
        if ([string]::IsNullOrWhiteSpace($raw)) { return '1' }
        $raw = $raw.Trim()
        foreach ($it in $items) { if ($it[0] -eq $raw) { return $raw } }
        Write-Host '  Pilihan tidak valid, coba lagi.' -ForegroundColor Yellow
    }
}

# ------------------------------------------------------------------ fungsi
function Write-Log {
    param([string]$Message)
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    if (Test-Path $WorkDir) {
        Add-Content -Path $LogFile -Value $line -ErrorAction SilentlyContinue
    }
}

function ConvertTo-Seconds {
    # Ubah input durasi jadi detik. Contoh: 90, 45s, 2m, 1m30s, 1h, 0.5h.
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    $t = $Text.Trim().ToLower()

    if ($t -match '^\d+(\.\d+)?$') { return [double]$t }

    $total   = 0.0
    $matched = $false
    foreach ($m in [regex]::Matches($t, '(?<v>\d+(?:\.\d+)?)\s*(?<u>h|jam|j|mnt|menit|m|dtk|detik|s)')) {
        $matched = $true
        $v = [double]$m.Groups['v'].Value
        $u = $m.Groups['u'].Value
        switch -Regex ($u) {
            '^(h|jam|j)$'        { $total += $v * 3600 }
            '^(mnt|menit|m)$'    { $total += $v * 60 }
            default              { $total += $v }
        }
    }
    if (-not $matched) { return $null }
    if ($total -le 0) { return $null }
    return $total
}

function Read-DurationInteractive {
    # Tanya durasi per game. Enter = default.
    param([double]$DefaultSeconds)

    $defText = Format-Duration $DefaultSeconds
    while ($true) {
        Write-Host ''
        Write-Host ('Durasi per game sekarang: {0}.' -f $defText) -ForegroundColor Cyan
        try {
            $raw = Read-Host ('Berapa lama tiap game? [default {0}; contoh: 30 / 45s / 2m / 1m30s]' -f (Format-Duration $DefaultSeconds))
        }
        catch {
            Write-Host 'Tidak bisa membaca input; memakai durasi default.' -ForegroundColor DarkGray
            return $DefaultSeconds
        }

        if ([string]::IsNullOrWhiteSpace($raw)) { return $DefaultSeconds }

        $sec = ConvertTo-Seconds $raw
        if ($null -ne $sec) {
            if ($sec -lt 5) {
                Write-Host '  Minimal 5 detik agar sempat terdeteksi. Coba lagi.' -ForegroundColor Yellow
                continue
            }
            return $sec
        }
        Write-Host '  Format tidak dikenali. Contoh yang benar: 45, 45s, 2m, 1m30s.' -ForegroundColor Yellow
    }
}

function Get-GameSeconds {
    # Durasi efektif sebuah game: durasi khusus dari file, atau default.
    param([string]$Exe, [double]$DefaultSeconds)
    foreach ($k in @($GameDurations.Keys)) {
        if ([string]::Equals($k, $Exe, [StringComparison]::OrdinalIgnoreCase)) {
            return [double]$GameDurations[$k]
        }
    }
    return $DefaultSeconds
}

function Format-Duration {
    param([double]$TotalSeconds)
    $ts = [TimeSpan]::FromSeconds([math]::Max(0, $TotalSeconds))
    if ($ts.TotalHours -ge 1) { return ('{0} jam {1} mnt' -f [int][math]::Floor($ts.TotalHours), $ts.Minutes) }
    if ($ts.TotalMinutes -ge 1) { return ('{0} mnt {1:d2} dtk' -f [int][math]::Floor($ts.TotalMinutes), $ts.Seconds) }
    return ('{0} dtk' -f [int][math]::Round($ts.TotalSeconds))
}

function Get-GameTitle {
    param([string]$Exe)
    foreach ($k in $GameList.Keys) {
        if ([string]::Equals($k, $Exe, [StringComparison]::OrdinalIgnoreCase)) { return $GameList[$k] }
    }
    return [IO.Path]::GetFileNameWithoutExtension($Exe)
}

function Read-GameCountInteractive {
    # Tanya jumlah game sebelum farming dimulai. Enter = pakai default.
    param([int]$Available, [int]$Default)

    $range = if ($Available -gt 0) { "1-$Available" } else { '1+' }
    while ($true) {
        Write-Host ''
        Write-Host ('Game siap difarm: {0}.' -f $Available) -ForegroundColor Cyan

        try {
            $raw = Read-Host ('Berapa game yang mau difarm? [{0}, default {1}]' -f $range, $Default)
        }
        catch {
            Write-Host 'Tidak bisa membaca input; memakai jumlah default.' -ForegroundColor DarkGray
            return $Default
        }

        if ([string]::IsNullOrWhiteSpace($raw)) { return $Default }

        $n = 0
        if ([int]::TryParse($raw.Trim(), [ref]$n) -and $n -gt 0) {
            if ($Available -gt 0 -and $n -gt $Available) {
                Write-Host ('Hanya tersedia {0} game; memakai {0}.' -f $Available) -ForegroundColor Yellow
                return $Available
            }
            return $n
        }
        Write-Host 'Masukkan angka bulat lebih dari 0 (atau tekan Enter untuk default).' -ForegroundColor Yellow
    }
}

function Format-NameList {
    # Ringkas daftar nama panjang: "a, b, c, ... +12 lagi".
    param([string[]]$Names, [int]$Max = 8)
    $arr = @($Names)
    if ($arr.Count -eq 0) { return '' }
    if ($arr.Count -le $Max) { return ($arr -join ', ') }
    return (($arr[0..($Max - 1)] -join ', ') + (', ... +{0} lagi' -f ($arr.Count - $Max)))
}

function ConvertTo-ExeName {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    try { $name = [IO.Path]::GetFileName($Value.Trim()) } catch { return $null }
    if ([string]::IsNullOrWhiteSpace($name)) { return $null }
    return $name
}

function Test-NameInList {
    param([string]$Name, [string[]]$List)
    foreach ($item in $List) {
        if ([string]::Equals($item, $Name, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

function Read-NameFile {
    # Baca daftar nama .exe dari file teks (format sama dengan -GamesFile).
    param([string]$Path)
    $result = New-Object System.Collections.Generic.List[string]
    if (-not $Path -or -not (Test-Path -LiteralPath $Path)) { return $result }
    foreach ($raw in Get-Content -LiteralPath $Path) {
        if ($null -eq $raw) { continue }
        $line = $raw.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith('#')) { continue }
        if ($line -match '^(?<exe>[^=]+?)\s*=') { $line = $Matches.exe.Trim() }
        $name = ConvertTo-ExeName $line
        if ($name) { $result.Add($name) }
    }
    return $result
}

function Get-PlayedGames {
    if (-not (Test-Path -LiteralPath $HistoryFile)) { return @() }
    return @(
        Get-Content -LiteralPath $HistoryFile |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -and -not $_.StartsWith('#') } |
            Select-Object -Unique
    )
}

function Add-PlayedGame {
    param([string]$Exe)
    if (-not (Test-Path $WorkDir)) { New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null }
    Add-Content -LiteralPath $HistoryFile -Value $Exe -ErrorAction SilentlyContinue
}

function Wait-GameDuration {
    # Tunggu selama durasi game, tampilkan progress, dan pantau tombol 'S' untuk skip.
    param([int]$Milliseconds, [string]$Label)
    $deadline = (Get-Date).AddMilliseconds($Milliseconds)
    while ($true) {
        $remaining = ($deadline - (Get-Date)).TotalMilliseconds
        if ($remaining -le 0) {
            Show-Progress -Percent 100 -Text $Label
            return 'done'
        }

        $percent = 100.0 * (1.0 - ($remaining / [double]$Milliseconds))
        Show-Progress -Percent $percent -Text ($Label + ('   sisa {0,3}s' -f [int][math]::Ceiling($remaining / 1000.0)))

        try {
            if (-not [Console]::IsInputRedirected -and [Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq [ConsoleKey]::S) { return 'skipped' }
            }
        }
        catch { }

        $slice = [int][math]::Min(200, [math]::Ceiling($remaining))
        if ($slice -lt 1) { $slice = 1 }
        Start-Sleep -Milliseconds $slice
    }
}

function Get-FarmProcesses {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ExecutablePath -and
            $_.ExecutablePath.StartsWith($WorkDir, [StringComparison]::OrdinalIgnoreCase)
        }
}

function Stop-FarmProcesses {
    foreach ($p in @(Get-FarmProcesses)) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Log ("Mematikan sisa proses dummy: {0} (PID {1})" -f $p.Name, $p.ProcessId)
    }
}

function Test-ProcAlive {
    param($Process)
    if (-not $Process) { return $false }
    try { return -not $Process.HasExited } catch { return $false }
}

function Test-DiscordRunning {
    [bool](Get-Process -Name Discord, DiscordPTB, DiscordCanary -ErrorAction SilentlyContinue)
}

function New-SleeperExe {
    # Buat executable dummy yang hanya tidur. Kalau compiler tidak tersedia,
    # fallback: salinan ping.exe yang mem-ping localhost (loopback, tanpa traffic).
    param([switch]$Force)
    if ((Test-Path $DummyExe) -and -not $Force) { return }

    $source = @'
using System;
using System.Threading;

class Sleeper
{
    static void Main(string[] args)
    {
        while (true)
        {
            try { Thread.Sleep(int.MaxValue); } catch { }
        }
    }
}
'@
    try {
        Add-Type -TypeDefinition $source -OutputType ConsoleApplication -OutputAssembly $DummyExe
        Write-Log 'sleeper.exe dibuat lewat compiler .NET lokal.'
    }
    catch {
        $ping = Join-Path $env:SystemRoot 'System32\ping.exe'
        if (-not (Test-Path $ping)) {
            throw 'Tidak bisa membuat proses dummy (compiler .NET dan ping.exe tidak tersedia).'
        }
        Copy-Item $ping $DummyExe -Force
        Write-Log 'Compiler tidak tersedia; memakai salinan ping.exe sebagai fallback.'
    }
}

# ------------------------------------------------------------------ banner & menu
Show-Banner

if ($PSBoundParameters.Count -eq 0) {
    if (-not (Test-CanPrompt)) {
        Write-Host '  Tidak ada input interaktif.' -ForegroundColor Yellow
        Write-Host '  Jalankan dengan parameter, contoh:' -ForegroundColor Yellow
        Write-Host '    powershell -File .\discord-badge-farm.ps1 -Ask' -ForegroundColor DarkGray
        Write-Host '    powershell -File .\discord-badge-farm.ps1 -ListGames' -ForegroundColor DarkGray
        return
    }
    $choice = Show-Menu
    switch ($choice) {
        '0' { Write-Host '  Sampai jumpa.' -ForegroundColor DarkGray; return }
        '2' { $Preview = $true; $Ask = $true }
        '3' { $ShowHistory = $true }
        '4' { $ResetHistory = $true }
        '5' { $ListGames = $true }
        '6' { $Clean = $true }
        default { $Ask = $true }
    }
    Write-Host ''
}

# ------------------------------------------------------------------ mode bersih-bersih
if ($Clean) {
    if (Test-Path $WorkDir) {
        Stop-FarmProcesses
        Start-Sleep -Seconds 1
        Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host 'Bersih: semua proses dummy dimatikan dan folder kerja dihapus.'
    }
    else {
        Write-Host 'Tidak ada yang perlu dibersihkan.'
    }
    return
}

# ------------------------------------------------------------------ daftar game custom dari file
$fileGames = New-Object System.Collections.Generic.List[string]
if ($GamesFile) {
    if (-not (Test-Path -LiteralPath $GamesFile)) {
        throw "File daftar game tidak ditemukan: $GamesFile"
    }
    $added = 0
    foreach ($raw in Get-Content -LiteralPath $GamesFile) {
        if ($null -eq $raw) { continue }
        $line = $raw.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith('#')) { continue }

        # Format:  nama.exe | durasi | judul      (durasi & judul opsional)
        # Format lama juga didukung:  nama.exe = judul
        $parts   = @($line -split '\|' | ForEach-Object { $_.Trim() })
        $name    = $parts[0]
        $title   = $null
        $seconds = $null

        if ($parts.Count -eq 1 -and $name -match '^(?<exe>[^=]+?)\s*=\s*(?<title>.+)$') {
            $name  = $Matches.exe.Trim()
            $title = $Matches.title.Trim()
        }
        else {
            for ($pi = 1; $pi -lt $parts.Count; $pi++) {
                $part = $parts[$pi]
                if ([string]::IsNullOrWhiteSpace($part)) { continue }
                if ($part.Contains('=')) {
                    $title = ($part -split '=', 2)[1].Trim()
                    continue
                }
                if ($null -eq $seconds) {
                    $sec = ConvertTo-Seconds $part
                    if ($null -ne $sec -and $sec -gt 0) { $seconds = $sec; continue }
                }
                if (-not $title) { $title = $part }
            }
        }

        try { $name = [IO.Path]::GetFileName($name) } catch { $name = $null }
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        # Cari entri yang sudah ada (case-insensitive).
        $existing = $null
        foreach ($k in @($GameList.Keys)) {
            if ([string]::Equals($k, $name, [StringComparison]::OrdinalIgnoreCase)) { $existing = $k; break }
        }

        if ($existing) {
            # Judul bawaan jangan ditimpa kalau file hanya menyebut nama .exe.
            if ($title) { $GameList[$existing] = $title }
            $name = $existing
        }
        else {
            if (-not $title) { $title = [IO.Path]::GetFileNameWithoutExtension($name) }
            $GameList[$name] = $title
            $added++
        }

        if ($null -ne $seconds) { $GameDurations[$name] = $seconds }
        $fileGames.Add($name)
    }
    Write-Host ("Dari file '{0}': {1} nama game dibaca ({2} baru, {3} pakai durasi khusus)." -f `
        $GamesFile, $fileGames.Count, $added, $GameDurations.Count)
}

if ($ListGames) {
    Write-Section ("DAFTAR GAME TERSEDIA ({0})" -f $GameList.Count)
    Write-Host ''
    $i = 0
    foreach ($k in $GameList.Keys) {
        $i++
        Write-Host ('  {0,3}. ' -f $i) -NoNewline -ForegroundColor DarkGray
        Write-Host ('{0,-34}' -f $k) -NoNewline -ForegroundColor White
        Write-Host $GameList[$k] -ForegroundColor DarkGray
    }
    Write-Host ''
    Write-Host ("  Total: {0} nama game tersedia." -f $GameList.Count) -ForegroundColor Cyan
    return
}

# ------------------------------------------------------------------ riwayat & daftar skip
$history = @(Get-PlayedGames)

if ($ShowHistory) {
    Write-Section ("RIWAYAT GAME ({0})" -f $history.Count)
    if ($history.Count -eq 0) {
        Write-Host ''
        Write-Host '  Belum ada game yang tercatat pernah difarm.' -ForegroundColor DarkGray
    }
    else {
        Write-Host ''
        $i = 0
        foreach ($h in $history) {
            $i++
            Write-Host ('  {0,3}. ' -f $i) -NoNewline -ForegroundColor DarkGray
            Write-Host $h -NoNewline -ForegroundColor White
            Write-Host ('  (' + (Get-GameTitle $h) + ')') -ForegroundColor DarkGray
        }
    }
    Write-Host ''
    Write-Host ("  File riwayat: {0}" -f $HistoryFile) -ForegroundColor DarkGray
    return
}

if ($ResetHistory) {
    if (Test-Path -LiteralPath $HistoryFile) {
        Remove-Item -LiteralPath $HistoryFile -Force -ErrorAction SilentlyContinue
        Write-Host ''
        Write-Host '  Riwayat dihapus: semua game dianggap belum pernah dimainkan.' -ForegroundColor Green
    }
    else {
        Write-Host ''
        Write-Host '  Riwayat memang belum ada; tidak ada yang perlu dihapus.' -ForegroundColor DarkGray
    }
    return
}

$skipList = New-Object System.Collections.Generic.List[string]
foreach ($s in @($SkipGames)) {
    if ([string]::IsNullOrWhiteSpace($s)) { continue }
    foreach ($part in ($s -split ',')) {
        $n = ConvertTo-ExeName $part
        if ($n -and -not (Test-NameInList $n $skipList)) { $skipList.Add($n) }
    }
}
if ($SkipFile) {
    if (-not (Test-Path -LiteralPath $SkipFile)) {
        throw "File daftar skip tidak ditemukan: $SkipFile"
    }
    foreach ($n in (Read-NameFile $SkipFile)) {
        if (-not (Test-NameInList $n $skipList)) { $skipList.Add($n) }
    }
}

# ------------------------------------------------------------------ pilih game
if ($PSBoundParameters.ContainsKey('Games') -and $Games -and $Games.Count -gt 0) {
    # Dukung bentuk "a.exe,b.exe" (dari powershell -File) maupun array.
    $selected = @(
        $Games |
            ForEach-Object { $_ -split ',' } |
            ForEach-Object { ConvertTo-ExeName $_ } |
            Where-Object { $_ } |
            Select-Object -Unique
    )
    # Daftarkan judul untuk nama yang belum ada di daftar bawaan.
    foreach ($g in $selected) {
        $known = $false
        foreach ($k in @($GameList.Keys)) {
            if ([string]::Equals($k, $g, [StringComparison]::OrdinalIgnoreCase)) { $known = $true; break }
        }
        if (-not $known) { $GameList[$g] = [IO.Path]::GetFileNameWithoutExtension($g) }
    }
}
elseif ($fileGames.Count -gt 0) {
    $selected = @($fileGames | Select-Object -Unique)
}
else {
    $selected = @($GameList.Keys)
}

if ($Test) {
    # Mode uji selalu mengabaikan skip & riwayat supaya bisa diulang kapan saja.
    $selected = @('Terraria.exe')
    $Rounds   = 1
    if (-not $PSBoundParameters.ContainsKey('SecondsPerGame') -and
        -not $PSBoundParameters.ContainsKey('HoursPerGame')) {
        $SecondsPerGame = 60
    }
    Write-Host ''
    Write-Host '== MODE UJI: dummy "Terraria.exe" ==' -ForegroundColor Cyan
    Write-Host 'Pantau sekarang: profil/status Discord Anda harus menampilkan "Playing Terraria".' -ForegroundColor Cyan
}
else {
    # 1) Buang game yang ada di daftar skip manual.
    if ($skipList.Count -gt 0) {
        $listedSkip = @($selected | Where-Object { Test-NameInList $_ $skipList })
        $selected   = @($selected | Where-Object { -not (Test-NameInList $_ $skipList) })
        if ($listedSkip.Count -gt 0) {
            Write-Host ("  Dilewati (daftar skip, {0}): {1}" -f $listedSkip.Count, (Format-NameList $listedSkip)) -ForegroundColor DarkGray
        }
    }

    # 2) Buang game yang sudah pernah difarm (kecuali -IgnoreHistory).
    if (-not $IgnoreHistory -and $history.Count -gt 0) {
        $playedSkip = @($selected | Where-Object { Test-NameInList $_ $history })
        $selected   = @($selected | Where-Object { -not (Test-NameInList $_ $history) })
        if ($playedSkip.Count -gt 0) {
            Write-Host ("  Dilewati (sudah pernah dimainkan, {0}): {1}" -f $playedSkip.Count, (Format-NameList $playedSkip)) -ForegroundColor DarkGray
            Write-Host '  (pakai -IgnoreHistory untuk memfarm ulang game-game itu)' -ForegroundColor DarkGray
        }
    }

    # 3) Acak urutan (default). -InOrder untuk tetap berurutan.
    if (-not $InOrder -and $selected.Count -gt 1) {
        $selected = @($selected | Get-Random -Count $selected.Count)
    }
}

# Durasi: -SecondsPerGame menimpa -HoursPerGame (dilakukan sebelum prompt agar
# nilai ini bisa menjadi default saat -Ask).
if ($SecondsPerGame -gt 0) {
    $HoursPerGame = $SecondsPerGame / 3600.0
}

# -Ask: tanyakan jumlah game & durasi tepat sebelum farming dimulai.
if ($Ask -and -not $Test) {
    $defaultCount = if ($selected.Count -gt 0) { $selected.Count } else { 1 }
    if ($GameCount -gt 0 -and $GameCount -le $defaultCount) { $defaultCount = $GameCount }
    $GameCount = Read-GameCountInteractive -Available $selected.Count -Default $defaultCount

    # Durasi: nilai dari -SecondsPerGame / -HoursPerGame dipakai sebagai default.
    $SecondsPerGame = [int][math]::Round((Read-DurationInteractive -DefaultSeconds ($HoursPerGame * 3600.0)))
    Write-Host ''
}

# -GameCount membatasi jumlah game yang difarm (dihitung setelah skip & acak).
if ($GameCount -gt 0) {
    if ($GameCount -gt $selected.Count) {
        Write-Warning ("Anda minta {0} game, tapi hanya {1} game tersedia setelah skip. Memakai semua {1} game." -f $GameCount, $selected.Count)
    }
    else {
        $selected = @($selected | Select-Object -First $GameCount)
    }
}

# ------------------------------------------------------------------ validasi
if ($selected.Count -eq 0) {
    throw ('Tidak ada game yang tersisa untuk difarm (semua sudah pernah dimainkan atau ada di daftar skip). ' +
           'Gunakan -IgnoreHistory untuk memfarm ulang, -ResetHistory untuk menghapus riwayat, atau -ShowHistory untuk melihatnya.')
}
if ($HoursPerGame -le 0)   { throw '-HoursPerGame / -SecondsPerGame harus lebih dari 0.' }
if ($Rounds -lt 1)         { throw '-Rounds minimal 1.' }

$perGameSeconds = $HoursPerGame * 3600.0

# Durasi efektif tiap game (bisa berbeda-beda kalau -GamesFile memakai kolom durasi).
$durations   = @($selected | ForEach-Object { Get-GameSeconds $_ $perGameSeconds })
$minSeconds  = ($durations | Measure-Object -Minimum).Minimum
$maxSeconds  = ($durations | Measure-Object -Maximum).Maximum
$totalSeconds = ((($durations | Measure-Object -Sum).Sum) * $Rounds)
if ([math]::Abs($maxSeconds - $minSeconds) -lt 0.5) {
    $perGameDesc = Format-Duration $minSeconds
}
else {
    $perGameDesc = 'campuran ({0} s/d {1})' -f (Format-Duration $minSeconds), (Format-Duration $maxSeconds)
}

if ($minSeconds -lt 10) {
    Write-Warning ("Ada game dengan durasi {0}. Discord butuh beberapa detik untuk mendeteksi; di bawah ~15 detik hasilnya sering tidak tercatat." -f (Format-Duration $minSeconds))
}

if ($Preview) {
    Write-Section ("DAFTAR GAME ({0})" -f $selected.Count)
    Write-Host ''
    $n = 0
    foreach ($g in $selected) {
        $n++
        $sec = Get-GameSeconds $g $perGameSeconds
        Write-Host ('  {0,3}. ' -f $n) -NoNewline -ForegroundColor DarkGray
        Write-Host ('{0,-34}' -f $g) -NoNewline -ForegroundColor White
        Write-Host ('{0,-24}' -f (Get-GameTitle $g)) -NoNewline -ForegroundColor DarkGray
        Write-Host (Format-Duration $sec) -ForegroundColor DarkCyan
    }
    Write-Host ''
    Write-BoxEdge -Kind top -Color DarkCyan
    Write-BoxLine 'RINGKASAN RENCANA' 'Cyan' -Center
    Write-BoxLine ''
    Write-BoxLine ("Game        : {0} game x {1} putaran" -f $selected.Count, $Rounds)
    Write-BoxLine ("Per game    : {0}" -f $perGameDesc)
    Write-BoxLine ("Estimasi    : {0}" -f (Format-Duration $totalSeconds))
    Write-BoxEdge -Kind bottom -Color DarkCyan
    Write-Host ''
    Write-Host '  Mode preview: tidak ada proses yang dijalankan.' -ForegroundColor DarkGray
    return
}

New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
New-SleeperExe
Stop-FarmProcesses   # bersihkan sisa eksekusi terdahulu, jika ada

if (-not (Test-DiscordRunning)) {
    Write-Warning 'Discord desktop sepertinya belum berjalan. Jalankan Discord dan login dulu, kalau tidak waktu bermain tidak akan tercatat.'
}
else {
    Write-Log 'Discord terdeteksi sedang berjalan.'
}

Write-Log ("Rencana: {0} game x {1} putaran | {2} per game | total +-{3}" -f `
    $selected.Count, $Rounds, $perGameDesc, (Format-Duration $totalSeconds))
if (-not $Test -and -not $IgnoreHistory -and $history.Count -gt 0) {
    Write-Log ("Riwayat: {0} game sudah pernah difarm dan otomatis dilewati (-IgnoreHistory untuk memfarm ulang)." -f $history.Count)
}

$canReadKeys = Test-CanPrompt

Write-Host ''
Write-BoxEdge -Kind top -Color DarkCyan
Write-BoxLine 'RENCANA FARMING' 'Cyan' -Center
Write-BoxLine ''
Write-BoxLine ("Game        : {0} game x {1} putaran" -f $selected.Count, $Rounds)
Write-BoxLine ("Per game    : {0}" -f $perGameDesc)
Write-BoxLine ("Estimasi    : {0}" -f (Format-Duration $totalSeconds))
Write-BoxLine ("Window      : {0}" -f ($(if ($Hidden) { 'hidden' } else { 'terlihat' })))
if (-not $Test -and -not $IgnoreHistory -and $history.Count -gt 0) {
    Write-BoxLine ("Riwayat     : {0} dilewati" -f $history.Count)
}
Write-BoxEdge -Kind bottom -Color DarkCyan

if ($Ask -and $canReadKeys) {
    Write-Host ''
    $ans = Read-Host '  Mulai sekarang? [Y/n]'
    if (-not [string]::IsNullOrWhiteSpace($ans) -and $ans.Trim() -notmatch '^(y|ya|yes)$') {
        Write-Host '  Dibatalkan. Tidak ada yang dijalankan.' -ForegroundColor Yellow
        return
    }
}

if ($canReadKeys) {
    Write-Host ''
    Write-Host '  Tekan [S] untuk melewati game yang sedang berjalan, [Ctrl+C] untuk berhenti.' -ForegroundColor DarkGray
}

# ------------------------------------------------------------------ loop utama
$argList  = '-n 999999999 127.0.0.1'   # argumen untuk fallback ping.exe (diabaikan sleeper.exe)
$winStyle = if ($Hidden) { 'Hidden' } else { 'Normal' }
$proc     = $null
$total    = $selected.Count
$done     = New-Object System.Collections.Generic.List[string]
$failed   = New-Object System.Collections.Generic.List[string]
$startTime = Get-Date

try {
    for ($round = 1; $round -le $Rounds; $round++) {
        $i = 0
        foreach ($game in $selected) {
            $i++
            $title = Get-GameTitle $game
            $exe   = Join-Path $WorkDir $game

            # Durasi game ini (bisa beda per game).
            $gameSeconds = Get-GameSeconds $game $perGameSeconds
            $sleepMs     = [int][math]::Round($gameSeconds * 1000.0)
            if ($sleepMs -lt 1000) { $sleepMs = 1000 }

            if (-not (Test-DiscordRunning)) {
                Write-Log ("PERINGATAN: Discord tidak berjalan saat farming '{0}' - waktu mungkin tidak tercatat." -f $title)
            }

            try {
                if (-not (Test-Path -LiteralPath $DummyExe)) { New-SleeperExe }
                Copy-Item $DummyExe $exe -Force
                $proc = Start-Process -FilePath $exe -ArgumentList $argList -WindowStyle $winStyle -PassThru
            }
            catch {
                # sleeper.exe bisa hilang di tengah jalan (mis. dibersihkan AV/user).
                # Bangun ulang sekali, lalu coba lagi.
                try {
                    New-SleeperExe -Force
                    Copy-Item $DummyExe $exe -Force
                    $proc = Start-Process -FilePath $exe -ArgumentList $argList -WindowStyle $winStyle -PassThru
                    Write-Log 'sleeper.exe tidak ditemukan; sudah dibuat ulang dan farming dilanjutkan.'
                }
                catch {
                    Write-Log ("GAGAL menjalankan {0}: {1}" -f $game, $_.Exception.Message)
                    $failed.Add($game)
                    continue
                }
            }

            Write-Log ("Putaran {0}/{1} | game {2}/{3} : {4} [{5}] selama {6} (PID {7})" -f `
                $round, $Rounds, $i, $total, $title, $game, (Format-Duration $gameSeconds), $proc.Id)

            $overall = (($round - 1) * $total) + $i
            $label   = ('{0}/{1}  {2}' -f $overall, ($total * $Rounds), $title)
            $waitResult = Wait-GameDuration -Milliseconds $sleepMs -Label $label
            Clear-ProgressLine

            if (Test-ProcAlive $proc) {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                Start-Sleep -Milliseconds 300
            }
            Remove-Item $exe -Force -ErrorAction SilentlyContinue

            if ($waitResult -eq 'skipped') {
                Write-Log ("  -> '{0}' dilewati lebih awal (tombol S)." -f $title)
            }

            # Catat ke riwayat agar tidak difarm ulang pada eksekusi berikutnya.
            # (Mode -Test tidak mencatat, supaya uji coba tidak "menghanguskan" game.)
            if (-not $Test) { Add-PlayedGame $game }
            $done.Add($game)
        }
    }

    $elapsed = ((Get-Date) - $startTime).TotalSeconds
    Write-Log ("Selesai: {0} game diproses ({1} berhasil, {2} gagal)." -f $done.Count, $done.Count, $failed.Count)
    if ($failed.Count -gt 0) {
        Write-Log ("Game gagal dijalankan: {0}" -f (Format-NameList $failed))
    }
    Write-Log ("Total waktu farming: {0}." -f (Format-Duration $elapsed))

    Write-Host ''
    Write-BoxEdge -Kind top -Color Green
    Write-BoxLine 'SELESAI' 'Green' -Center
    Write-BoxLine ''
    Write-BoxLine ("Berhasil     : {0} game" -f $done.Count)
    Write-BoxLine ("Gagal        : {0} game" -f $failed.Count)
    Write-BoxLine ("Total waktu  : {0}" -f (Format-Duration $elapsed))
    if (-not $Test) {
        Write-BoxLine ("Riwayat      : {0} game" -f (@(Get-PlayedGames).Count))
    }
    Write-BoxEdge -Kind bottom -Color Green
}
finally {
    Clear-ProgressLine
    if (Test-ProcAlive $proc) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    Stop-FarmProcesses
    Write-Log 'Script berhenti.'
    Write-Host ''
    Write-Host ('  ' + $script:Copyright) -ForegroundColor DarkGray
}
