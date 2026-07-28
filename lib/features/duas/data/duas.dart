import 'package:flutter/material.dart';

/// Curated offline dua collection.
///
/// Kept local rather than fetched: the available free dua APIs
/// (dua-dhikr, Naikiyah) only serve Indonesian and English, and machine
/// translating supplications into German is not appropriate. Each entry below
/// carries its source so the wording can be checked.
class Dua {
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
  final DuaCategory category;

  const Dua({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.category,
  });
}

enum DuaCategory {
  daily('Alltag', Icons.checklist_rtl_outlined),
  morningEvening('Morgen & Abend', Icons.brightness_6_outlined),
  prayer('Gebet', Icons.mosque_outlined),
  food('Essen & Trinken', Icons.restaurant_outlined),
  travel('Reise', Icons.flight_outlined),
  protection('Schutz', Icons.shield_outlined),
  forgiveness('Vergebung', Icons.volunteer_activism_outlined),
  distress('Sorge & Not', Icons.healing_outlined);

  final String label;
  final IconData icon;
  const DuaCategory(this.label, this.icon);
}

const duas = <Dua>[
  // --- Alltag ---------------------------------------------------------------
  Dua(
    title: 'Beim Aufwachen',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    transliteration: 'Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur',
    translation:
        'Alles Lob gebührt Allah, der uns wieder zum Leben brachte, nachdem Er uns sterben ließ, und zu Ihm ist die Rückkehr.',
    source: 'Bukhari 6312',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Vor dem Schlafen',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    transliteration: 'Bismika Allahumma amutu wa ahya',
    translation: 'In Deinem Namen, o Allah, sterbe ich und lebe ich.',
    source: 'Bukhari 6324',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Vor dem Betreten der Toilette',
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبْثِ وَالْخَبَائِثِ',
    transliteration: 'Allahumma inni a\'udhu bika minal-khubuthi wal-khaba\'ith',
    translation:
        'O Allah, ich suche Zuflucht bei Dir vor den bösen männlichen und weiblichen Geistern.',
    source: 'Bukhari 142',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Beim Verlassen der Toilette',
    arabic: 'غُفْرَانَكَ',
    transliteration: 'Ghufranak',
    translation: 'Ich erbitte Deine Vergebung.',
    source: 'Abu Dawud 30',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Beim Verlassen des Hauses',
    arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
    translation:
        'Im Namen Allahs, ich vertraue auf Allah. Es gibt keine Macht und keine Kraft außer durch Allah.',
    source: 'Abu Dawud 5095',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Beim Betreten des Hauses',
    arabic: 'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى رَبِّنَا تَوَكَّلْنَا',
    transliteration:
        'Bismillahi walajna wa bismillahi kharajna wa \'ala Rabbina tawakkalna',
    translation:
        'Im Namen Allahs treten wir ein, im Namen Allahs gehen wir hinaus, und auf unseren Herrn vertrauen wir.',
    source: 'Abu Dawud 5096',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Beim Anziehen neuer Kleidung',
    arabic: 'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ',
    transliteration: 'Allahumma lakal-hamdu Anta kasawtanih',
    translation: 'O Allah, Dir gebührt das Lob, Du hast mich damit bekleidet.',
    source: 'Abu Dawud 4020',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Beim Betreten der Moschee',
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    transliteration: 'Allahumma iftah li abwaba rahmatik',
    translation: 'O Allah, öffne mir die Tore Deiner Barmherzigkeit.',
    source: 'Muslim 713',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Beim Verlassen der Moschee',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    transliteration: 'Allahumma inni as\'aluka min fadlik',
    translation: 'O Allah, ich bitte Dich um Deine Gunst.',
    source: 'Muslim 713',
    category: DuaCategory.daily,
  ),
  Dua(
    title: 'Bei Wissen und Verstehen',
    arabic: 'رَبِّ زِدْنِي عِلْمًا',
    transliteration: 'Rabbi zidni \'ilma',
    translation: 'Mein Herr, vermehre mein Wissen.',
    source: 'Qur\'an 20:114',
    category: DuaCategory.daily,
  ),

  // --- Morgen & Abend -------------------------------------------------------
  Dua(
    title: 'Morgen-Dhikr',
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    transliteration:
        'Asbahna wa asbahal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah',
    translation:
        'Wir sind in den Morgen getreten, und die Herrschaft gehört Allah. Alles Lob gebührt Allah. Es gibt keinen Gott außer Allah, dem Einen, der keinen Teilhaber hat.',
    source: 'Muslim 2723',
    category: DuaCategory.morningEvening,
  ),
  Dua(
    title: 'Abend-Dhikr',
    arabic:
        'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    transliteration:
        'Amsayna wa amsal-mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah',
    translation:
        'Wir sind in den Abend getreten, und die Herrschaft gehört Allah. Alles Lob gebührt Allah. Es gibt keinen Gott außer Allah, dem Einen, der keinen Teilhaber hat.',
    source: 'Muslim 2723',
    category: DuaCategory.morningEvening,
  ),
  Dua(
    title: 'Sayyidul-Istighfar',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
    transliteration:
        'Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana \'abduk, wa ana \'ala \'ahdika wa wa\'dika mastata\'t',
    translation:
        'O Allah, Du bist mein Herr, es gibt keinen Gott außer Dir. Du hast mich erschaffen und ich bin Dein Diener. Ich halte mich an Deinen Bund und Dein Versprechen, so gut ich kann.',
    source: 'Bukhari 6306',
    category: DuaCategory.morningEvening,
  ),
  Dua(
    title: 'Schutz am Morgen und Abend',
    arabic:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration:
        'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-sama\'i wa Huwas-Sami\'ul-\'Alim',
    translation:
        'Im Namen Allahs, mit dessen Namen nichts auf der Erde und nichts im Himmel schaden kann. Er ist der Allhörende, der Allwissende.',
    source: 'Abu Dawud 5088',
    category: DuaCategory.morningEvening,
  ),
  Dua(
    title: 'Zufriedenheit mit dem Glauben',
    arabic:
        'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    transliteration:
        'Raditu billahi Rabban, wa bil-Islami dinan, wa bi-Muhammadin sallallahu \'alayhi wa sallama nabiyyan',
    translation:
        'Ich bin zufrieden mit Allah als Herrn, mit dem Islam als Religion und mit Muhammad (Friede sei mit ihm) als Prophet.',
    source: 'Abu Dawud 1529',
    category: DuaCategory.morningEvening,
  ),

  // --- Gebet ----------------------------------------------------------------
  Dua(
    title: 'Nach dem Gebet',
    arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    transliteration: 'Allahumma a\'inni \'ala dhikrika wa shukrika wa husni \'ibadatik',
    translation:
        'O Allah, hilf mir, Dich zu gedenken, Dir zu danken und Dir auf beste Weise zu dienen.',
    source: 'Abu Dawud 1522',
    category: DuaCategory.prayer,
  ),
  Dua(
    title: 'Bittgebet im Qunut',
    arabic: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ وَعَافِنِي فِيمَنْ عَافَيْتَ',
    transliteration: 'Allahummahdini fiman hadayt, wa \'afini fiman \'afayt',
    translation:
        'O Allah, leite mich recht unter denen, die Du rechtgeleitet hast, und schenke mir Gesundheit unter denen, denen Du Gesundheit gegeben hast.',
    source: 'Tirmidhi 464',
    category: DuaCategory.prayer,
  ),
  Dua(
    title: 'Nach dem Adhan',
    arabic:
        'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ',
    transliteration:
        'Allahumma Rabba hadhihid-da\'watit-tammati was-salatil-qa\'imati ati Muhammadanil-wasilata wal-fadilah',
    translation:
        'O Allah, Herr dieses vollkommenen Rufes und des bevorstehenden Gebets, gewähre Muhammad die Fürsprache und die Auszeichnung.',
    source: 'Bukhari 614',
    category: DuaCategory.prayer,
  ),
  Dua(
    title: 'Istikhara (Bitte um Entscheidung)',
    arabic:
        'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ',
    transliteration:
        'Allahumma inni astakhiruka bi\'ilmika wa astaqdiruka biqudratika wa as\'aluka min fadlikal-\'azim',
    translation:
        'O Allah, ich bitte Dich um Führung durch Dein Wissen, um Kraft durch Deine Macht, und ich bitte Dich um Deine große Gunst.',
    source: 'Bukhari 1166',
    category: DuaCategory.prayer,
  ),

  // --- Essen & Trinken ------------------------------------------------------
  Dua(
    title: 'Vor dem Essen',
    arabic: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillah',
    translation: 'Im Namen Allahs.',
    source: 'Abu Dawud 3767',
    category: DuaCategory.food,
  ),
  Dua(
    title: 'Wenn das Bismillah vergessen wurde',
    arabic: 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
    transliteration: 'Bismillahi awwalahu wa akhirah',
    translation: 'Im Namen Allahs, zu Beginn und am Ende.',
    source: 'Abu Dawud 3767',
    category: DuaCategory.food,
  ),
  Dua(
    title: 'Nach dem Essen',
    arabic:
        'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
    transliteration:
        'Alhamdulillahil-ladhi at\'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah',
    translation:
        'Alles Lob gebührt Allah, der mir dies zu essen gab und mich damit versorgte, ohne Kraft und Vermögen meinerseits.',
    source: 'Abu Dawud 4023',
    category: DuaCategory.food,
  ),
  Dua(
    title: 'Beim Fastenbrechen',
    arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
    transliteration: 'Dhahabaz-zama\'u wabtallatil-\'uruqu wa thabatal-ajru in sha\'Allah',
    translation:
        'Der Durst ist gestillt, die Adern sind befeuchtet, und der Lohn steht fest, wenn Allah will.',
    source: 'Abu Dawud 2357',
    category: DuaCategory.food,
  ),
  Dua(
    title: 'Für den Gastgeber',
    arabic: 'اللَّهُمَّ بَارِكْ لَهُمْ فِيمَا رَزَقْتَهُمْ وَاغْفِرْ لَهُمْ وَارْحَمْهُمْ',
    transliteration: 'Allahumma barik lahum fima razaqtahum waghfir lahum warhamhum',
    translation:
        'O Allah, segne sie in dem, was Du ihnen gegeben hast, vergib ihnen und erbarme Dich ihrer.',
    source: 'Muslim 2042',
    category: DuaCategory.food,
  ),

  // --- Reise ----------------------------------------------------------------
  Dua(
    title: 'Beim Aufbruch zur Reise',
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ',
    transliteration: 'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin',
    translation:
        'Gepriesen sei Der, der uns dies dienstbar gemacht hat; wir selbst hätten es nicht bezwingen können.',
    source: 'Qur\'an 43:13, Muslim 1342',
    category: DuaCategory.travel,
  ),
  Dua(
    title: 'Bitte um eine leichte Reise',
    arabic: 'اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ',
    transliteration: 'Allahumma hawwin \'alayna safarana hadha watwi \'anna bu\'dah',
    translation:
        'O Allah, erleichtere uns diese Reise und verkürze für uns ihre Entfernung.',
    source: 'Muslim 1342',
    category: DuaCategory.travel,
  ),
  Dua(
    title: 'Bei der Ankunft an einem Ort',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
    translation:
        'Ich suche Zuflucht in den vollkommenen Worten Allahs vor dem Übel dessen, was Er erschaffen hat.',
    source: 'Muslim 2708',
    category: DuaCategory.travel,
  ),
  Dua(
    title: 'Für den Zurückbleibenden',
    arabic: 'أَسْتَوْدِعُكَ اللَّهَ الَّذِي لَا تَضِيعُ وَدَائِعُهُ',
    transliteration: 'Astawdi\'ukallahal-ladhi la tadi\'u wada\'i\'uh',
    translation:
        'Ich vertraue dich Allah an, dessen Anvertrautes niemals verloren geht.',
    source: 'Ibn Majah 2825',
    category: DuaCategory.travel,
  ),

  // --- Schutz ---------------------------------------------------------------
  Dua(
    title: 'Zuflucht vor dem Bösen',
    arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    transliteration: 'A\'udhu billahi minash-shaytanir-rajim',
    translation: 'Ich suche Zuflucht bei Allah vor dem verstoßenen Satan.',
    source: 'Qur\'an 16:98',
    category: DuaCategory.protection,
  ),
  Dua(
    title: 'Schutz für die Familie',
    arabic: 'أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ',
    transliteration: 'U\'idhukuma bikalimatillahit-tammati min kulli shaytanin wa hammah',
    translation:
        'Ich stelle euch unter den Schutz der vollkommenen Worte Allahs vor jedem Teufel und jedem schädlichen Tier.',
    source: 'Bukhari 3371',
    category: DuaCategory.protection,
  ),
  Dua(
    title: 'Ayatul-Kursi (Auszug)',
    arabic: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    transliteration: 'Allahu la ilaha illa Huwal-Hayyul-Qayyum',
    translation:
        'Allah – es gibt keinen Gott außer Ihm, dem Immerlebenden, dem aus sich selbst Bestehenden.',
    source: 'Qur\'an 2:255',
    category: DuaCategory.protection,
  ),
  Dua(
    title: 'Beim Gewitter',
    arabic: 'اللَّهُمَّ اسْقِنَا غَيْثًا مُغِيثًا',
    transliteration: 'Allahummasqina ghaythan mughithan',
    translation: 'O Allah, gib uns hilfreichen Regen.',
    source: 'Abu Dawud 1169',
    category: DuaCategory.protection,
  ),
  Dua(
    title: 'Gegen böse Blicke und Neid',
    arabic: 'مَا شَاءَ اللَّهُ تَبَارَكَ اللَّهُ',
    transliteration: 'Ma sha\'Allah, tabarakallah',
    translation: 'Was Allah gewollt hat. Gesegnet sei Allah.',
    source: 'Qur\'an 18:39 (Bedeutung)',
    category: DuaCategory.protection,
  ),

  // --- Vergebung ------------------------------------------------------------
  Dua(
    title: 'Kurzes Istighfar',
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    transliteration: 'Astaghfirullaha wa atubu ilayh',
    translation: 'Ich bitte Allah um Vergebung und kehre reuevoll zu Ihm zurück.',
    source: 'Bukhari 6307',
    category: DuaCategory.forgiveness,
  ),
  Dua(
    title: 'Bitte um Vergebung und Barmherzigkeit',
    arabic: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    transliteration:
        'Rabbana zalamna anfusana wa in lam taghfir lana wa tarhamna lanakunanna minal-khasirin',
    translation:
        'Unser Herr, wir haben uns selbst Unrecht getan. Wenn Du uns nicht vergibst und Dich unser nicht erbarmst, gehören wir gewiss zu den Verlierern.',
    source: 'Qur\'an 7:23',
    category: DuaCategory.forgiveness,
  ),
  Dua(
    title: 'Für die Eltern',
    arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
    transliteration: 'Rabbir-hamhuma kama rabbayani saghira',
    translation:
        'Mein Herr, erbarme Dich ihrer beider, so wie sie mich als Kind aufgezogen haben.',
    source: 'Qur\'an 17:24',
    category: DuaCategory.forgiveness,
  ),
  Dua(
    title: 'Bitte um Gutes in beiden Welten',
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration:
        'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adhaban-nar',
    translation:
        'Unser Herr, gib uns Gutes im Diesseits und Gutes im Jenseits und bewahre uns vor der Strafe des Feuers.',
    source: 'Qur\'an 2:201',
    category: DuaCategory.forgiveness,
  ),

  // --- Sorge & Not ----------------------------------------------------------
  Dua(
    title: 'Bei Sorge und Kummer',
    arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ',
    transliteration: 'Allahumma inni a\'udhu bika minal-hammi wal-hazani wal-\'ajzi wal-kasal',
    translation:
        'O Allah, ich suche Zuflucht bei Dir vor Sorge und Trauer, vor Unfähigkeit und Trägheit.',
    source: 'Bukhari 6369',
    category: DuaCategory.distress,
  ),
  Dua(
    title: 'Dua des Yunus in Not',
    arabic: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    transliteration: 'La ilaha illa Anta subhanaka inni kuntu minaz-zalimin',
    translation:
        'Es gibt keinen Gott außer Dir. Gepriesen seist Du. Gewiss, ich gehörte zu den Ungerechten.',
    source: 'Qur\'an 21:87',
    category: DuaCategory.distress,
  ),
  Dua(
    title: 'Bei schwerer Prüfung',
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Hasbunallahu wa ni\'mal-wakil',
    translation: 'Allah genügt uns, und Er ist der beste Sachwalter.',
    source: 'Qur\'an 3:173',
    category: DuaCategory.distress,
  ),
  Dua(
    title: 'Für einen Kranken',
    arabic: 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
    transliteration: 'As\'alullahal-\'Azima Rabbal-\'arshil-\'azimi an yashfiyak',
    translation:
        'Ich bitte Allah, den Erhabenen, den Herrn des großen Thrones, dass Er dich heilt.',
    source: 'Abu Dawud 3106',
    category: DuaCategory.distress,
  ),
  Dua(
    title: 'Bei Trauer um einen Verstorbenen',
    arabic: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
    transliteration: 'Inna lillahi wa inna ilayhi raji\'un',
    translation: 'Wir gehören Allah, und zu Ihm kehren wir zurück.',
    source: 'Qur\'an 2:156',
    category: DuaCategory.distress,
  ),
];
