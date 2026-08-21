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
          if (LegalProfile.hasPlaceholders) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vor der Store-Einreichung muessen die Platzhalter in '
              'legal_profile.dart durch echte Betreiber-, Kontakt- und '
              'oeffentliche Web-URLs ersetzt werden.',
              style: TextStyle(
                color: colors.textDark,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
    intro:
        'Angaben nach § 5 DDG sowie weitere Anbieterinformationen fuer die App '
        '${LegalProfile.appName}.',
    sections: [
      _LegalSection(
        title: 'Anbieter',
        paragraphs: [
          '${LegalProfile.operatorName}\n'
              '${LegalProfile.operatorStreet}\n'
              '${LegalProfile.operatorPostalCity}\n'
              '${LegalProfile.operatorCountry}',
        ],
      ),
      _LegalSection(
        title: 'Kontakt',
        paragraphs: [
          'E-Mail: ${LegalProfile.contactEmail}\n'
              'Telefon: ${LegalProfile.contactPhone}',
          'Eine schnelle elektronische Kontaktaufnahme ist ueber die oben '
              'genannte E-Mail-Adresse moeglich.',
        ],
      ),
      _LegalSection(
        title: 'Vertretung und Register',
        paragraphs: [
          'Vertreten durch: ${LegalProfile.representedBy}',
          'Registereintrag: ${LegalProfile.registerEntry}',
          'Umsatzsteuer-Identifikationsnummer: ${LegalProfile.vatId}',
        ],
      ),
      _LegalSection(
        title: 'Inhaltlich verantwortlich',
        paragraphs: [
          LegalProfile.editorialResponsible,
          'Dieser Abschnitt ist auszufuellen, wenn die App journalistisch-'
              'redaktionelle Inhalte im Sinne des Medienstaatsvertrags anbietet.',
        ],
      ),
      _LegalSection(
        title: 'Haftung fuer Inhalte und externe Quellen',
        paragraphs: [
          'Die Inhalte der App werden mit Sorgfalt erstellt. Gebetszeiten, '
              'Qibla-Richtung, Moschee-Daten, Qur’an-Texte und Uebersetzungen '
              'koennen jedoch von Berechnungsmethoden, Standortdaten und externen '
              'Datenquellen abhaengen. Bitte pruefe wichtige religioese Fragen '
              'bei einer qualifizierten Vertrauensperson oder deiner Gemeinde.',
          'Externe Links und Datenquellen liegen ausserhalb unseres '
              'Einflussbereichs. Fuer deren Inhalte und Datenschutzpraktiken sind '
              'die jeweiligen Anbieter verantwortlich.',
        ],
      ),
    ],
  );

  static const privacy = _LegalDocument(
    title: 'Datenschutzrichtlinie',
    intro:
        'Diese Datenschutzerklaerung beschreibt, welche Daten ${LegalProfile.appName} '
        'verarbeitet, wofuer sie genutzt werden und welche Rechte du hast.',
    sections: [
      _LegalSection(
        title: 'Verantwortlicher',
        paragraphs: [
          '${LegalProfile.operatorName}\n'
              '${LegalProfile.operatorStreet}\n'
              '${LegalProfile.operatorPostalCity}\n'
              '${LegalProfile.operatorCountry}\n'
              'E-Mail: ${LegalProfile.contactEmail}',
          'Oeffentliche Datenschutz-URL fuer App Store und Google Play: '
              '${LegalProfile.privacyPolicyUrl}',
        ],
      ),
      _LegalSection(
        title: 'Kurzfassung',
        bullets: [
          'Die App funktioniert grundsaetzlich ohne Konto.',
          'Gebetszeiten und Qibla werden auf deinem Geraet aus deinem Standort berechnet.',
          'Die Moschee-Suche sendet deinen ungefaehren Standort nur nach separater Zustimmung an Overpass/OpenStreetMap.',
          'Ein Google/Firebase-Konto ist optional und dient nur der Synchronisierung von Tracker- und Einstellungsdaten.',
          'Es sind keine Werbe-SDKs, keine Analytics-SDKs und kein Verkauf personenbezogener Daten eingebaut.',
        ],
      ),
      _LegalSection(
        title: 'Lokal gespeicherte Daten',
        paragraphs: [
          'Munir speichert Einstellungen lokal auf deinem Geraet, damit die App '
              'beim naechsten Start wie erwartet weiterlaeuft.',
        ],
        bullets: [
          'Name, App-Sprache, abgeschlossene Einfuehrung und Anzeigeeinstellungen.',
          'Standortkoordinaten und Stadtname fuer Gebetszeiten, Qibla und Anzeige in der App.',
          'Berechnungsmethode, Madhhab, Erinnerungs- und Adhan-Einstellungen.',
          'Gebets-Tracker, Streaks und erledigte Gebete.',
          'Tasbih-Zaehler, aktuelle Runde und Gesamtzahl.',
          'Moschee-Suchzustimmung und zwischengespeicherte Moschee-/Kartendaten.',
        ],
      ),
      _LegalSection(
        title: 'Standortdaten',
        paragraphs: [
          'Wenn du die Standortfreigabe erteilst, nutzt Munir den Standort, um '
              'Gebetszeiten und Qibla-Richtung genauer zu berechnen. Diese '
              'Berechnung erfolgt in der App.',
          'Bei der manuellen Stadtsuche kann der eingegebene Ort durch den '
              'Betriebssystem-Geocoder in Koordinaten umgewandelt werden. Die '
              'konkrete technische Verarbeitung haengt vom jeweiligen Betriebssystem '
              'und dessen Geocoding-Dienst ab.',
        ],
      ),
      _LegalSection(
        title: 'Moschee-Suche, Karten und externe Datenquellen',
        paragraphs: [
          'Wenn du der Moschee-Suche zustimmst, sendet Munir Koordinaten und '
              'Suchradius an die Overpass API, um Moscheen aus OpenStreetMap zu '
              'finden. Es wird kein Munir-Konto und keine Werbe-ID mitgeschickt.',
          'Kartenkacheln werden von CARTO geladen. Qur’an-Texte, Uebersetzungen, '
              'Transliteration und Audiodateien werden ueber alquran.cloud geladen. '
              'Dabei koennen technisch notwendige Verbindungsdaten wie IP-Adresse, '
              'Zeitpunkt, Anfrage und Geraete-/Browserinformationen bei den jeweiligen '
              'Anbietern anfallen.',
        ],
        bullets: [
          'OpenStreetMap/Overpass: https://overpass-api.de und https://www.openstreetmap.org',
          'CARTO-Kartenkacheln: https://carto.com',
          'Qur’an-Daten: https://alquran.cloud',
        ],
      ),
      _LegalSection(
        title: 'Optionales Konto und Synchronisierung',
        paragraphs: [
          'Die Anmeldung mit Google ist freiwillig. Wenn du dich anmeldest, nutzt '
              'Munir Google Sign-In und Firebase Authentication, um dein Konto zu '
              'erkennen. Dabei werden insbesondere technische Konto-IDs sowie je '
              'nach Google-Konto E-Mail-Adresse und Profilinformationen verarbeitet.',
          'Zur Synchronisierung speichert Munir in Firebase Cloud Firestore deinen '
              'Gebets-Tracker, deine Tasbih-Gesamtzahl, deinen Namen, die App-Sprache '
              'und einen Aktualisierungs-Zeitpunkt. Ohne Anmeldung bleiben diese Daten '
              'lokal auf deinem Geraet.',
        ],
      ),
      _LegalSection(
        title: 'Benachrichtigungen',
        paragraphs: [
          'Wenn du Benachrichtigungen aktivierst, plant Munir lokale Gebetszeit-'
              'Erinnerungen auf deinem Geraet. Die App sendet dafuer keine '
              'Benachrichtigungsinhalte an einen eigenen Server.',
        ],
      ),
      _LegalSection(
        title: 'Rechtsgrundlagen',
        bullets: [
          'Art. 6 Abs. 1 lit. b DSGVO: Bereitstellung der App-Funktionen, die du nutzt.',
          'Art. 6 Abs. 1 lit. a DSGVO: Standortfreigabe, Benachrichtigungen, optionale Moschee-Suche und optionale Anmeldung, soweit eine Einwilligung erforderlich ist.',
          'Art. 6 Abs. 1 lit. f DSGVO: Stabiler, sicherer und nachvollziehbarer App-Betrieb.',
        ],
      ),
      _LegalSection(
        title: 'Speicherdauer und Loeschung',
        paragraphs: [
          'Lokale Daten bleiben gespeichert, bis du sie in der App zuruecksetzt, '
              'Berechtigungen widerrufst, App-Daten loeschst oder die App deinstallierst.',
          'Wenn du angemeldet bist, kannst du dein Konto in der App unter '
              'Einstellungen > Konto > Konto loeschen entfernen. Dein Konto und '
              'alle zugehoerigen Daten werden dabei dauerhaft geloescht.',
          'Du kannst dein Konto und deine Daten auch loeschen lassen, ohne die '
              'App zu installieren: ${LegalProfile.accountDeletionUrl}',
        ],
      ),
      _LegalSection(
        title: 'Weitergabe von Daten',
        paragraphs: [
          'Eine Weitergabe erfolgt nur, soweit sie fuer die genannten Funktionen '
              'technisch notwendig ist, etwa an Google/Firebase bei optionaler '
              'Anmeldung, an Overpass/OpenStreetMap bei aktivierter Moschee-Suche, '
              'an CARTO fuer Karten und an alquran.cloud fuer Qur’an-Inhalte.',
          'Eine Nutzung zu Werbezwecken, Profilbildung fuer Werbung oder ein Verkauf '
              'personenbezogener Daten findet in Munir nicht statt.',
        ],
      ),
      _LegalSection(
        title: 'Deine Rechte',
        paragraphs: [
          'Du hast nach Massgabe der DSGVO insbesondere Rechte auf Auskunft, '
              'Berichtigung, Loeschung, Einschraenkung der Verarbeitung, '
              'Datenuebertragbarkeit sowie Widerspruch gegen bestimmte Verarbeitungen. '
              'Einwilligungen kannst du mit Wirkung fuer die Zukunft widerrufen.',
          'Du hast ausserdem das Recht, dich bei einer Datenschutzaufsichtsbehoerde '
              'zu beschweren.',
        ],
      ),
      _LegalSection(
        title: 'Kinder und sensible Nutzung',
        paragraphs: [
          'Munir richtet sich nicht gezielt an Kinder. Wenn Erziehungsberechtigte '
              'feststellen, dass ein Kind ohne erforderliche Zustimmung personenbezogene '
              'Daten bereitgestellt hat, koennen sie uns ueber die oben genannte '
              'Kontaktadresse erreichen.',
          'Religioese Nutzung kann sensibel sein. Munir verarbeitet keine Daten, um '
              'daraus religioese Profile fuer Werbung oder Tracking zu erstellen.',
        ],
      ),
      _LegalSection(
        title: 'Aenderungen',
        paragraphs: [
          'Diese Datenschutzerklaerung wird angepasst, wenn sich Funktionen, '
              'Datenverarbeitungen oder rechtliche Anforderungen aendern. Die jeweils '
              'aktuelle Fassung ist in der App und unter der oeffentlichen '
              'Datenschutz-URL abrufbar.',
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
