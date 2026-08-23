# Munir

Gebetszeiten, Qibla und Qur'an — eine Flutter-App für Android und iOS.

Munir rechnet Gebetszeiten und Qibla-Richtung auf dem Gerät aus. Ein Konto ist
optional und dient allein dem Abgleich zwischen mehreren Geräten. Keine
Werbung, keine Nutzungsanalyse.

## Funktionen

- **Gebetszeiten** für den aktuellen Standort, mit wählbarer Berechnungsmethode
  und Madhhab, inklusive Sonderbehandlung hoher Breitengrade.
- **Erinnerungen** je Gebet, lokal geplant, mit Uhrzeit und Ort im Text und
  einer Nachfrage, wenn ein Gebet noch nicht eingetragen ist.
- **Qibla-Kompass** auf Basis der geografischen Nordrichtung, der bei
  unzuverlässigem Sensor lieber gar nichts anzeigt als etwas Falsches.
- **Qur'an** mit Text, Transliteration, Übersetzung, Rezitation und
  gespeichertem Lesefortschritt.
- **Moscheen in der Nähe** über OpenStreetMap — erst nach ausdrücklicher
  Zustimmung, weil dafür der Standort das Gerät verlässt.
- **Tracker** für verrichtete Gebete, Streak und Tasbih.
- Fünf Sprachen: Deutsch, Englisch, Türkisch, Arabisch, Französisch.

## Entwicklung

```bash
flutter pub get
flutter run
```

Prüfen, was die CI auch prüft:

```bash
flutter analyze && flutter test
```

### Firebase

`lib/firebase_options.dart`, `android/app/google-services.json` und
`ios/Runner/GoogleService-Info.plist` liegen nicht im Repository — es ist
öffentlich. Lokal kommen sie aus der Firebase Console, in der CI aus
Repository-Secrets.

## Aufbau

```
lib/
├── core/          # Modelle, Provider, Services, Theme, i18n-Hilfen
├── features/      # je Bereich ein Ordner: prayers, qibla, quran, mosques, …
└── l10n/          # ARB-Dateien und generierte Localizations
tool/              # Generatoren, u. a. die veröffentlichten Rechtsseiten
test/              # Unit- und Widget-Tests
```

Zustand läuft über Riverpod. Die Provider in `lib/core/providers/` sind die
einzige Quelle für Standort, Gebetszeiten und Einstellungen; Screens rechnen
nicht selbst.

## Veröffentlichung

| Workflow | Ergebnis |
|---|---|
| `.github/workflows/android-aab.yml` | signiertes App Bundle für Google Play |
| `.github/workflows/ios-ipa.yml` | unsignierte IPA |
| `.github/workflows/pages.yml` | Datenschutz, Impressum und Konto-Löschung auf GitHub Pages |

Die Rechtsseiten werden aus denselben Dart-Werten erzeugt, die die App
anzeigt (`lib/features/legal/legal_documents.dart`), damit veröffentlichter
Text und App-Text nicht auseinanderlaufen können.

Schritt für Schritt zum Play-Release: [docs/play-release.md](docs/play-release.md).
Rechtliches und Store-Angaben: [docs/store-compliance-legal.md](docs/store-compliance-legal.md).

## Datenquellen

- Gebetszeiten und Qibla: lokal berechnet
- Moscheen: [Overpass API](https://overpass-api.de) / OpenStreetMap
- Kartenkacheln: [CARTO](https://carto.com) Positron
- Qur'an: [alquran.cloud](https://alquran.cloud)
