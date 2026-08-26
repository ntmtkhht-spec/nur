# Firestore-Regeln testen

Diese Tests laufen in CI (`.github/workflows/ci.yml`) bei jedem Pull Request,
und ein Merge nach `master`, der `firestore.rules` anfasst, rollt die Regeln
aus — aber erst, nachdem sie hier nochmal gegen den Emulator gelaufen sind
(`.github/workflows/firestore-rules.yml`). Der Rollout braucht das Secret
`FIREBASE_SERVICE_ACCOUNT`: base64 eines Service-Account-Keys mit der Rolle
"Firebase Rules Admin" auf `munir-9360e`.

Lokal, vor dem Push:

```bash
npm --prefix tool/firestore_rules_test install
npm --prefix tool/firestore_rules_test test
```

Der Testlauf braucht ein JDK — der Firestore-Emulator ist ein JVM-Prozess.
Die Emulator-Konfiguration steht in `firebase.json` im Repository-Wurzel-
verzeichnis; sie enthält keine Schlüssel und ist deshalb bewusst eingecheckt.

Der Test startet den Firestore-Emulator und prüft beides: dass die App
schreiben darf, was `SyncService` tatsächlich schickt, und dass alles andere
abgelehnt wird — fremde Nutzer, Abmeldung, unbekannte Felder, überlange Namen,
negative Zählerstände.

Er ist nicht dekorativ. Ein erster Entwurf dieser Regeln bestand die
Kompilierung und ließ trotzdem jede Validierung wirkungslos, weil
`match /{subcollection=**}` auch null Segmente matcht und damit das
Nutzerdokument selbst freigab. Nur der Emulator hat das gezeigt.
