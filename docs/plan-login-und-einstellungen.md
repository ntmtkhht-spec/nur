# Plan: Anmeldung (Apple / Google) und Einstellungsseite

Stand: 19. August 2026 · Betrifft: Nur App (`com.nur.nurApp`)

Alle Store-Anforderungen unten sind an der jeweils aktuellen Fassung der Richtlinien
geprüft, nicht aus dem Gedächtnis geschrieben. Quellen stehen am Ende.

---

## 1. Leitentscheidung: Die Anmeldung bleibt optional

Das ist keine Geschmacksfrage, sondern die Bedingung dafür, dass die App durch die
Prüfung kommt. Apple, Richtlinie 5.1.1(v), wörtlich:

> "If your app doesn't include significant account-based features, let people use it
> without a login. […] Apps may not require users to enter personal information to
> function, except when directly relevant to the core functionality of the app or
> required by law."

Gebetszeiten, Qibla, Tasbih, Duas, die 99 Namen und der Qur'an funktionieren
vollständig ohne Konto. Ein Anmeldezwang beim Start wäre ein direkter
Ablehnungsgrund. Die App startet also weiter ins Onboarding und danach in den
Hauptbildschirm — ohne jede Anmeldung.

**Regel für die Umsetzung:** Kein Bildschirm, keine Funktion, die heute ohne Konto
läuft, darf hinter die Anmeldung wandern.

### Wofür der Login dann da ist

Der Login trägt genau einen Zweck, und der rechtfertigt ihn auch gegenüber der
Prüfung: **Sicherung und Abgleich der persönlichen Daten über Geräte hinweg.**

| Daten | heute | mit Konto |
|---|---|---|
| Gebets-Tracker (erledigt/offen pro Tag) | nur lokal, weg bei Neuinstallation | gesichert, geräteübergreifend |
| Streak | nur lokal | gesichert |
| Einstellungen (Methode, Madhab, Sprache, Muezzin) | nur lokal | gesichert |
| Name aus dem Onboarding | nur lokal | gesichert |

Muslim Pro löst es genauso: Konto über E-Mail, Google oder Apple, und wer auf das
X tippt, nutzt die App als Gast weiter — nur ohne gespeicherten Fortschritt. Das
ist die Messlatte, an der sich die Prüfer orientieren werden.

---

## 2. Was die Stores konkret verlangen

### 2.1 Apple, Richtlinie 4.8 — „Login Services"

Häufiges Missverständnis: Es steht **nicht** mehr da, dass „Sign in with Apple"
Pflicht ist. Verlangt wird ein *gleichwertiger* Dienst, der drei Eigenschaften
erfüllt. Wörtlich muss der alternative Login:

> - "the login service limits data collection to the user's name and email address;
> - the login service allows users to keep their email address private as part of
>   setting up their account; and
> - the login service does not collect interactions with your app for advertising
>   purposes without consent."

Sobald wir Google Sign-In anbieten, brauchen wir also einen zweiten Dienst mit
diesen drei Eigenschaften. Sign in with Apple erfüllt sie (Name + E-Mail, private
Relay-Adresse, kein Werbe-Tracking) und ist der pragmatische Weg. Ein eigener
E-Mail-Login würde die Anforderung ebenfalls erfüllen, kostet aber Passwort-Reset,
Zustellung, Brute-Force-Schutz — deshalb hier nicht empfohlen.

**Reihenfolge in der UI:** Apple oben. Nicht wegen einer Vorschrift, sondern weil
Prüfer bei iOS-Apps genau darauf schauen, ob der Apple-Weg gleichrangig sichtbar ist.

### 2.2 Apple, Richtlinie 5.1.1(v) — Kontolöschung

> "If your app supports account creation, you must also offer account deletion
> within the app."

Konkret gefordert:

- Löschung **des ganzen Kontos samt Daten**, nicht nur Deaktivieren. Wörtlich:
  „only offering to temporarily deactivate or disable an account is insufficient"
- leicht auffindbar, üblicherweise in den Einstellungen
- für **alle** Nutzer, unabhängig vom Wohnort
- bei Sign in with Apple zusätzlich: **Token per REST-API widerrufen**
  („Apps that support Sign in with Apple should use the Sign in with Apple REST API
  to revoke user tokens")

Der Token-Widerruf wird gerne vergessen und fällt in der Prüfung auf.

### 2.3 Google Play — Kontolöschung

Play verlangt **zwei** Wege, nicht einen:

1. „provide users with an in-app path to delete their app accounts and associated data"
2. „provide a web link resource where users can request app account deletion" —
   eine öffentlich erreichbare Webseite, auf der der Löschweg „prominently featured
   and easily discoverable" ist und die den App- oder Entwicklernamen nennt

Die URL wird im Play-Console-Formular „Data safety" hinterlegt. **Ohne diese
Webseite gibt es keine Freigabe** — auch dann nicht, wenn die App-interne Löschung
tadellos funktioniert.

### 2.4 Apple — Privacy Manifest

Seit dem 1. Mai 2024 nimmt App Store Connect keine App mehr an, die ihre Nutzung
der „Required Reason APIs" nicht in einer `PrivacyInfo.xcprivacy` deklariert. Das
betrifft uns bereits heute (die App nutzt `UserDefaults` über `shared_preferences`)
und wird mit jedem neuen Paket größer. Die Datei fehlt im Projekt bislang.

Zu prüfen ist außerdem, ob die eingebundenen Pakete eigene Manifeste mitbringen —
Drittanbieter-SDKs müssen ihres selbst liefern.

### 2.5 Google Play — Data-Safety-Formular

Mit dem Login wandern erstmals personenbezogene Daten (Name, E-Mail, Nutzer-ID) auf
einen Server. Das Formular muss das abbilden, sonst droht Sperrung. Ebenfalls
anzugeben: Verschlüsselung bei der Übertragung, Löschmöglichkeit.

---

## 3. Architektur

### 3.1 Backend — Empfehlung: Supabase

Ein Login ohne Server ist nicht möglich: ID-Tokens müssen serverseitig geprüft
werden, und der Abgleich braucht eine Datenbank.

| Option | Für uns | Gegen uns |
|---|---|---|
| **Supabase** (Empfehlung) | Apple + Google eingebaut, Postgres mit Row Level Security, Edge Functions für Löschung/Token-Widerruf, MCP-Zugang in dieser Umgebung bereits verbunden | eigenes Projekt nötig |
| Firebase Auth | sehr verbreitet, Apple + Google eingebaut | zieht Google-SDKs in die App, mehr Privacy-Manifest-Aufwand, Datenhaltung bei Google |
| Eigener Server | volle Kontrolle | Betrieb, Sicherheit, Kosten — für diese App unverhältnismäßig |

Supabase passt hier am besten. Row Level Security sorgt dafür, dass ein Nutzer
technisch nur an seine eigenen Zeilen kommt, selbst wenn die App kompromittiert
würde.

### 3.2 Datenmodell (Entwurf)

```
profiles            id (= auth.uid), display_name, locale, created_at
prayer_log          user_id, day (date), prayer (text), done (bool)   -- PK: (user_id, day, prayer)
user_settings       user_id, calculation_method, madhab, muezzin_voice,
                    notifications_enabled, prayer_notifications (jsonb), updated_at
```

Auf allen drei Tabellen: RLS aktiv, Policy `user_id = auth.uid()`.
Kein Standort auf dem Server — die Koordinaten bleiben auf dem Gerät. Das ist
sparsamer und erspart uns eine heikle Angabe im Data-Safety-Formular.

### 3.3 Abgleich

- Lokal bleibt führend. Die App funktioniert offline weiter, `SharedPreferences`
  bleibt die Quelle für den laufenden Betrieb.
- Bei Anmeldung: Server-Daten holen, mit lokalen zusammenführen.
- Konflikt: Beim Gebets-Log gewinnt „erledigt" — ein abgehaktes Gebet soll nicht
  durch einen Abgleich verschwinden. Bei Einstellungen gewinnt der neuere
  `updated_at`.
- Bei Änderung: in die Warteschlange, hochladen sobald Netz da ist.

---

## 4. Ablauf der Anmeldung

### 4.1 Sign in with Apple

Paket `sign_in_with_apple` (aktuell 8.1.0). Ablauf:

1. Zufälligen `nonce` erzeugen, SHA-256 davon an Apple schicken
2. `getAppleIDCredential(scopes: [email, fullName], nonce: hashedNonce)`
3. `identityToken` **mit dem ungehashten nonce** an Supabase geben
4. Server prüft Signatur, `aud`, `iss`, Ablauf **und** den nonce

Die Signatur des Pakets belegt die Unterstützung:

```dart
static Future<AuthorizationCredentialAppleID> getAppleIDCredential({
  required List<AppleIDAuthorizationScopes> scopes,
  WebAuthenticationOptions? webAuthenticationOptions,
  String? nonce,
  String? state,
})
```

Zwei Eigenheiten, die zu Fehlern führen, wenn man sie nicht kennt:

- **Name und E-Mail liefert Apple nur beim allerersten Mal.** Wer sie nicht sofort
  speichert, bekommt sie nie wieder — außer der Nutzer entfernt die App in seinen
  Apple-ID-Einstellungen. Also: beim ersten Erfolg direkt ins Profil schreiben.
- Wählt der Nutzer „E-Mail verbergen", kommt eine `@privaterelay.appleid.com`-Adresse.
  Die ist gültig, aber Weiterleitung funktioniert nur über eine registrierte Domain.
  Für uns unkritisch, solange wir keine E-Mails versenden.

### 4.2 Google Sign-In

Paket `google_sign_in` (aktuell 7.2.0, Android SDK 21+, iOS 12+). Version 7 hat den
Ablauf umgebaut, alte Anleitungen aus dem Netz passen nicht mehr:

- `GoogleSignIn` ist jetzt ein Singleton, `initialize()` muss vor allem anderen
  aufgerufen und abgewartet werden
- **Authentifizierung und Autorisierung sind getrennt** — der alte
  Alles-in-einem-`signIn()` ist weg
- `attemptLightweightAuthentication()` für die stille Wiederanmeldung,
  `authenticate()` für den vom Nutzer ausgelösten Weg
- Android läuft über den Credential Manager; das alte Google-Sign-In-SDK für
  Android ist abgekündigt

### 4.3 Wo der Login auftaucht

- **Einstellungen → ganz oben**, als Karte „Anmelden — Fortschritt sichern"
- Einmalig ein dezenter Hinweis auf der Startseite, wegwischbar, danach nie wieder
- **Nicht** beim Start, **nicht** als Sperre vor einer Funktion

---

## 5. Sicherheit: was konkret schiefgehen kann

Diese Punkte sind keine Theorie — jeder steht für einen real ausgenutzten Fehler.

### 5.1 Nutzer an `sub` binden, niemals an die E-Mail

Truffle Security zeigte Anfang 2025, wie über aufgekaufte Domains von
eingestellten Firmen die Konten ehemaliger Mitarbeiter übernommen werden konnten:
Dienste hatten Nutzer an `email` und `hd` gekoppelt statt an die stabile ID.
Betroffen waren Millionen Konten bei Diensten wie Slack und Notion.

**Für uns:** Primärschlüssel ist die unveränderliche Anbieter-ID (`sub`). Die
E-Mail ist ein Anzeigefeld, mehr nicht. Sie darf nie allein über die Identität
entscheiden.

### 5.2 Nonce erzeugen **und** prüfen

Der häufigste Fehler bei OpenID Connect: Ein nonce wird erzeugt, aber beim Rücklauf
nie verglichen — dann schützt er gegen nichts. Die Spezifikation verlangt die
Prüfung ausdrücklich. Ein gestohlenes ID-Token ist sonst beliebig wiederverwendbar.

### 5.3 Tokens nicht in SharedPreferences

`SharedPreferences` legt im Klartext ab. Zugangstokens gehören in
`flutter_secure_storage` (Keychain auf iOS, Keystore/EncryptedSharedPreferences auf
Android). Die bestehenden Einstellungen dürfen bleiben, wo sie sind — Tokens nicht.

### 5.4 Kein Client Secret in der App

Alles, was mitgeliefert wird, ist auslesbar. Der Apple-Token-Widerruf braucht ein
signiertes Client Secret — das gehört ausschließlich in eine Edge Function, nie in
den Flutter-Code und nie ins öffentliche Repo.

**Besonders wichtig bei uns: Das Repository ist seit heute öffentlich.** Jeder
versehentlich eingecheckte Schlüssel ist sofort weltweit lesbar und muss als
kompromittiert gelten.

### 5.5 ID-Token immer serverseitig prüfen

Signatur, `aud`, `iss`, Ablaufzeit und nonce werden auf dem Server geprüft. Eine
Prüfung in der App ist wertlos, weil der Angreifer die App kontrolliert.

### 5.6 Kein Login in einer eingebetteten WebView

Google lehnt OAuth in eingebetteten WebViews ab. Es muss
`ASWebAuthenticationSession` (iOS) beziehungsweise Custom Tabs (Android) sein — die
Pakete erledigen das, solange man sie nicht umgeht.

### 5.7 Konto-Verknüpfung sauber lösen

Meldet sich jemand erst mit Google an und später mit Apple bei gleicher E-Mail,
darf **nicht** automatisch zusammengeführt werden, solange die E-Mail nicht
nachweislich verifiziert ist. Sonst entsteht eine Übernahmemöglichkeit über eine
untergeschobene Adresse.

### 5.8 Löschung muss wirklich löschen

Ein `deleted_at`-Feld reicht nicht. Gefordert ist die Löschung des Datensatzes
samt zugehöriger Daten. Aufbewahren darf man nur, was aus Sicherheits- oder
Rechtsgründen nötig ist — und das gehört in die Datenschutzerklärung.

---

## 6. Einstellungsseite

### 6.1 Einstieg

Zahnrad **oben rechts auf der Startseite**, in `GreetingHeader` neben dem
Moschee-Symbol. Öffnet `SettingsScreen` über `Navigator.push`.

Nebenbefund: Auf der Gebet-Seite gibt es bereits ein `Icons.tune`, das an **keinen**
Handler hängt — ein toter Knopf. Der zeigt künftig auf dieselbe Seite.

### 6.2 Aufbau

Alles, was heute im Code verstreut liegt, kommt hier zusammen. Die kursiven
Einträge existieren bereits als Provider und werden nur angebunden:

**Konto**
- Angemeldet als … / „Anmelden — Fortschritt sichern"
- Abmelden
- Konto löschen (rot, mit Rückfrage in zwei Schritten)

**Gebet**
- *Berechnungsmethode* (`calculationMethodProvider`)
- *Rechtsschule / Madhab* (`madhabProvider`)
- *Standort* (`locationProvider`) — automatisch oder manuell
- Manuelle Zeitkorrektur pro Gebet (neu, ±Minuten)

**Benachrichtigungen**
- *Hauptschalter* (`notificationsEnabledProvider`)
- *Pro Gebet* (`prayerNotificationsProvider`)
- *Muezzin-Stimme* (`muezzinVoiceProvider`)
- Vorlaufzeit (neu)

**Darstellung**
- *Sprache* (`appLanguageProvider`) — bisher nur im Onboarding wählbar
- *Name* (`userNameProvider`)

**Daten**
- Moscheesuche erlauben (`mosqueSearchConsentProvider`)
- Kartendaten-Zwischenspeicher leeren (der Kachel-Cache aus dem letzten Commit)
- Gebets-Tracker zurücksetzen

**Rechtliches**
- Datenschutzerklärung (Link)
- Impressum
- Quellen: OpenStreetMap, CARTO, alquran.cloud
- Version

### 6.3 Anmerkung zur Sprache

Die Sprachauswahl aus dem Onboarding wird bisher nur gespeichert, aber im UI
ignoriert — übersetzt ist derzeit allein die Fortschrittskarte über
`lib/core/i18n/app_strings.dart`. Eine Sprachumschaltung in den Einstellungen macht
das für jeden sofort sichtbar. Entweder wird die Übersetzung mitgezogen, oder die
Auswahl bleibt vorerst draußen. Auf halbem Weg wirkt sie kaputt.

---

## 7. Reihenfolge der Umsetzung

**Phase 1 — Einstellungsseite, ohne Konto** ▸ *ohne Zugangsdaten machbar, kann sofort losgehen*
Zahnrad, `SettingsScreen`, alle vorhandenen Provider angebunden, Rechtliches,
Cache leeren, Tracker zurücksetzen. Kontoblock zunächst ausgeblendet.

**Phase 2 — Fundament** ▸ *braucht deine Konten*
Supabase-Projekt, Tabellen samt RLS, `PrivacyInfo.xcprivacy`, Datenschutzerklärung
und Lösch-Webseite online.

**Phase 3 — Sign in with Apple**
Capability im Apple-Portal, Flutter-Anbindung mit nonce, Profil beim ersten Login
speichern.

**Phase 4 — Google Sign-In**
Google-Cloud-Projekt, OAuth-Clients für iOS und Android, `google_sign_in` 7.

**Phase 5 — Abgleich**
Tracker und Einstellungen hoch- und runterladen, Zusammenführung, Warteschlange
für Offline.

**Phase 6 — Löschung**
In-App-Löschung, Edge Function mit Apple-Token-Widerruf, Webseite verlinkt.

**Phase 7 — Freigabe vorbereiten**
Data-Safety-Formular, App-Privacy-Angaben, Testkonto für die Prüfer, Prüfung gegen
die Punkte aus Abschnitt 2.

---

## 8. Was nur du erledigen kannst

Ohne diese Dinge kommt Phase 2 nicht von der Stelle:

| Was | Wo | Wofür |
|---|---|---|
| Sign in with Apple aktivieren | Apple Developer Portal → Identifiers | Phase 3 |
| Service ID + Key | Apple Developer Portal | Token-Widerruf |
| OAuth-Client iOS + Android | Google Cloud Console | Phase 4 |
| SHA-1-Fingerabdruck | aus deinem Signaturschlüssel | Google unter Android |
| Supabase-Projekt | supabase.com | Phase 2 |
| Datenschutzerklärung (URL) | eigene Seite | beide Stores |
| Lösch-Webseite (URL) | eigene Seite | Play zwingend |

Schlüssel und Secrets gehören in GitHub Secrets, **nicht** ins Repository — es ist
öffentlich.

---

## 9. Offene Punkte

1. **Backend:** Supabase wie empfohlen, oder Firebase?
2. **E-Mail-Login zusätzlich?** Nicht nötig, sobald Apple dabei ist. Mehr Aufwand,
   mehr Angriffsfläche.
3. **Sprachumschaltung:** mit vollständiger Übersetzung, oder vorerst weglassen?
4. **Premium später?** Falls Käufe geplant sind, ändert das die Anforderungen an
   die Kontowiederherstellung — dann sollte das Datenmodell es früh mitdenken.

---

## Quellen

- [App Review Guidelines — 4.8 Login Services, 5.1.1 Data Collection and Storage](https://developer.apple.com/app-store/review/guidelines/)
- [Offering Account Deletion in Your App](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
- [Google Play — App account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111)
- [pub.dev — google_sign_in](https://pub.dev/packages/google_sign_in)
- [pub.dev — sign_in_with_apple, getAppleIDCredential](https://pub.dev/documentation/sign_in_with_apple/latest/sign_in_with_apple/SignInWithApple/getAppleIDCredential.html)
- [Truffle Security — Millions of Accounts Vulnerable due to Google's OAuth Flaw](https://trufflesecurity.com/blog/millions-at-risk-due-to-google-s-oauth-flaw)
- [The Hacker News — Google OAuth Vulnerability Exposes Millions via Failed Startup Domains](https://thehackernews.com/2025/01/google-oauth-vulnerability-exposes.html)
- [Securing — OpenID Connect Nonce explained: replay attack revisited](https://www.securing.pl/en/openid-connect-nonce-explained/)
- [Auth0 — Demystifying OAuth Security: State vs. Nonce vs. PKCE](https://auth0.com/blog/demystifying-oauth-security-state-vs-nonce-vs-pkce/)
- [flutter/flutter#154205 — google_sign_in: Switch Android to Credential Manager](https://github.com/flutter/flutter/issues/154205)
- [Privacy manifest requirements — Übersicht](https://vburojevic.dev/blog/ios-privacy-manifest-requirements/)
- [Muslim Pro — Setting Up A Profile](https://support.muslimpro.com/hc/en-us/articles/4648775233549-Setting-Up-A-Muslim-Pro-Profile)
