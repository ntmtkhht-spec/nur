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
  String get settingsAdhanVoice => 'Voix de l\'adhan';

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
  String notificationPrayerTimeTitle(String prayer) {
    return 'C\'est l\'heure de $prayer';
  }

  @override
  String get notificationBodyFajr =>
      'Le jour commence dans le silence — un instant de calme pour toi.';

  @override
  String get notificationBodyDhuhr =>
      'Une courte pause dans la journée. Le moment de souffler.';

  @override
  String get notificationBodyAsr =>
      'La lumière devient dorée. L\'heure de la prière d\'Asr.';

  @override
  String get notificationBodyMaghrib =>
      'Le soleil se couche — un instant de gratitude.';

  @override
  String get notificationBodyIsha => 'Laisse la journée s\'apaiser.';

  @override
  String get settingsMadhabShafiHint =>
      'Aussi Maliki et Hanbali — Asr plus tôt';

  @override
  String get settingsMadhabHanafiHint => 'Asr plus tard';

  @override
  String get muezzinSilent => 'Vibration seule / silencieux';

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
  String get onboardingMuezzinSection => 'VOIX DU MUEZZIN';

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
      'Vraiment supprimer votre compte ? Votre historique sur les serveurs sera définitivement supprimé. Les données de cet appareil sont conservées.';

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
}
