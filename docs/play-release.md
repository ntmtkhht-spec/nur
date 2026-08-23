# Munir bei Google Play veröffentlichen

Stand: 23. August 2026

Schritt für Schritt vom Repository zur Veröffentlichung. Die Punkte unter
"Einmalig" fallen nur beim ersten Release an, danach genügt "Jedes Release".

Was rechtlich hineingehört, steht in
[store-compliance-legal.md](store-compliance-legal.md). Diese Datei ist keine
Rechtsberatung.

---

## Einmalig

### 1. Play Console — erledigt

Entwicklerkonto besteht. Falls die App dort noch nicht angelegt ist: Name
`Munir`, Standardsprache Deutsch, Typ App, kostenlos.

### 2. Rechtsseiten veröffentlichen — erledigt

Die Seiten werden aus der App heraus erzeugt und liegen auf GitHub Pages.
Pages ist aktiviert (Source: GitHub Actions, HTTPS erzwungen) und
`.github/workflows/pages.yml` veröffentlicht sie bei jeder Änderung an
`lib/features/legal/` neu. Hier ist nichts mehr zu tun.

Erreichbar unter:

| Zweck | URL |
|---|---|
| Datenschutzerklärung | <https://ntmtkhht-spec.github.io/nur/index.html> |
| Impressum | <https://ntmtkhht-spec.github.io/nur/impressum.html> |
| Konto löschen | <https://ntmtkhht-spec.github.io/nur/konto-loeschen.html> |

Alle drei antworten mit HTTP 200 ohne Anmeldung — geprüft mit `curl`, das
weder Cookies noch Zugangsdaten mitschickt und damit genau das nachweist, was
Play verlangt. Nachprüfen lässt sich das jederzeit:

```bash
curl -sI https://ntmtkhht-spec.github.io/nur/index.html | head -1
```

Ändert sich der Repository-Name oder wird das Repository privat, brechen diese
URLs — dann lehnt Play die Einreichung ab, und `legal_profile.dart` muss
nachgezogen werden.

### 3. Upload-Keystore erzeugen

Der Schlüssel signiert jedes Bundle. **Geht er verloren, lässt sich Munir bei
Play nie wieder aktualisieren** — es gibt keinen Reset, nur einen langwierigen
Antrag bei Google. Datei und Passwort gehören in einen Passwortmanager oder ein
Backup, nicht nur auf diesen Rechner.

Ausserhalb des Repositorys ablegen, damit er weder versehentlich commitet wird
noch mit dem Projektordner verschwindet:

```bash
mkdir -p ~/keys
```

```bash
keytool -genkey -v -keystore ~/keys/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`keytool` liegt beim JDK, das Flutter ohnehin braucht. Das Kommando fragt der
Reihe nach:

| Frage | Eintrag |
|---|---|
| Keystore-Passwort (zweimal) | frei wählbar |
| Vor- und Nachname | der Name aus dem Impressum |
| Organisationseinheit, Organisation | leer lassen genügt |
| Stadt, Bundesland, Ländercode | `Oldenburg`, `Niedersachsen`, `DE` |
| Kennwort für `upload` | Enter — übernimmt das Keystore-Passwort |

Diese Angaben landen im Zertifikat, nicht im Store-Eintrag.

### 4. Secrets hinterlegen

`GOOGLE_SERVICES_JSON` und `FIREBASE_OPTIONS_DART` liegen schon vom
iOS-Workflow vor. Es fehlen die vier `ANDROID_*`.

Keystore nach Base64, weil ein Secret nur Text aufnimmt:

```bash
base64 -w0 ~/keys/upload-keystore.jks > ~/keys/keystore.base64.txt
```

Dann setzen, aus dem Repository-Ordner heraus:

```bash
gh secret set ANDROID_KEYSTORE_BASE64 < ~/keys/keystore.base64.txt
```

```bash
gh secret set ANDROID_KEYSTORE_PASSWORD
```

```bash
gh secret set ANDROID_KEY_PASSWORD
```

```bash
gh secret set ANDROID_KEY_ALIAS --body upload
```

Die beiden Passwort-Befehle fragen interaktiv und zeigen nichts an — so landet
das Passwort weder in der Shell-History noch in einer Datei. Beide Male
dasselbe Passwort, sofern bei "Kennwort für upload" Enter gedrückt wurde.

Danach die Base64-Datei löschen, die `.jks` behalten:

```bash
rm ~/keys/keystore.base64.txt
```

Über die Weboberfläche geht es auch: **Settings → Secrets and variables →
Actions → New repository secret**, vier Einträge mit genau diesen Namen.

Prüfen, ob alle stehen:

```bash
gh secret list
```

### 5. Lokal bauen (optional)

Für einen signierten Build auf dem eigenen Rechner `android/key.properties`
anlegen — gitignored:

```properties
storeFile=/c/Users/<name>/keys/upload-keystore.jks
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
