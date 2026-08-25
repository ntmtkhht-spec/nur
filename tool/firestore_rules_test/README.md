# Firestore-Regeln testen

Die Regeln in `firestore.rules` werden von keiner Pipeline ausgerollt. Nach
einer Änderung:

```bash
npm --prefix tool/firestore_rules_test install
npm --prefix tool/firestore_rules_test test
firebase deploy --only firestore:rules --project munir-9360e
```

Der Test startet den Firestore-Emulator und prüft beides: dass die App
schreiben darf, was `SyncService` tatsächlich schickt, und dass alles andere
abgelehnt wird — fremde Nutzer, Abmeldung, unbekannte Felder, überlange Namen,
negative Zählerstände.

Er ist nicht dekorativ. Ein erster Entwurf dieser Regeln bestand die
Kompilierung und ließ trotzdem jede Validierung wirkungslos, weil
`match /{subcollection=**}` auch null Segmente matcht und damit das
Nutzerdokument selbst freigab. Nur der Emulator hat das gezeigt.
