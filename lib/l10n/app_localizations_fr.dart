// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Munir';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPrayers => 'Prière';

  @override
  String get navQuran => 'Coran';

  @override
  String get navTasbih => 'Tasbih';

  @override
  String get navQibla => 'Qibla';

  @override
  String greeting(String name) {
    return 'Assalamu alaikum, $name';
  }

  @override
  String get greetingNoName => 'Assalamu alaikum';

  @override
  String get nextPrayer => 'Prochaine prière';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'dans $hours h $minutes min';
  }

  @override
  String inMinutesSeconds(int minutes, int seconds) {
    return 'dans $minutes min $seconds s';
  }

  @override
  String get todaysProgress => 'Progression du jour';

  @override
  String get overallProgress => 'Progression totale';

  @override
  String percentComplete(int percent) {
    return '$percent % accompli';
  }

  @override
  String get prayerNotYetDue => 'Cette prière n\'est pas encore venue.';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsStreakLabel => 'Jours d\'affilée';

  @override
  String get statsBestLabel => 'Record';

  @override
  String get statsWeekLabel => '7 derniers jours';

  @override
  String get statsTotalLabel => 'Prières notées';

  @override
  String statsWeekValue(int done) {
    return '$done/7';
  }

  @override
  String statsWeakest(String prayer) {
    return 'La plus manquée récemment : $prayer';
  }

  @override
  String get statsEmpty =>
      'Note ta première prière — tes chiffres apparaîtront ici.';

  @override
  String get streakTitle => 'Ta série de prières';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours d\'affilée',
      one: '1 jour d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String streakBest(int count) {
    return 'Record : $count';
  }

  @override
  String get streakMilestoneTitle => 'Étape franchie !';

  @override
  String streakMilestoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours d\'affilée',
      one: '1 jour d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String get praiseTitle => 'MachaAllah !';

  @override
  String praiseAllPrayers(int completed, int total) {
    return '$completed/$total accomplies';
  }

  @override
  String tasbihTotal(int count) {
    return '$count au total';
  }

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Lever du soleil';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get quickMosques => 'Mosquées';

  @override
  String get quickQibla => 'Qibla';

  @override
  String get quickDuas => 'Douas';

  @override
  String get quickNames => '99 Noms';

  @override
  String get locationWarning =>
      'Pas d\'accès à la position. Les horaires utilisent les valeurs par défaut (Berlin).';

  @override
  String get activate => 'Activer';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String todayShort(String date) {
    return 'Aujourd\'hui, $date';
  }

  @override
  String get mosquesTitle => 'Mosquées';

  @override
  String get mosquesRadius => 'Rayon';

  @override
  String mosquesKm(int km) {
    return '$km km';
  }

  @override
  String get mosquesRefresh => 'Actualiser';

  @override
  String get mosquesShowList => 'Liste';

  @override
  String get mosquesShowMap => 'Carte';

  @override
  String get mosquesRoute => 'Itinéraire';

  @override
  String get mosquesWebsite => 'Site web';

  @override
  String get mosquesCall => 'Appeler';

  @override
  String mosquesEmpty(int km) {
    return 'Aucune mosquée trouvée dans un rayon de $km km.';
  }

  @override
  String get mosquesRetry => 'Réessayer';

  @override
  String get mosquesCouldNotOpen => 'Impossible d\'ouvrir.';

  @override
  String mosquesDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get mosquesConsentTitle => 'Trouver des mosquées près de vous';

  @override
  String get mosquesConsentBody =>
      'Vos coordonnées seront envoyées à OpenStreetMap. Aucune autre donnée n\'est transmise.';

  @override
  String get mosquesConsentAccept => 'Accepter et chercher';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get qiblaTurnToKaaba => 'Tournez-vous vers la Kaaba';

  @override
  String qiblaDistanceToMecca(String km) {
    return 'Distance jusqu\'à La Mecque : $km km';
  }

  @override
  String get qiblaNoCompass => 'Votre appareil n\'a pas de boussole.';

  @override
  String get tasbihTitle => 'Tasbih';

  @override
  String get tasbihTapToCount => 'Touchez pour compter';

  @override
  String tasbihRound(int round) {
    return 'Tour $round';
  }

  @override
  String get tasbihReset => 'Réinitialiser';

  @override
  String get quranTitle => 'Coran';

  @override
  String quranVerses(int count) {
    return '$count versets';
  }

  @override
  String get quranSearchHint => 'Rechercher une sourate…';

  @override
  String get duasTitle => 'Douas';

  @override
  String get duasSearchHint => 'Rechercher une doua…';

  @override
  String duasCount(int count) {
    return '$count douas';
  }

  @override
  String get namesTitle => 'Les 99 Noms';

  @override
  String get namesSearchHint => 'Rechercher un nom ou un sens…';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionPrayer => 'Prière';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsSectionDisplay => 'Affichage';

  @override
  String get settingsSectionData => 'Données';

  @override
  String get settingsSectionLegal => 'Mentions légales';

  @override
  String get settingsLocation => 'Position';

  @override
  String get settingsLocationHint => 'Touchez pour redéterminer';

  @override
  String get settingsCalculationMethod => 'Méthode de calcul';

  @override
  String get settingsMadhab => 'École juridique';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsName => 'Nom';

  @override
  String get settingsNameHint => 'Comment devons-nous vous appeler ?';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsMosqueConsent => 'Autoriser la recherche de mosquées';

  @override
  String get settingsMosqueConsentHint =>
      'Envoie vos coordonnées à OpenStreetMap';

  @override
  String get settingsClearMapCache => 'Vider le cache des cartes';

  @override
  String get settingsClearMapCacheHint => 'Supprimer les tuiles enregistrées';

  @override
  String get settingsClearMapCacheDone => 'Cache des cartes vidé.';

  @override
  String get settingsResetTracker => 'Réinitialiser l\'historique';

  @override
  String get settingsResetTrackerHint =>
      'Supprime toutes les prières cochées et la série';

  @override
  String get settingsResetTrackerConfirm =>
      'Vraiment réinitialiser ? Toutes les prières cochées et votre série seront perdues.';

  @override
  String get settingsResetTrackerDone => 'Historique réinitialisé.';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsImprint => 'Mentions légales';

  @override
  String get settingsNotConfigured => 'Pas encore renseigné';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonDone => 'Terminé';

  @override
  String commonComingSoon(String feature) {
    return '$feature bientôt disponible !';
  }

  @override
  String get onboardingLanguageTitle => 'Choisir la langue';

  @override
  String get onboardingNameTitle => 'Comment vous appelez-vous ?';

  @override
  String get onboardingNameHint => 'Votre nom';

  @override
  String get onboardingLocationTitle => 'Position';

  @override
  String get onboardingLocationBody =>
      'Nous avons besoin de votre position pour des horaires précis.';

  @override
  String get onboardingLocationAllow => 'Autoriser la position';

  @override
  String get onboardingLocationManual => 'Choisir une ville manuellement';

  @override
  String get onboardingMethodTitle => 'Méthode de calcul';

  @override
  String get onboardingAdhanTitle => 'Voix de l\'adhan';

  @override
  String get onboardingDoneTitle => 'Tout est prêt';

  @override
  String get onboardingDoneBody =>
      'Que cette application vous accompagne dans vos prières.';

  @override
  String get onboardingStart => 'C\'est parti';

  @override
  String notificationPrayerTimeTitle(String prayer, String time) {
    return 'C\'est l\'heure de $prayer · $time';
  }

  @override
  String get notificationBodyFajr =>
      'الصلاة خير من النوم\nLa prière vaut mieux que le sommeil.';

  @override
  String get notificationBodyDhuhr =>
      'La journée est devenue bruyante. Dhuhr est l\'instant où elle se tait — prends-le avant qu\'il passe.';

  @override
  String get notificationBodyAsr =>
      'La lumière devient dorée. Prends cet instant et accomplis ta prière d\'Asr.';

  @override
  String get notificationBodyMaghrib =>
      'Le soleil s\'est couché. Un instant de gratitude.';

  @override
  String get notificationBodyIsha =>
      'La journée est finie, la dernière prière ne l\'est pas. Accomplis Isha avant de dormir.';

  @override
  String notificationLocationLine(String city) {
    return 'Calculé pour $city';
  }

  @override
  String notificationCatchUpTitle(String prayer) {
    return '$prayer se termine bientôt';
  }

  @override
  String notificationCatchUpBody(String next, String time) {
    return 'Profite du temps qu\'il reste avant que $next commence à $time.';
  }

  @override
  String get notificationCatchUpChannelName => 'Prières en attente';

  @override
  String get notificationCatchUpChannelDescription =>
      'Rappel lorsqu\'une prière n\'a pas encore été notée';

  @override
  String get settingsCatchUpReminders => 'Rappeler les prières en attente';

  @override
  String get settingsCatchUpRemindersHint =>
      '30 minutes avant la prière suivante, si rien n\'est encore noté';

  @override
  String get settingsMadhabShafiHint =>
      'Aussi Maliki et Hanbali — Asr plus tôt';

  @override
  String get settingsMadhabHanafiHint => 'Asr plus tard';

  @override
  String get settingsNotSet => 'non défini';

  @override
  String get qiblaAligned => 'Aligné — vers La Mecque';

  @override
  String get settingsDataSources => 'Sources des données';

  @override
  String get nowLabel => 'maintenant';

  @override
  String get onboardingLanguageSubtitle => 'Vous pourrez changer à tout moment';

  @override
  String get onboardingNameQuestion => 'Comment devons-nous vous appeler ?';

  @override
  String get onboardingNameSubtitle => 'Pour votre salutation personnelle.';

  @override
  String onboardingNamePreview(String name) {
    return 'p. ex. pour « Assalamu alaikum, $name »';
  }

  @override
  String get onboardingLocationDetect => 'Détecter la position automatiquement';

  @override
  String get onboardingLocationSearch => 'Rechercher une ville…';

  @override
  String get onboardingLocationSkip => 'Continuer sans position';

  @override
  String get onboardingLocationPrivacy =>
      'Les horaires et la qibla sont calculés sur votre appareil. Seule la recherche de mosquées envoie votre position — après votre accord.';

  @override
  String onboardingLocationDetected(String city) {
    return 'Position détectée : $city';
  }

  @override
  String get onboardingLocationNotFound => 'Lieu introuvable.';

  @override
  String get onboardingLocationSearchFailed =>
      'Échec de la recherche. Vérifie ta connexion.';

  @override
  String get onboardingMethodHeading => 'Ajuster les horaires';

  @override
  String get onboardingMethodSection => 'MÉTHODE DE CALCUL';

  @override
  String get onboardingMadhabSection => 'CALCUL DU ASR (MADHAB)';

  @override
  String get onboardingAdhanHeading => 'Rappels de l\'adhan';

  @override
  String get onboardingAdhanBody =>
      'Recevez un rappel discret à chaque prière.';

  @override
  String get onboardingAdhanEnable => 'Activer les notifications';

  @override
  String get onboardingAdhanEnabled => 'Notifications activées.';

  @override
  String get onboardingAdhanDenied => 'Autorisation refusée.';

  @override
  String get onboardingDoneHeading => 'Tout est prêt';

  @override
  String onboardingDoneHeadingNamed(String name) {
    return 'Tout est prêt, $name';
  }

  @override
  String get onboardingDoneCompanion =>
      'Que Munir vous accompagne tout au long de la journée.';

  @override
  String get onboardingOpenApp => 'Ouvrir l\'application';

  @override
  String get onboardingAdhanOn => 'Adhan activé';

  @override
  String get onboardingAdhanOff => 'Adhan désactivé';

  @override
  String get featurePrayerTitle => 'Ne manquez plus une prière';

  @override
  String get featurePrayerBody =>
      'Des horaires précis pour votre position, avec rappel de l\'adhan.';

  @override
  String get featureQiblaTitle => 'Trouvez la direction de la qibla';

  @override
  String get featureQiblaBody =>
      'Une boussole précise vous oriente vers La Mecque partout.';

  @override
  String get featureQuranTitle => 'Le Coran, toujours avec vous';

  @override
  String get featureQuranBody =>
      'Lisez, écoutez et suivez vos progrès — hors ligne.';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonNext => 'Suivant';

  @override
  String get onboardingLocationQuestion => 'Où vous trouvez-vous ?';

  @override
  String get notificationChannelName => 'Heures de prière';

  @override
  String get notificationChannelDescription =>
      'Rappels pour les horaires de prière quotidiens';

  @override
  String get onboardingLocationWhy =>
      'Nous avons besoin de votre position pour des horaires précis et la direction de la qibla.';

  @override
  String get commonOr => 'ou';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsSignInGoogle => 'Se connecter avec Google';

  @override
  String get settingsSignInApple => 'Se connecter avec Apple';

  @override
  String get settingsSignInWhy =>
      'Sauvegarde votre historique de prières et le synchronise entre vos appareils';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountHint =>
      'Supprime définitivement votre compte et toutes les données enregistrées';

  @override
  String get settingsDeleteAccountConfirm =>
      'Vraiment supprimer votre compte ? Votre historique sera définitivement supprimé — du compte et de cet appareil. C\'est irréversible.';

  @override
  String get onboardingPrivacyLink => 'Lire la politique de confidentialité';

  @override
  String get adoptLocalDataTitle => 'Ajouter les entrées existantes ?';

  @override
  String get adoptLocalDataBody =>
      'Cet appareil contient des entrées qui n\'appartiennent encore à aucun compte. Les ajouter à ton compte ? Si tu as récupéré cet appareil de quelqu\'un d\'autre, supprime-les.';

  @override
  String adoptLocalDataBodyCounted(int count) {
    return 'Cet appareil contient $count prières enregistrées qui n\'appartiennent encore à aucun compte. Les ajouter à ton compte ? Si tu as récupéré cet appareil de quelqu\'un d\'autre, supprime-les.';
  }

  @override
  String get adoptLocalDataKeep => 'Ajouter';

  @override
  String get adoptLocalDataDiscard => 'Supprimer';

  @override
  String get settingsSignOutConfirm =>
      'Se déconnecter ? Tes entrées sont d\'abord sauvegardées dans ton compte, puis retirées de cet appareil. Elles reviennent à la prochaine connexion. Une connexion internet est nécessaire.';

  @override
  String get settingsSignOutNeedsConnection =>
      'La déconnexion nécessite une connexion — tes entrées sont d\'abord sauvegardées dans ton compte. Réessaie plus tard.';

  @override
  String settingsSignedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get settingsSignInFailed => 'Échec de la connexion.';

  @override
  String get settingsSyncNow => 'Synchroniser';

  @override
  String get settingsSyncDone => 'Synchronisé.';

  @override
  String get settingsAccountDeleted => 'Compte supprimé.';

  @override
  String get onboardingAccountTitle => 'Conservez votre progression';

  @override
  String get onboardingAccountBody =>
      'Avec un compte, votre historique de prières est conservé — même en changeant d\'appareil. Sans compte, tout reste uniquement sur cet appareil.';

  @override
  String get commonLater => 'Plus tard';

  @override
  String quranTranslationCredit(String translator) {
    return 'Traduction : $translator';
  }

  @override
  String get quranSourceCredit =>
      'Texte arabe, translittération et récitation via alquran.cloud';

  @override
  String get settingsLicenses => 'Licences open source';

  @override
  String get settingsLicensesHint =>
      'Textes de licence des bibliothèques utilisées';

  @override
  String get mosqueConsentHeading => 'Trouver des mosquées à proximité';

  @override
  String get mosqueConsentBody =>
      'Votre position actuelle est envoyée à l\'API Overpass (exploitée par FOSSGIS e.V.) pour effectuer la recherche de proximité dans les données OpenStreetMap.\n\nC\'est la seule fonction où votre position quitte l\'appareil. Aucune autre donnée ni identifiant n\'est transmis.';

  @override
  String get mosqueConsentAccept => 'Accepter et rechercher des mosquées';

  @override
  String get mosqueConsentRevocable =>
      'Vous pouvez révoquer cela à tout moment.';

  @override
  String get mosqueSearching => 'Recherche de mosquées …';

  @override
  String get mosqueUnnamed => 'Mosquée (sans nom)';

  @override
  String get qiblaCalibrateAction => 'Calibrer la boussole';

  @override
  String get qiblaCalibrateHint =>
      'Déplacez votre appareil en formant un huit (∞) pour calibrer la boussole.';

  @override
  String get qiblaNeedsLocation =>
      'Une qibla précise nécessite votre position actuelle.';

  @override
  String get qiblaLocationUnavailable =>
      'La position est indisponible. Activez-la dans les réglages.';

  @override
  String get qiblaCompassUnsupported =>
      'Aucune boussole disponible sur cet appareil.';

  @override
  String get qiblaInaccurate =>
      'La direction est imprécise. Déplacez votre appareil en formant un huit (∞).';

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés.';

  @override
  String get locationPermissionDenied => 'L\'accès à la position a été refusé.';

  @override
  String get locationNoFix =>
      'Aucune position actuelle disponible. Recherchez une ville manuellement.';

  @override
  String get locationDetecting => 'Détection de la position …';

  @override
  String get locationUnavailableShort => 'indisponible';

  @override
  String get settingsNamePlaceholder => 'Votre nom';

  @override
  String get commonLoadFailed => 'Échec du chargement.';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get surahSearchOpen => 'Rechercher des sourates';

  @override
  String get surahSearchClose => 'Fermer la recherche';

  @override
  String get surahSearchClear => 'Effacer la recherche';

  @override
  String get quranProgressHeading => 'Votre progression';

  @override
  String get quranProgressEmpty =>
      'Votre progression apparaît ici dès que vous avez lu un verset.';

  @override
  String get quranArabicTextSize => 'Taille du texte (arabe)';

  @override
  String get namesNoMatch => 'Aucun nom trouvé.';

  @override
  String get adviceTomorrow => 'Demain, le prochain conseil apparaîtra ici.';

  @override
  String get locationLabelFallback => 'Position';

  @override
  String get mosqueSearchBusy =>
      'Le service de recherche est surchargé. Réessayez dans quelques minutes.';

  @override
  String get mosqueSearchFailed => 'La recherche de mosquées a échoué.';

  @override
  String get quranShowTranslation => 'Afficher la traduction';

  @override
  String get adviceSectionLabel => 'CONSEIL DU JOUR';

  @override
  String get adviceReadMore => 'Lire la suite';

  @override
  String get adviceActionLabel => 'À FAIRE AUJOURD’HUI';

  @override
  String get surahSearchHint => 'Rechercher une sourate';

  @override
  String dateToday(String date) {
    return 'Aujourd\'hui, $date';
  }

  @override
  String get qiblaCalibrating =>
      'Calibrage de la boussole. Tenez l\'appareil à plat et déplacez-le en formant un huit (∞).';

  @override
  String get qiblaNoLocationForCompass =>
      'Activez l\'accès à la position pour une qibla précise.';

  @override
  String get qiblaNoLocationFix => 'La position n\'a pas pu être déterminée.';

  @override
  String get quranAudioFailed => 'La récitation n\'a pas pu être chargée.';

  @override
  String get quranPlaybackSpeed => 'Vitesse de lecture';
}
