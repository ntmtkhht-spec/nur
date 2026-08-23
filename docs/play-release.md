# Munir bei Google Play veröffentlichen

Stand: 23. August 2026

Schritt für Schritt vom Repository zur Veröffentlichung. Die Punkte unter
"Einmalig" fallen nur beim ersten Release an, danach genügt "Jedes Release".

Was rechtlich hineingehört, steht in
[store-compliance-legal.md](store-compliance-legal.md). Diese Datei ist keine
Rechtsberatung.

---

## Einmalig

### 1. Play Console

- Entwicklerkonto anlegen: <https://play.google.com/console> — einmalig 25 USD.
- Für private Entwicklerkonten verlangt Google eine Identitätsprüfung, und die
  öffentlich sichtbare Anschrift ist dieselbe, die auch im Impressum steht.
  Das dauert erfahrungsgemäß einige Tage, also früh anstoßen.
- App anlegen: Name `Munir`, Standardsprache Deutsch, Typ App, kostenlos.

### 2. Rechtsseiten veröffentlichen

Die Seiten werden aus der App heraus erzeugt und liegen auf GitHub Pages.

Einmal im Repository aktivieren: **Settings → Pages → Source: GitHub Actions**.
Danach den Workflow `Publish legal pages` einmal von Hand starten
(**Actions → Publish legal pages → Run workflow**).

Danach erreichbar unter:

| Zweck | URL |
|---|---|
| Datenschutzerklärung | <https://ntmtkhht-spec.github.io/nur/index.html> |
| Impressum | <https://ntmtkhht-spec.github.io/nur/impressum.html> |
| Konto löschen | <https://ntmtkhht-spec.github.io/nur/konto-loeschen.html> |

Beide Pflicht-URLs prüfen: in einem privaten Fenster öffnen, ohne Login. Ist
eine davon nicht erreichbar, lehnt Play die Einreichung ab.

### 3. Upload-Keystore erzeugen

Der Schlüssel signiert jedes Bundle. **Geht er verloren, lässt sich die App
nicht mehr aktualisieren** — sichere ihn in einem Passwortmanager, nicht nur
auf dem Rechner. Er gehört nicht ins Repository; `.gitignore` hält
`android/key.properties` und `android/app/upload-keystore.jks` bereits heraus.

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`keytool` liegt beim JDK, das Flutter ohnehin braucht. Das Kommando fragt nach
einem Passwort und nach Name und Anschrift; die landen im Zertifikat, nicht im
Store-Eintrag.

### 4. Secrets hinterlegen

**Settings → Secrets and variables → Actions → New repository secret.**

| Secret | Inhalt |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | die `.jks` als Base64, siehe unten |
| `ANDROID_KEYSTORE_PASSWORD` | das Keystore-Passwort aus Schritt 3 |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | das Key-Passwort (meist dasselbe) |
| `GOOGLE_SERVICES_JSON` | `android/app/google-services.json` als Base64 |
| `FIREBASE_OPTIONS_DART` | `lib/firebase_options.dart` als Base64 |

Die letzten beiden existieren schon vom iOS-Workflow.

Base64 erzeugen:

```bash
base64 -w0 upload-keystore.jks > keystore.base64.txt
```

Auf Windows in PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Content keystore.base64.txt
```

Inhalt der Datei einfügen, danach `keystore.base64.txt` löschen.

### 5. Lokal bauen (optional)

Für einen signierten Build auf dem eigenen Rechner `android/key.properties`
anlegen — gitignored:

```properties
storeFile=../upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

Fehlt die Datei, greift bewusst der Debug-Key, damit `flutter run --release`
auf einem Rechner ohne Keystore weiterhin funktioniert. Play nimmt so ein
Bundle nicht an; der Workflow prüft das eigens.

### 6. Store-Eintrag ausfüllen

Grafiken, die Play verlangt:

| Asset | Format |
|---|---|
| App-Icon | 512 × 512 PNG, 32 bit |
| Feature-Grafik | 1024 × 500 PNG oder JPG |
| Screenshots Smartphone | mindestens 2, je 320–3840 px Kantenlänge |

Screenshots lassen sich aus dem Emulator ziehen; naheliegend sind
Gebetszeiten, Qibla-Kompass, Qur'an-Lesebereich und Moscheen-Karte.

Texte:

- Kurzbeschreibung, höchstens 80 Zeichen
- Vollständige Beschreibung, höchstens 4000 Zeichen
- Kategorie: Lifestyle oder Bildung
- Kontakt-E-Mail: siehe `lib/features/legal/legal_profile.dart`

Fragebögen:

- **Inhaltseinstufung** — Munir enthält keine problematischen Inhalte.
- **Data safety** — die Antworten stehen ausformuliert in
  [store-compliance-legal.md](store-compliance-legal.md#google-play).
- **Zielgruppe** — nicht an Kinder gerichtet.
- **Konto- und Datenlöschung** — die URL aus Schritt 2 angeben.
- **Berechtigungen** — der genaue Standort wird für Gebetszeiten und Qibla
  begründet, `SCHEDULE_EXACT_ALARM` mit den zeitgebundenen Erinnerungen.

---

## Jedes Release

1. `version:` in `pubspec.yaml` erhöhen. Die Zahl hinter dem `+` ist der
   `versionCode` und **muss** bei jedem Upload steigen — Play weist ein Bundle
   mit einem bereits verwendeten `versionCode` ab.
2. Nach `master` pushen. Der Workflow `Build Android App Bundle` läuft
   automatisch, prüft `flutter analyze` und `flutter test`, baut das signierte
   Bundle und stellt sicher, dass es nicht mit dem Debug-Key signiert ist.
3. Bundle herunterladen:

   ```bash
   gh run download --name munir-play-aab
   ```

4. In der Play Console unter **Testen → Interner Test** hochladen und selbst
   installieren, bevor es in die Produktion geht.
5. Aus dem internen Test in die Produktion überführen. Die erste Prüfung durch
   Google dauert meist einige Tage.

---

## Was noch nicht eingerichtet ist

- **Automatischer Upload in die Play Console.** Das Bundle wird gebaut und als
  Artifact abgelegt, aber von Hand hochgeladen. Automatisieren ließe sich das
  über einen Service-Account und die Play Developer API; das lohnt erst, wenn
  regelmäßig Releases anstehen.
- **iOS.** Der IPA-Workflow baut unsigniert und reicht für Sideloading, nicht
  für den App Store. Dafür brauchte es einen bezahlten Apple-Developer-Account
  sowie Zertifikat und Provisioning Profile als Secrets.
