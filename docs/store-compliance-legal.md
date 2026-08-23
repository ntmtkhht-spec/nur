# Munir Store- und Rechts-Checkliste

Stand: 20. August 2026

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
  Einstellungen bei Sync, Diagnosedaten nur falls spaeter ein SDK hinzukommt.

## Google Play

- Google Play Console braucht die Data safety Angaben passend zur App.
- Google Play braucht eine Privacy Policy, wenn personenbezogene oder sensible
  Nutzerdaten verarbeitet werden. Standort und Konto reichen dafuer aus.
- Wenn eine App Konten erstellen laesst, muss es in der App und ueber eine
  oeffentliche Webseite eine Moeglichkeit zur Konto- und Datenloeschung geben.
- Die Play-Console-Antworten sollten aktuell ungefaehr so aussehen:
  - Standort: erfasst, fuer App-Funktionalitaet, nicht fuer Werbung, nicht
    verkauft.
  - Personenbezogene Daten: E-Mail/Name nur bei optionalem Login bzw. Sync.
  - App-Aktivitaet: Gebets-Tracker nur bei optionalem Sync in Firebase.
  - Keine Werbung, kein Analytics-SDK, kein Verkauf von Daten.
  - Datenloeschung: In-App-Pfad und oeffentliche Loesch-URL angeben.

## Datenfluesse in Munir

- Lokal: Sprache, Name, Standort, Berechnungsmethode, Madhhab,
  Benachrichtigungseinstellungen, Gebets-Tracker, Moschee-Cache.
- Standort: GPS per `geolocator`; Gebetszeiten und Qibla werden lokal berechnet.
- Moschee-Suche: nur nach Zustimmung; Koordinaten und Radius an Overpass API.
- Karten: CARTO-Kacheln werden geladen; Karten-Cache kann in Einstellungen
  geloescht werden.
- Qur'an: Surah-Liste, Texte, Uebersetzungen, Transliteration und Audio von
  `https://api.alquran.cloud/v1`.
- Konto: optional Google Sign-In/Firebase Auth.
- Sync: Firebase Cloud Firestore speichert Tracker, Tasbih-Gesamtzahl, Name,
  Sprache, updatedAt.
- Benachrichtigungen: lokal geplant, keine eigenen Push-Inhalte an Server.

## Quellen

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Google Play User Data policy: https://support.google.com/googleplay/android-developer/answer/10144311
- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Google Play account deletion: https://support.google.com/googleplay/android-developer/answer/13327111
- § 5 Digitale-Dienste-Gesetz: https://www.gesetze-im-internet.de/ddg/__5.html
- DSGVO Art. 13: https://eur-lex.europa.eu/eli/reg/2016/679/oj
