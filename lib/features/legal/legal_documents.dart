/// The text of the imprint and the privacy policy, kept apart from the widget
/// that renders it.
///
/// The published legal pages are generated from these same values by
/// `tool/build_legal_site.dart`, so the App Store's privacy URL and the
/// screens inside the app cannot say different things. That is the whole
/// reason this is data and not markup: nothing here may import Flutter, or
/// the generator could not run outside an app.
library;

import 'legal_profile.dart';

class LegalDocument {
  final String title;
  final String intro;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.title,
    required this.intro,
    required this.sections,
  });

  static const imprint = LegalDocument(
    title: 'Impressum',
    intro: 'Wer ${LegalProfile.appName} anbietet und wie du uns erreichst.',
    sections: [
      LegalSection(
        title: 'Anbieter',
        paragraphs: [
          '${LegalProfile.operatorName}\n'
              '${LegalProfile.operatorStreet}\n'
              '${LegalProfile.operatorPostalCity}\n'
              '${LegalProfile.operatorCountry}',
          'Munir wird von einer Privatperson angeboten, nicht von einem '
              'Unternehmen.',
        ],
      ),
      LegalSection(
        title: 'Kontakt',
        paragraphs: [
          'E-Mail: ${LegalProfile.contactEmail}\n'
              'Telefon: ${LegalProfile.contactPhone}',
          'Am schnellsten erreichst du uns per E-Mail. Anfragen zum '
              'Datenschutz beantworten wir unter derselben Adresse.',
        ],
      ),
      LegalSection(
        title: 'Inhalte der App',
        paragraphs: [
          'Die Inhalte werden mit Sorgfalt erstellt. Gebetszeiten und '
              'Qibla-Richtung werden auf deinem Gerät berechnet und hängen von '
              'deinem Standort und der gewählten Berechnungsmethode ab; '
              'Moschee-Angaben, Qur’an-Texte und Übersetzungen stammen von '
              'externen Quellen. Abweichungen sind möglich.',
          'Bitte kläre wichtige religiöse Fragen mit einer qualifizierten '
              'Vertrauensperson oder deiner Gemeinde.',
        ],
      ),
      LegalSection(
        title: 'Externe Links und Quellen',
        paragraphs: [
          'Für die Inhalte verlinkter Seiten und externer Datenquellen sind '
              'deren jeweilige Anbieter verantwortlich. Zum Zeitpunkt der '
              'Verlinkung waren keine Rechtsverstöße erkennbar. Werden uns '
              'Rechtsverstöße bekannt, entfernen wir die betreffenden Links.',
        ],
      ),
    ],
  );

  /// Google Play requires the deletion route to be reachable from a public
  /// web page, not only from inside the app. The app itself covers this in
  /// section 13 of the privacy policy, so this exists for the published site.
  static const accountDeletion = LegalDocument(
    title: 'Konto löschen',
    intro:
        'So löschst du dein Munir-Konto und alle darin gespeicherten Daten. '
        'Ein Konto ist freiwillig — nutzt du Munir ohne Anmeldung, gibt es '
        'nichts zu löschen, was nicht schon auf deinem Gerät liegt.',
    sections: [
      LegalSection(
        title: 'In der App',
        paragraphs: [
          'Öffne Einstellungen, dann Konto, dann Konto löschen. Damit werden '
              'dein Gebets-Verlauf, deine Tasbih-Gesamtzahl, dein '
              'Qur\'an-Lesefortschritt, dein Name und deine Spracheinstellung '
              'sowohl im Konto als auch auf dem Gerät dauerhaft entfernt.',
          'Der Vorgang ist endgültig und lässt sich nicht rückgängig machen.',
        ],
      ),
      LegalSection(
        title: 'Ohne installierte App',
        paragraphs: [
          'Hast du Munir bereits deinstalliert, genügt eine formlose Nachricht '
              'an ${LegalProfile.contactEmail} von der E-Mail-Adresse, mit der '
              'du dich angemeldet hast. Wir löschen dein Konto und die '
              'zugehörigen Daten dann für dich.',
          'Solche Anfragen bearbeiten wir unverzüglich, spätestens innerhalb '
              'eines Monats nach Eingang (Art. 12 Abs. 3 DSGVO).',
        ],
      ),
      LegalSection(
        title: 'Was gelöscht wird',
        bullets: [
          'Gebets-Verlauf und Streak.',
          'Tasbih-Gesamtzahl.',
          'Qur\'an-Lesefortschritt und zuletzt gelesene Stelle.',
          'Name und Spracheinstellung.',
          'Die Anmelde-Kennung und die hinterlegte E-Mail-Adresse.',
        ],
      ),
      LegalSection(
        title: 'Was auf dem Gerät bleibt',
        paragraphs: [
          'Geräteeinstellungen ohne Personenbezug — Berechnungsmethode, '
              'Madhhab, Erinnerungen und der zwischengespeicherte Kartenbereich '
              '— gehören zu keinem Konto. Sie verschwinden, sobald du die '
              'App-Daten löschst oder die App deinstallierst.',
        ],
      ),
    ],
  );

  static const privacy = LegalDocument(
    title: 'Datenschutzerklärung',
    intro:
        'Diese Erklärung beschreibt, welche personenbezogenen Daten Munir '
        'verarbeitet, zu welchem Zweck das geschieht, wer sie erhält und '
        'welche Rechte dir zustehen.',
    sections: [
      LegalSection(
        title: '1. Verantwortlicher',
        paragraphs: [
          'Verantwortlich für die Datenverarbeitung in dieser App ist:',
          '${LegalProfile.operatorName}\n'
              '${LegalProfile.operatorStreet}\n'
              '${LegalProfile.operatorPostalCity}\n'
              '${LegalProfile.operatorCountry}\n'
              'E-Mail: ${LegalProfile.contactEmail}\n'
              'Telefon: ${LegalProfile.contactPhone}',
          'Ein Datenschutzbeauftragter ist nicht bestellt, da die '
              'Voraussetzungen dafür nicht vorliegen.',
        ],
      ),
      LegalSection(
        title: '2. Überblick',
        bullets: [
          'Munir lässt sich vollständig ohne Konto nutzen.',
          'Gebetszeiten und Qibla-Richtung werden auf deinem Gerät berechnet.',
          'Standortdaten verlassen dein Gerät nur, wenn du die Moschee-Suche '
              'ausdrücklich freigibst.',
          'Ein Konto ist freiwillig, läuft über Google oder Apple und dient '
              'allein dazu, deine Einträge auf mehreren Geräten gleich zu '
              'halten.',
          'Es gibt keine Werbung, keine Nutzungsanalyse, keine Werbe-Kennungen '
              'und keinen Verkauf deiner Daten.',
        ],
      ),
      LegalSection(
        title: '3. Daten, die auf deinem Gerät bleiben',
        paragraphs: [
          'Die folgenden Angaben speichert Munir ausschließlich lokal auf '
              'deinem Gerät, damit die App beim nächsten Start wie erwartet '
              'weiterläuft. Ohne Konto werden sie an niemanden übermittelt.',
        ],
        bullets: [
          'Dein Name, die App-Sprache und ob die Einführung abgeschlossen ist.',
          'Dein zuletzt ermittelter Standort und der zugehörige Ortsname.',
          'Berechnungsmethode, Madhhab sowie deine Erinnerungs- und '
              'Adhan-Einstellungen.',
          'Welche Gebete du abgehakt hast und wie viele Tage am Stück.',
          'Deine Tasbih-Zählungen einschließlich der Gesamtzahl.',
          'Deinen Qur\'an-Lesefortschritt und die zuletzt gelesene Stelle.',
          'Deine Zustimmung zur Moschee-Suche und zwischengespeicherte '
              'Moschee- und Kartendaten.',
        ],
      ),
      LegalSection(
        title: '4. Zugriff auf Standort',
        paragraphs: [
          'Zweck: Berechnung der Gebetszeiten und der Qibla-Richtung für '
              'deinen tatsächlichen Aufenthaltsort. Ohne Standort verwendet '
              'Munir einen voreingestellten Ort.',
          'Der Zugriff erfolgt nur, wenn du ihn erlaubst, und nur während du '
              'die App nutzt. Im Hintergrund greift Munir nie auf deinen '
              'Standort zu.',
          'Für die Gebetszeiten genügt ein ungefährer Standort auf Stadtebene, '
              'und genau den fragt Munir ab. Unter Android fordert die App '
              'deshalb ausschließlich die Berechtigung für den ungefähren '
              'Standort an.',
          'Eine Ausnahme ist der Qibla-Kompass auf dem iPhone: iOS liefert eine '
              'Richtung bezogen auf den geografischen Norden nur, solange '
              'gleichzeitig eine genaue Ortung läuft. Solange der '
              'Kompass-Bildschirm geöffnet ist, verarbeitet iOS dafür eine '
              'punktgenaue Position auf dem Gerät. Unter Android entsteht die '
              'Richtung aus den Bewegungssensoren; dort wird dafür kein '
              'Standort abgefragt.',
          'Die Berechnung findet in allen Fällen auf deinem Gerät statt; für '
              'Gebetszeiten und Qibla wird dein Standort nicht übermittelt.',
          'Suchst du eine Stadt von Hand, wandelt dein Gerät den eingegebenen '
              'Ort in Koordinaten um. Diese Umwandlung übernimmt der Dienst '
              'deines Betriebssystems; welche Daten dabei anfallen, richtet '
              'sich nach dessen Datenschutzbestimmungen.',
          'Du kannst die Standortfreigabe jederzeit in den Systemeinstellungen '
              'deines Geräts widerrufen.',
        ],
      ),
      LegalSection(
        title: '5. Benachrichtigungen',
        paragraphs: [
          'Zweck: Erinnerung an die täglichen Gebetszeiten.',
          'Aktivierst du Erinnerungen, plant Munir sie auf deinem Gerät ein. '
              'Es werden keine Benachrichtigungen von einem Server verschickt, '
              'und es wird keine Gerätekennung für Push-Nachrichten erzeugt '
              'oder übermittelt.',
          'Damit die Erinnerungen pünktlich erscheinen, benötigt Munir unter '
              'Android die Berechtigung für exakte Weckzeiten. Beide '
              'Berechtigungen kannst du jederzeit in den Systemeinstellungen '
              'zurücknehmen.',
        ],
      ),
      LegalSection(
        title: '6. Moscheen in deiner Nähe',
        paragraphs: [
          'Zweck: Anzeige von Moscheen im gewählten Umkreis.',
          'Diese Funktion ist standardmäßig ausgeschaltet. Erst wenn du ihr '
              'zustimmst, übermittelt Munir deinen Standort und den gewählten '
              'Umkreis an die Overpass-API, um passende Einträge aus '
              'OpenStreetMap abzurufen. Betrieben wird der angefragte Server '
              'overpass-api.de vom FOSSGIS e.V., nicht von der OpenStreetMap '
              'Foundation. Ein Konto oder eine Werbe-Kennung wird dabei nicht '
              'mitgeschickt.',
          'Deine Zustimmung kannst du in den Einstellungen jederzeit mit '
              'Wirkung für die Zukunft widerrufen.',
        ],
        bullets: [
          'FOSSGIS e.V., Betreiber von overpass-api.de: '
              'https://www.fossgis.de/datenschutz/',
          'Kartendaten der OpenStreetMap Foundation: '
              'https://www.openstreetmap.org',
        ],
      ),
      LegalSection(
        title: '7. Kartenansicht und Qur’an-Inhalte',
        paragraphs: [
          'Die Kartenansicht lädt Kartenausschnitte von CARTO. Qur’an-Texte, '
              'Übersetzungen und Rezitationen lädt Munir von alquran.cloud. '
              'Diese Abrufe finden nur statt, wenn du den jeweiligen Bereich '
              'der App öffnest.',
          'Wie bei jedem Abruf im Internet erfährt der jeweilige Anbieter '
              'dabei technisch notwendige Angaben, insbesondere deine '
              'IP-Adresse, den Zeitpunkt der Anfrage und Angaben zu Gerät und '
              'Betriebssystem. Auf diese Verarbeitung haben wir keinen '
              'Einfluss; es gelten die Bestimmungen des jeweiligen Anbieters.',
        ],
        bullets: [
          'CARTO: https://carto.com/privacy',
          'alquran.cloud: https://alquran.cloud',
        ],
      ),
      LegalSection(
        title: '8. Freiwilliges Konto und Synchronisierung',
        paragraphs: [
          'Zweck: Sicherung deiner Einträge und Abgleich zwischen mehreren '
              'Geräten.',
          'Die Anmeldung erfolgt mit deinem Google-Konto oder — auf dem '
              'iPhone — über „Mit Apple anmelden“. Munir erhält dabei eine '
              'Kennung, die dich wiedererkennt, sowie deine E-Mail-Adresse und '
              'deinen Namen, soweit der jeweilige Anbieter sie herausgibt. Bei '
              '„Mit Apple anmelden“ kannst du das Weitergeben deiner '
              'E-Mail-Adresse ablehnen; Apple hinterlegt dann eine anonyme '
              'Weiterleitungsadresse. Dein Passwort erfährt Munir in keinem '
              'Fall.',
          'Ist ein Konto verbunden, werden dein Gebets-Verlauf, deine '
              'Tasbih-Gesamtzahl, dein Qur\'an-Lesefortschritt, dein Name, '
              'deine Spracheinstellung und der Zeitpunkt der letzten Änderung '
              'in deinem Konto gespeichert. Der '
              'technische Betrieb von Anmeldung und Speicherung erfolgt durch '
              'Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, '
              'Irland.',
          'Deinen Standort, deine Berechnungsmethode und deine '
              'Erinnerungseinstellungen übermittelt Munir nicht.',
        ],
      ),
      LegalSection(
        title: '9. Übermittlung in Länder außerhalb der EU',
        paragraphs: [
          'Nutzt du das freiwillige Konto, kann Google zur Erbringung des '
              'Dienstes auch auf Server in den Vereinigten Staaten '
              'zurückgreifen. Google LLC ist unter dem EU-US Data Privacy '
              'Framework zertifiziert; ergänzend bestehen '
              'Standardvertragsklauseln der Europäischen Kommission nach '
              'Art. 46 DSGVO.',
          'Ohne Anmeldung findet keine solche Übermittlung statt.',
        ],
      ),
      LegalSection(
        title: '10. Bezug der App',
        paragraphs: [
          'Beim Herunterladen der App erhebt der jeweilige App-Store Daten, '
              'etwa deine Nutzerkennung, die E-Mail-Adresse deines '
              'Store-Kontos, den Zeitpunkt des Downloads und Angaben zu deinem '
              'Gerät. Auf diese Erhebung haben wir keinen Einfluss; '
              'verantwortlich ist der Betreiber des Stores.',
        ],
      ),
      LegalSection(
        title: '11. Rechtsgrundlagen',
        bullets: [
          'Art. 6 Abs. 1 lit. b DSGVO für die Bereitstellung der Funktionen, '
              'die du nutzt, einschließlich des freiwilligen Kontos.',
          'Art. 6 Abs. 1 lit. a DSGVO für Standortfreigabe, Erinnerungen und '
              'die Moschee-Suche. Diese Einwilligungen kannst du jederzeit mit '
              'Wirkung für die Zukunft widerrufen.',
          'Art. 6 Abs. 1 lit. f DSGVO für einen stabilen und sicheren Betrieb '
              'der App.',
        ],
      ),
      LegalSection(
        title: '12. Empfänger',
        paragraphs: [
          'Deine Daten werden nur weitergegeben, soweit die von dir genutzte '
              'Funktion es erfordert:',
          'Ein Teil dieser Anbieter hat seinen Sitz außerhalb der '
              'Europäischen Union. Welche Daten dort jeweils verarbeitet '
              'werden und auf welcher Grundlage, steht in den oben verlinkten '
              'Datenschutzhinweisen des jeweiligen Anbieters.',
        ],
        bullets: [
          'Google Ireland Limited für Anmeldung mit Google sowie für den '
              'technischen Betrieb des Kontos.',
          'Apple Distribution International Ltd., wenn du dich mit Apple '
              'anmeldest.',
          'FOSSGIS e.V. als Betreiber von overpass-api.de, wenn du der '
              'Moschee-Suche zustimmst.',
          'CARTO, wenn du die Kartenansicht öffnest.',
          'alquran.cloud, wenn du Qur’an-Inhalte oder Rezitationen abrufst.',
        ],
      ),
      LegalSection(
        title: '13. Speicherdauer und Löschung',
        paragraphs: [
          'Lokale Daten bleiben gespeichert, bis du sie in der App '
              'zurücksetzt, die App-Daten löschst oder die App deinstallierst.',
          'Meldest du dich ab, werden dein Gebets-Verlauf, deine '
              'Tasbih-Zählungen, dein Qur\'an-Lesefortschritt und dein Name '
              'zuvor in deinem Konto gesichert '
              'und anschließend von diesem Gerät entfernt. Bei der nächsten '
              'Anmeldung stehen sie wieder zur Verfügung. Geräteeinstellungen '
              'wie Sprache, Berechnungsmethode und Erinnerungen bleiben '
              'erhalten. Die Abmeldung setzt eine Internetverbindung voraus; '
              'ohne Verbindung wird sie abgelehnt, damit keine noch nicht '
              'gesicherten Einträge verloren gehen.',
          'Meldet sich ein anderes Konto auf demselben Gerät an, werden die '
              'lokalen Daten des zuvor angemeldeten Kontos vorher entfernt. '
              'Sind beim ersten Anmelden bereits Einträge vorhanden, die zu '
              'keinem Konto gehören, fragt Munir, ob sie übernommen werden '
              'sollen; verwirfst du sie, werden sie gelöscht.',
          'Dein Konto und alle darin gespeicherten Daten kannst du in der App '
              'unter Einstellungen, Konto, Konto löschen dauerhaft entfernen. '
              'Dabei werden die Daten im Konto und auf diesem Gerät gelöscht.',
          'Ist die App nicht mehr installiert, genügt eine formlose Nachricht '
              'an ${LegalProfile.contactEmail}; wir löschen dein Konto und die '
              'zugehörigen Daten dann für dich. Solche Anfragen bearbeiten wir '
              'unverzüglich, spätestens innerhalb eines Monats nach Eingang '
              '(Art. 12 Abs. 3 DSGVO). Eine öffentlich erreichbare Möglichkeit '
              'zur Löschung findest du unter '
              '${LegalProfile.accountDeletionUrl}',
        ],
      ),
      LegalSection(
        title: '14. Deine Rechte',
        paragraphs: ['Dir stehen nach der DSGVO folgende Rechte zu:'],
        bullets: [
          'Auskunft über die zu deiner Person gespeicherten Daten '
              '(Art. 15 DSGVO).',
          'Berichtigung unrichtiger Daten (Art. 16 DSGVO).',
          'Löschung (Art. 17 DSGVO).',
          'Einschränkung der Verarbeitung (Art. 18 DSGVO).',
          'Datenübertragbarkeit (Art. 20 DSGVO).',
          'Widerspruch gegen bestimmte Verarbeitungen (Art. 21 DSGVO).',
          'Widerruf erteilter Einwilligungen mit Wirkung für die Zukunft '
              '(Art. 7 Abs. 3 DSGVO).',
        ],
      ),
      LegalSection(
        title: '15. Beschwerderecht',
        paragraphs: [
          'Du hast das Recht, dich bei einer Datenschutz-Aufsichtsbehörde zu '
              'beschweren. Zuständig ist die Behörde deines gewöhnlichen '
              'Aufenthaltsorts oder die für uns zuständige Stelle:',
          'Die Landesbeauftragte für den Datenschutz Niedersachsen\n'
              'Prinzenstraße 5\n'
              '30159 Hannover\n'
              'https://www.lfd.niedersachsen.de',
        ],
      ),
      LegalSection(
        title: '16. Keine automatisierte Entscheidungsfindung',
        paragraphs: [
          'Eine automatisierte Entscheidungsfindung einschließlich Profiling '
              'nach Art. 22 DSGVO findet nicht statt. Deine Einträge werden '
              'nicht ausgewertet, um Profile über dich zu bilden.',
        ],
      ),
      LegalSection(
        title: '17. Kinder',
        paragraphs: [
          'Munir richtet sich nicht gezielt an Kinder. Haben '
              'Erziehungsberechtigte Grund zu der Annahme, dass ein Kind ohne '
              'die erforderliche Zustimmung personenbezogene Daten '
              'bereitgestellt hat, können sie uns unter '
              '${LegalProfile.contactEmail} erreichen. Wir löschen die Daten '
              'dann.',
        ],
      ),
      LegalSection(
        title: '18. Sicherheit der Übertragung',
        paragraphs: [
          'Alle Verbindungen, die Munir aufbaut, sind mit TLS verschlüsselt. '
              'Daten, die auf deinem Gerät bleiben, sind durch die '
              'Schutzmechanismen deines Betriebssystems abgesichert; ein '
              'Gerätecode oder eine Bildschirmsperre erhöht diesen Schutz '
              'zusätzlich.',
        ],
      ),
      LegalSection(
        title: '19. Änderungen dieser Erklärung',
        paragraphs: [
          'Diese Datenschutzerklärung wird angepasst, wenn sich Funktionen '
              'oder rechtliche Anforderungen ändern. Die jeweils aktuelle '
              'Fassung ist in der App und unter '
              '${LegalProfile.privacyPolicyUrl} abrufbar.',
        ],
      ),
    ],
  );
}

class LegalSection {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  const LegalSection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });
}
