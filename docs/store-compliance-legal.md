# Munir Store- und Rechts-Checkliste

Stand: 25. August 2026

Diese Datei ist keine Rechtsberatung. Sie dokumentiert, was vor der Einreichung
bei Apple App Store und Google Play noch auszufuellen oder im Store-Backend
anzugeben ist.

## Stand der Pflichtangaben

Alle Angaben in `lib/features/legal/legal_profile.dart` sind gesetzt:
Betreiber, ladungsfaehige Anschrift, E-Mail und Telefon. Register, UST-ID und
eine verantwortliche Person nach § 18 Abs. 2 MStV entfallen, weil Munir von
einer Privatperson ohne journalistische Inhalte angeboten wird.

Datenschutz-URL und Konto-Loesch-URL zeigen auf GitHub Pages:

- https://ntmtkhht-spec.github.io/nur/index.html
- https://ntmtkhht-spec.github.io/nur/impressum.html
- https://ntmtkhht-spec.github.io/nur/konto-loeschen.html

Die Seiten werden von `.github/workflows/pages.yml` aus
`lib/features/legal/legal_documents.dart` erzeugt — derselben Quelle, aus der
die App ihre Rechtstexte rendert. Der Text kann deshalb nicht auseinander
laufen, und ein Platzhalter in einer der beiden Fassungen ist ausgeschlossen.

Vor der Einreichung beide URLs in einem privaten Fenster oeffnen: eine
Datenschutz-URL, die nur eingeloggt erreichbar ist, ist ein Rejection-Grund.

## Apple App Store

- App Store Connect braucht eine Privacy Policy URL.
- Die In-App-Datenschutzerklaerung muss erklaeren, welche Daten gesammelt
  werden, wofuer sie genutzt werden, ob sie geteilt werden und wie Nutzer ihre
  Daten loeschen koennen.
- Da Munir optional Google/Firebase-Login anbietet, muss die App auch eine
  In-App-Kontoloeschung anbieten. Das ist aktuell unter
  `Einstellungen > Konto > Konto loeschen` vorhanden.
- In App Privacy Details muessen die tatsaechlichen Datenfluesse deklariert
  werden: Standort, User ID/Auth-ID, E-Mail-Adresse bei Login, Name/Tracker/
  Lesefortschritt/Einstellungen bei Sync, Diagnosedaten nur falls spaeter ein
  SDK hinzukommt.
- **Guideline 4.8 — App-Seite erledigt, Backend-Seite offen.** Neben Google
  wird auf iOS jetzt Sign in with Apple angeboten
  (`FeatureFlags.appleSignInEnabled = true`); das Entitlement steht in
  `ios/Runner/Runner.entitlements` und ist in allen drei
  Build-Konfigurationen verdrahtet. Damit der Knopf nicht schlimmer ist als
  gar keiner, muss vor der Einreichung noch:
  Apple als Sign-in-Provider in der Firebase-Konsole aktiviert sein, eine
  Services-ID samt Key unter Sign in with Apple im Apple-Developer-Portal
  angelegt sein (mit der Firebase-Callback-URL), die Capability an der App-ID
  haengen — und der Flow einmal auf einem echten Geraet gelaufen sein, wofuer
  es einen Mac braucht. Ohne das scheitert er an `signInWithCredential` und
  zeigt nur die generische Anmeldefehler-Meldung.
- Die fuenf `ios/Runner/<lang>.lproj/InfoPlist.strings` muessen in Xcode dem
  Runner-Target hinzugefuegt werden, sonst liest iOS sie nicht und der
  Standort-Dialog bleibt bei der deutschen Fassung aus der Info.plist.

## Google Play

- Google Play Console braucht die Data safety Angaben passend zur App.
- Google Play braucht eine Privacy Policy, wenn personenbezogene oder sensible
  Nutzerdaten verarbeitet werden. Standort und Konto reichen dafuer aus.
- Wenn eine App Konten erstellen laesst, muss es in der App und ueber eine
  oeffentliche Webseite eine Moeglichkeit zur Konto- und Datenloeschung geben.
- Die Play-Console-Antworten sollten aktuell ungefaehr so aussehen:
  - Standort: erfasst, **ungefaehrer Standort** (nicht praezise), fuer
    App-Funktionalitaet, nicht fuer Werbung, nicht verkauft. Die App
    deklariert unter Android nur `ACCESS_COARSE_LOCATION`.
  - Personenbezogene Daten: E-Mail/Name nur bei optionalem Login bzw. Sync.
  - App-Aktivitaet: Gebets-Tracker, Tasbih-Zahl und Qur'an-Lesefortschritt,
    nur bei optionalem Sync in Firebase.
  - Keine Werbung, kein Analytics-SDK, kein Verkauf von Daten.
  - Datenloeschung: In-App-Pfad und oeffentliche Loesch-URL angeben.

## Datenfluesse in Munir

- Lokal: Sprache, Name, Standort, Berechnungsmethode, Madhhab,
  Benachrichtigungseinstellungen, Gebets-Tracker, Moschee-Cache.
- Standort: nur ungefaehr (`LocationAccuracy.low`, Android fordert
  ausschliesslich `ACCESS_COARSE_LOCATION`). Gebetszeiten und Qibla-Peilung
  werden lokal berechnet. Ausnahme iOS: der Qibla-Kompass laesst Core
  Location mit `kCLLocationAccuracyBest` laufen, weil `trueHeading` sonst
  ungueltig bleibt — deshalb deklariert `PrivacyInfo.xcprivacy` weiterhin
  `PreciseLocation`. Unter Android kommt die Richtung aus dem
  Rotationsvektor-Sensor, ganz ohne Standortabfrage.
- Moschee-Suche: nur nach Zustimmung; Koordinaten und Radius an Overpass API.
- Karten: CARTO-Kacheln werden geladen; Karten-Cache kann in Einstellungen
  geloescht werden.
- Qur'an: Surah-Liste, Texte, Uebersetzungen, Transliteration und Audio von
  `https://api.alquran.cloud/v1`.
- Konto: optional Google Sign-In oder Sign in with Apple, beides ueber
  Firebase Auth. Sign in with Apple erscheint nur auf iOS.
- Sync: Firebase Cloud Firestore speichert Tracker, Tasbih-Gesamtzahl,
  Qur'an-Lesefortschritt, Name, Sprache, updatedAt.
- Benachrichtigungen: lokal geplant, keine eigenen Push-Inhalte an Server.

## Quellen

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Google Play User Data policy: https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play account deletion: https://support.google.com/googleplay/android-developer/answer/13327111
- § 5 Digitale-Dienste-Gesetz: https://www.gesetze-im-internet.de/ddg/__5.html
- DSGVO Art. 13: https://eur-lex.europa.eu/eli/reg/2016/679/oj

## Lizenzen der eingebundenen Dienste

Diese Punkte betreffen vor allem die geplante monetarisierte Version.

- **Qur'an-Text:** frei, auch kommerziell. Al Quran Cloud bittet um eine
  Quellenangabe im Kolophon — steht jetzt am Ende jeder Sure.
- **Uebersetzungen:** Al Quran Cloud verlangt die namentliche Nennung des
  Uebersetzers. Ebenfalls im Kolophon.
- **Rezitationen:** duerfen laut Al Quran Cloud in ein kommerzielles Produkt
  gebuendelt werden, die Rechte liegen aber bei den Rezitatoren, die eine
  Entfernung verlangen koennen. Fuer ein bezahltes Produkt einen Plan B
  vorsehen.
- **Suren-Namen-Font (QUL V4):** auf der Quellseite ist keine Lizenz
  ausgewiesen. Die V4-Typografie geht auf den King-Fahd-Komplex zurueck, und
  Schriften aus diesem Umfeld sind ueblicherweise auf nicht-kommerzielle
  Nutzung beschraenkt. **Vor einer Monetarisierung schriftlich klaeren oder
  ersetzen.**
- **CARTO-Kacheln:** Free Tier erlaubt kommerzielle Nutzung bis 5 Mio.
  Kachelabrufe pro Monat gegen Attribution. Die App nutzt jedoch die
  Raster-Endpunkte ohne API-Key, und CARTO dokumentiert diese als
  schluesselpflichtig und auslaufend. Konto anlegen und Key eintragen.
- **Overpass:** das Projekt nennt es ausdruecklich unerwuenscht, die
  oeffentlichen Instanzen als Backend einer App zu nutzen (Richtwert 10.000
  Anfragen/Tag fuer alle Nutzer zusammen). Der 24-Stunden-Cache daempft das;
  vor Reichweite eigene Instanz oder kommerzieller POI-Anbieter.
- **Firebase Spark:** kommerziell erlaubt, aber 20.000 Schreibvorgaenge pro
  Tag. Der SyncScheduler schreibt grob 10-20 mal pro aktivem Nutzer und Tag,
  also Deckel bei etwa 1.000-2.000 taeglich aktiven Nutzern. Danach schlagen
  alle Syncs fehl. Rechtzeitig auf Blaze mit Budget-Alarm.

## Offen

- **Firestore-Regeln muessen noch ausgerollt werden.** Sie begrenzen jetzt,
  was ein angemeldeter Nutzer in sein eigenes Dokument schreiben darf, aber
  keine Pipeline rollt sie aus. Vor der Einreichung:
  `npm --prefix tool/firestore_rules_test install`,
  `npm --prefix tool/firestore_rules_test test`, dann
  `firebase deploy --only firestore:rules --project munir-9360e`.
  Bis dahin laeuft im Projekt die alte, ungebremste Fassung.
- **Keine Hintergrundwiedergabe.** Die Rezitation stoppt, sobald der
  Bildschirm sperrt: kein `UIBackgroundModes`, kein `just_audio_background`.
  Kein Ablehnungsgrund, aber die Erwartung an jede Qur'an-App. Wichtig beim
  Nachruesten: `UIBackgroundModes: audio` ohne echte Hintergrundwiedergabe
  ist seinerseits ein Ablehnungsgrund — beides gehoert zusammen.
- **Inhalte nur auf Deutsch.** Bittgebete, die 99 Namen und der
  Tagesratgeber liegen einsprachig vor. Die Oberflaeche ist in allen fuenf
  Sprachen; diese drei Datensaetze nicht. In der Store-Beschreibung deshalb
  nicht mit fuenf vollstaendigen Sprachen werben.
