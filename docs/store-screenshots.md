# Store-Screenshots für Munir

Acht Bilder, 1080 × 2400, aufgenommen auf einem Pixel-8-Emulator mit Standort
Berlin. Rohdateien liegen in `artifacts/screenshots/` (gitignored, per
`tool/capture_screenshots.ps1` reproduzierbar).

## Reihenfolge und Text

Google Play zeigt die ersten zwei Bilder direkt in der Suchergebnisliste, den
Rest erst nach dem Öffnen der Detailseite. Die Reihenfolge ist deshalb nicht
beliebig: was die App im Kern ist, muss auf Bild 1 und 2 stehen.

Die Überschrift gehört über den Screenshot, nicht hinein. Drei bis fünf Wörter,
gross gesetzt — in der Liste ist das Bild rund 3 cm breit, ganze Sätze sind
dort unlesbar.

| # | Datei | Überschrift | Warum an dieser Stelle |
|---|---|---|---|
| 1 | `01-home.png` | **Nie wieder eine Gebetszeit verpassen** | Der Countdown ist das, was die App täglich tut. Sofort verständlich, ohne die App zu kennen. |
| 2 | `02-gebetszeiten.png` | **Alle fünf Zeiten für deinen Ort** | Beantwortet die naheliegendste Frage vor dem Installieren: stimmen die Zeiten bei mir? |
| 3 | `03-moscheen.png` | **Moscheen in deiner Nähe** | Konkreter Nutzen unterwegs, mit dem Suchradius massstabsgetreu auf der Karte. |
| 4 | `04-quran.png` | **Lesen, hören, Fortschritt behalten** | Zeigt Tiefe — die App ist mehr als eine Uhr. |
| 5 | `05-tasbih.png` | **Dhikr zählen, ohne nachzudenken** | Kleine Funktion, hohe Nutzung. |
| 6 | *ersetzen* | **Abhaken, was du gebetet hast** | Siehe unten — `07-adhan.png` bewirbt eine Funktion, die es nicht mehr gibt. Der Tracker mit Streak ist der naheliegende Ersatz. |
| 7 | `08-sprachen.png` | **Deutsch, Englisch, Türkisch, Arabisch, Französisch** | Fängt alle ab, die die App nicht auf Deutsch wollen. |
| 8 | *fehlt* | **Die Qibla, geografisch genau** | Siehe unten — muss auf einem echten Gerät entstehen. |

`06-einstellungen.png` liegt als Reserve daneben, falls eines der acht
ausgetauscht werden soll.

## `07-adhan.png` muss raus

Der Screenshot zeigt die Auswahl der Muezzin-Stimme und die Überschrift warb
damit als Unterscheidungsmerkmal. Die Auswahl ist entfernt: sie hat nie etwas
bewirkt — es gibt keine Adhan-Audiodateien in der App, und der gespeicherte
Wert wurde von der Benachrichtigung nie gelesen. Jede Option, „Stumm"
eingeschlossen, ergab den Systemton.

Bleibt das Bild in der Listung, wirbt der Eintrag mit einer Funktion, die die
App nicht hat. Das ist bei Apple Guideline 2.3.1 und bei Play „Misleading
claims" — und es ist einer der wenigen Punkte, die einem Prüfer beim
Vergleich von Listung und App sofort auffallen.

Ersatz ohne neue Aufnahme: `06-einstellungen.png` aus der Reserve. Besser
wäre ein Bild des Gebets-Trackers mit sichtbarer Streak.

## Für den App Store nochmal aufnehmen

Die acht vorhandenen Bilder sind 1080 × 2400 vom Pixel-8-Emulator. Apple
verlangt iPhone-Formate — 6,9 Zoll, 1290 × 2796 oder 1320 × 2868. Das
Seitenverhältnis passt nicht, die Bilder werden abgelehnt.

Auf einem echten iPhone ist das kein Aufwand: TestFlight-Build installieren,
die Bildschirme durchgehen, Lauter + Seitentaste. Der Qibla-Screenshot, der
für Play noch fehlt, entsteht dabei gleich mit — auf einem echten Gerät
liegt ein echter Standort vor, was auf dem Emulator gescheitert ist.

## Gestaltung

Ein Look über alle acht, sonst wirkt die Liste zusammengewürfelt.

- Hintergrund: Verlauf aus den App-Farben `#16402D` (Dunkelgrün) nach `#0E2A1D`,
  Überschrift in `#F5EFE3`, Akzente in `#B8894A` (Gold).
- Geräterahmen: schlicht und dunkel, damit der helle App-Hintergrund
  (`#FAF7F0`) trägt.
- Screenshot nicht randlos setzen — rundum Luft, sonst wirkt es gedrängt.
- Statusleiste im Screenshot behalten. Sie kostet nichts und lässt das Bild
  echt statt gerendert aussehen.

## Qibla fehlt noch (Play)

Der Qibla-Kompass liess sich auf dem Emulator nicht aufnehmen. Die App
verweigert die Anzeige bewusst, solange kein echter Standort vorliegt — ein
Fallback-Ort würde eine falsche Gebetsrichtung anzeigen, und das wäre schlimmer
als gar keine. Auf dem Emulator kommt kein echter Standort zustande:
`adb emu geo fix` quittiert zwar mit `OK`, die Position erreicht den
Fused-Location-Provider aber nicht, und die Stadtsuche scheitert am fehlenden
Geocoder-Backend des Images.

Auf einem echten Android-Gerät ist es ein Handgriff: App öffnen, Reiter Qibla,
Screenshot. Als Bild 3 einsortieren — die Qibla ist das visuell stärkste
Argument der App.

## Was noch fehlt

- **Feature-Grafik 1024 × 500.** Erscheint über der Listung. Logo, `Munir`, ein
  Halbsatz, derselbe Verlauf. Kein Geräterahmen — Play beschneidet die Grafik
  je nach Platzierung an den Rändern.
- **App-Icon 512 × 512 PNG.** Vorhanden unter
  `android/app/src/main/res/mipmap-xxxhdpi/` — vor dem Hochladen prüfen, ob es
  in 512 × 512 sauber skaliert, sonst aus der Quelldatei neu exportieren.

## Screenshots neu aufnehmen

```powershell
flutter build apk --release
```

```powershell
tool\capture_screenshots.ps1
```

Setzt einen laufenden Emulator voraus (`flutter emulators --launch Pixel_8`).
