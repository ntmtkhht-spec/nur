<#
.SYNOPSIS
    Nimmt Play-Store-Screenshots von Munir auf einem laufenden Android-Emulator auf.

.DESCRIPTION
    Deckt die fünf Reiter der unteren Navigation ab — das ist der Teil, der sich
    zuverlässig automatisieren lässt, weil die Schaltflächen dort feste
    Bildschirmpositionen haben. Alles, was erst über mehrere Taps erreichbar ist
    (Moscheen-Karte, Suren-Lesebereich), steht unten als Handgriff.

    Voraussetzungen:
      - Emulator läuft:      flutter emulators --launch Pixel_8
      - Release-APK gebaut:  flutter build apk --release
      - Zeitzone im Emulator auf Europe/Berlin, sonst zeigen die Gebetszeiten
        UTC und wirken für deutsche Nutzer falsch.

.PARAMETER OutDir
    Zielordner. Standard: artifacts\screenshots

.PARAMETER SkipInstall
    Überspringt die Neuinstallation der APK.
#>
param(
    [string] $OutDir = "artifacts\screenshots",
    [switch] $SkipInstall
)

$ErrorActionPreference = "Stop"

$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { throw "adb nicht gefunden: $adb" }

$devices = & $adb devices | Select-String "emulator-\d+\s+device"
if (-not $devices) { throw "Kein Emulator verbunden. Erst: flutter emulators --launch Pixel_8" }

New-Item -ItemType Directory -Force $OutDir | Out-Null

if (-not $SkipInstall) {
    $apk = "build\app\outputs\flutter-apk\app-release.apk"
    if (-not (Test-Path $apk)) { throw "APK fehlt. Erst: flutter build apk --release" }
    Write-Host "Installiere $apk ..."
    & $adb install -r $apk | Out-Null
}

# Ohne diese Berechtigungen fragt die App beim ersten Start per Systemdialog,
# der dann mitten im Screenshot steht.
foreach ($p in @(
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.POST_NOTIFICATIONS")) {
    & $adb shell pm grant com.munir.app $p 2>$null
}

& $adb shell am force-stop com.munir.app
& $adb shell am start -n com.munir.app/.MainActivity | Out-Null
Start-Sleep -Seconds 11

# Bildschirmpositionen der unteren Navigation auf 1080 x 2400.
$tabs = [ordered]@{
    "01-home"          = 141
    "02-gebetszeiten"  = 341
    "05-tasbih"        = 739
    "09-qibla"         = 937
}

foreach ($name in $tabs.Keys) {
    & $adb shell input tap $tabs[$name] 2253
    Start-Sleep -Seconds 5
    $path = Join-Path $OutDir "$name.png"
    # exec-out liefert die PNG-Bytes roh; Out-File würde sie als Text zerstören.
    & $adb exec-out screencap -p | Set-Content $path -Encoding Byte
    Write-Host "  $path"
}

Write-Host ""
Write-Host "Von Hand nachziehen:"
Write-Host "  03-moscheen  Start -> nach unten wischen -> Kachel Moscheen"
Write-Host "               (braucht 'Moscheesuche erlauben' in den Einstellungen)"
Write-Host "  04-quran     Reiter Qur'an -> erste Sure antippen"
Write-Host "  09-qibla     Zeigt auf dem Emulator nur den Hinweistext:"
Write-Host "               'adb emu geo fix' erreicht den Fused-Location-Provider"
Write-Host "               nicht, und ohne echten Standort verweigert die App die"
Write-Host "               Qibla-Anzeige. Auf einem echten Gerät aufnehmen."
