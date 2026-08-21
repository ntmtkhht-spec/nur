import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'legal_profile.dart';

class LegalDocumentScreen extends StatelessWidget {
  final _LegalDocument _document;

  const LegalDocumentScreen.imprint({super.key})
    : _document = _LegalDocument.imprint;

  const LegalDocumentScreen.privacy({super.key})
    : _document = _LegalDocument.privacy;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          _document.title,
          style: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.primaryGreen),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _IntroCard(document: _document),
          const SizedBox(height: AppSpacing.md),
          for (final section in _document.sections) ...[
            _LegalSectionView(section: section),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final _LegalDocument document;

  const _IntroCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LegalProfile.appName,
            style: TextStyle(
              color: colors.darkGreen,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Stand: ${LegalProfile.lastUpdated}',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            document.intro,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSectionView extends StatelessWidget {
  final _LegalSection section;

  const _LegalSectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              color: colors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final paragraph in section.paragraphs) ...[
            SelectableText(
              paragraph,
              style: TextStyle(
                color: colors.textDark,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (section.bullets.isNotEmpty)
            for (final bullet in section.bullets) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: colors.accentGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SelectableText(
                      bullet,
                      style: TextStyle(
                        color: colors.textDark,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
        ],
      ),
    );
  }
}

class _LegalDocument {
  final String title;
  final String intro;
  final List<_LegalSection> sections;

  const _LegalDocument({
    required this.title,
    required this.intro,
    required this.sections,
  });

  static const imprint = _LegalDocument(
    title: 'Impressum',
    intro: 'Wer ${LegalProfile.appName} anbietet und wie du uns erreichst.',
    sections: [
      _LegalSection(
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
      _LegalSection(
        title: 'Kontakt',
        paragraphs: [
          'E-Mail: ${LegalProfile.contactEmail}\n'
              'Telefon: ${LegalProfile.contactPhone}',
          'Am schnellsten erreichst du uns per E-Mail. Anfragen zum '
              'Datenschutz beantworten wir unter derselben Adresse.',
        ],
      ),
      _LegalSection(
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
      _LegalSection(
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

  static const privacy = _LegalDocument(
    title: 'Datenschutzerklärung',
    intro:
        'Diese Erklärung beschreibt, welche personenbezogenen Daten Munir '
        'verarbeitet, zu welchem Zweck das geschieht, wer sie erhält und '
        'welche Rechte dir zustehen.',
    sections: [
      _LegalSection(
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
      _LegalSection(
        title: '2. Überblick',
        bullets: [
          'Munir lässt sich vollständig ohne Konto nutzen.',
          'Gebetszeiten und Qibla-Richtung werden auf deinem Gerät berechnet.',
          'Standortdaten verlassen dein Gerät nur, wenn du die Moschee-Suche '
              'ausdrücklich freigibst.',
          'Ein Konto ist freiwillig und dient allein dazu, deine Einträge auf '
              'mehreren Geräten gleich zu halten.',
          'Es gibt keine Werbung, keine Nutzungsanalyse, keine Werbe-Kennungen '
              'und keinen Verkauf deiner Daten.',
        ],
      ),
      _LegalSection(
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
          'Deine Zustimmung zur Moschee-Suche und zwischengespeicherte '
              'Moschee- und Kartendaten.',
        ],
      ),
      _LegalSection(
        title: '4. Zugriff auf Standort',
        paragraphs: [
          'Zweck: Berechnung der Gebetszeiten und der Qibla-Richtung für '
              'deinen tatsächlichen Aufenthaltsort. Ohne Standort verwendet '
              'Munir einen voreingestellten Ort.',
          'Der Zugriff erfolgt nur, wenn du ihn erlaubst, und nur während du '
              'die App nutzt. Munir fragt dabei einen ungefähren Standort ab, '
              'keine punktgenaue Position, und greift nicht im Hintergrund auf '
              'deinen Standort zu.',
          'Die Berechnung findet auf deinem Gerät statt; für Gebetszeiten und '
              'Qibla wird dein Standort nicht übermittelt.',
          'Suchst du eine Stadt von Hand, wandelt dein Gerät den eingegebenen '
              'Ort in Koordinaten um. Diese Umwandlung übernimmt der Dienst '
              'deines Betriebssystems; welche Daten dabei anfallen, richtet '
              'sich nach dessen Datenschutzbestimmungen.',
          'Du kannst die Standortfreigabe jederzeit in den Systemeinstellungen '
              'deines Geräts widerrufen.',
        ],
      ),
      _LegalSection(
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
      _LegalSection(
        title: '6. Moscheen in deiner Nähe',
        paragraphs: [
          'Zweck: Anzeige von Moscheen im gewählten Umkreis.',
          'Diese Funktion ist standardmäßig ausgeschaltet. Erst wenn du ihr '
              'zustimmst, übermittelt Munir deinen Standort und den gewählten '
              'Umkreis an OpenStreetMap, um passende Einträge abzurufen. Ein '
              'Konto oder eine Werbe-Kennung wird dabei nicht mitgeschickt.',
          'Deine Zustimmung kannst du in den Einstellungen jederzeit mit '
              'Wirkung für die Zukunft widerrufen.',
        ],
        bullets: ['OpenStreetMap Foundation: https://www.openstreetmap.org'],
      ),
      _LegalSection(
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
      _LegalSection(
        title: '8. Freiwilliges Konto und Synchronisierung',
        paragraphs: [
          'Zweck: Sicherung deiner Einträge und Abgleich zwischen mehreren '
              'Geräten.',
          'Die Anmeldung erfolgt mit deinem Google-Konto. Munir erhält dabei '
              'eine Kennung, die dich wiedererkennt, sowie deine E-Mail-Adresse '
              'und deinen Namen, soweit dein Google-Konto diese herausgibt. '
              'Dein Passwort erfährt Munir zu keinem Zeitpunkt.',
          'Ist ein Konto verbunden, werden dein Gebets-Verlauf, deine '
              'Tasbih-Gesamtzahl, dein Name, deine Spracheinstellung und der '
              'Zeitpunkt der letzten Änderung in deinem Konto gespeichert. Der '
              'technische Betrieb von Anmeldung und Speicherung erfolgt durch '
              'Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, '
              'Irland.',
          'Deinen Standort, deine Berechnungsmethode und deine '
              'Erinnerungseinstellungen übermittelt Munir nicht.',
        ],
      ),
      _LegalSection(
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
      _LegalSection(
        title: '10. Bezug der App',
        paragraphs: [
          'Beim Herunterladen der App erhebt der jeweilige App-Store Daten, '
              'etwa deine Nutzerkennung, die E-Mail-Adresse deines '
              'Store-Kontos, den Zeitpunkt des Downloads und Angaben zu deinem '
              'Gerät. Auf diese Erhebung haben wir keinen Einfluss; '
              'verantwortlich ist der Betreiber des Stores.',
        ],
      ),
      _LegalSection(
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
      _LegalSection(
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
          'Google Ireland Limited, wenn du dich anmeldest.',
          'OpenStreetMap Foundation, wenn du der Moschee-Suche zustimmst.',
          'CARTO, wenn du die Kartenansicht öffnest.',
          'alquran.cloud, wenn du Qur’an-Inhalte oder Rezitationen abrufst.',
        ],
      ),
      _LegalSection(
        title: '13. Speicherdauer und Löschung',
        paragraphs: [
          'Lokale Daten bleiben gespeichert, bis du sie in der App '
              'zurücksetzt, die App-Daten löschst oder die App deinstallierst.',
          'Meldest du dich ab, werden dein Gebets-Verlauf, deine '
              'Tasbih-Zählungen und dein Name zuvor in deinem Konto gesichert '
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
      _LegalSection(
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
      _LegalSection(
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
      _LegalSection(
        title: '16. Keine automatisierte Entscheidungsfindung',
        paragraphs: [
          'Eine automatisierte Entscheidungsfindung einschließlich Profiling '
              'nach Art. 22 DSGVO findet nicht statt. Deine Einträge werden '
              'nicht ausgewertet, um Profile über dich zu bilden.',
        ],
      ),
      _LegalSection(
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
      _LegalSection(
        title: '18. Sicherheit der Übertragung',
        paragraphs: [
          'Alle Verbindungen, die Munir aufbaut, sind mit TLS verschlüsselt. '
              'Daten, die auf deinem Gerät bleiben, sind durch die '
              'Schutzmechanismen deines Betriebssystems abgesichert; ein '
              'Gerätecode oder eine Bildschirmsperre erhöht diesen Schutz '
              'zusätzlich.',
        ],
      ),
      _LegalSection(
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

class _LegalSection {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  const _LegalSection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });
}
