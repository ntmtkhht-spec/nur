/// One entry of the daily guide shown on the home screen.
///
/// The old home banner only carried a headline and a single line, so opening
/// it had nothing to show. Every entry here is written to be worth opening:
/// the card shows [title] and [teaser], the detail sheet adds the reasoning in
/// [body], where the advice comes from in [source], and one concrete thing to
/// do today in [action].
class DailyAdvice {
  final String title;
  final String teaser;
  final String body;
  final String source;
  final String action;

  const DailyAdvice({
    required this.title,
    required this.teaser,
    required this.body,
    required this.source,
    required this.action,
  });
}

/// Curated offline guide, one entry per day.
///
/// Kept local for the same reason as the dua collection: there is no free API
/// that serves this material in German, and machine translating Qur'an and
/// hadith is not appropriate. Every entry names its source so the wording can
/// be checked. Qur'an renderings are paraphrases of the meaning, not a
/// translation anyone should quote as one.
const dailyAdvices = <DailyAdvice>[
  DailyAdvice(
    title: 'Reinige deine Absicht',
    teaser: 'Dieselbe Tat kann alles oder nichts wert sein.',
    body:
        'Zwei Menschen tun äußerlich das Gleiche — und bei Allah zählt es '
        'völlig unterschiedlich, weil die Absicht unterschiedlich ist. Die '
        'Niyyah ist nichts, was man aussprechen muss; sie ist die stille '
        'Antwort auf die Frage, für wen du gerade handelst. Und sie lässt '
        'sich mitten in der Tat noch korrigieren.',
    source: 'Bukhari 1, Muslim 1907',
    action:
        'Halte vor der nächsten Aufgabe drei Sekunden inne und frage dich: '
        'für wen mache ich das?',
  ),
  DailyAdvice(
    title: 'Dhikr beruhigt das Herz',
    teaser: 'Unruhe ist selten ein Zeitproblem.',
    body:
        'Der Quran nennt das Gedenken Allahs ausdrücklich als das, wobei die '
        'Herzen zur Ruhe kommen. Dhikr braucht keinen besonderen Ort und '
        'keinen Gebetsteppich — er passt in den Weg zur Arbeit, in die '
        'Warteschlange, in die Minuten vor dem Einschlafen.',
    source: 'Quran 13:28',
    action:
        'Sag heute 33-mal SubhanAllah, 33-mal Alhamdulillah und 34-mal '
        'Allahu akbar — nebenbei, ohne extra Termin.',
  ),
  DailyAdvice(
    title: 'Bitte um Vergebung',
    teaser: 'Der Prophet ﷺ tat es täglich — obwohl ihm vergeben war.',
    body:
        'Istighfar ist kein Notfallknopf für große Sünden, sondern tägliche '
        'Pflege. Überliefert ist, dass der Prophet ﷺ sich mehr als '
        'siebzigmal am Tag an Allah um Vergebung wandte. Wer das zur '
        'Gewohnheit macht, trägt weniger mit sich herum.',
    source: 'Bukhari 6307; Quran 71:10',
    action:
        'Sprich heute nach jedem Gebet dreimal Astaghfirullah, bevor du '
        'aufstehst.',
  ),
  DailyAdvice(
    title: 'Sei dankbar',
    teaser: 'Dankbarkeit ist eine Übung, kein Gefühl.',
    body:
        'Allah verknüpft Dankbarkeit mit Mehrung: Wer dankbar ist, dem wird '
        'mehr gegeben. Das Schwierige daran ist, dass wir uns an alles '
        'gewöhnen — an Gesundheit, an ein Dach, an Menschen. Dankbarkeit '
        'heißt, das Gewöhnliche wieder als Gabe zu sehen.',
    source: 'Quran 14:7',
    action:
        'Nenne heute Abend drei konkrete Dinge von diesem Tag, für die du '
        'Alhamdulillah sagst.',
  ),
  DailyAdvice(
    title: 'Geduld ist Handeln',
    teaser: 'Sabr heißt nicht aushalten, sondern durchhalten.',
    body:
        'Sabr wird oft mit Passivität verwechselt. Gemeint ist das Gegenteil: '
        'weitermachen, ohne die Fassung und die Aufrichtigkeit zu verlieren. '
        'Der Quran nennt Gebet und Geduld in einem Atemzug als das, worin man '
        'Hilfe sucht.',
    source: 'Quran 2:45, 2:153',
    action:
        'Wenn dich heute etwas aus der Ruhe bringt, warte einen Atemzug, '
        'bevor du reagierst.',
  ),
  DailyAdvice(
    title: 'Sprich Gutes oder schweige',
    teaser: 'Zwei Optionen — die dritte gibt es nicht.',
    body:
        'Die Regel ist knapp: Wer an Allah und den Jüngsten Tag glaubt, soll '
        'Gutes sprechen oder schweigen. Kein Zwang zur Rede, aber auch kein '
        'Freiraum für Schädliches. Das meiste, was wir später bereuen, '
        'entsteht in Sätzen, die niemand gebraucht hätte.',
    source: 'Bukhari 6018, Muslim 47',
    action:
        'Lass heute einen Kommentar weg, von dem du weißt, dass er nur weh '
        'tut.',
  ),
  DailyAdvice(
    title: 'Vertraue auf Allah',
    teaser: 'Tawakkul ersetzt die Arbeit nicht — es trägt das Ergebnis.',
    body:
        'Tawakkul bedeutet: du bindest dein Kamel an und vertraust dann auf '
        'Allah. Plane, bereite vor, gib dein Bestes — und lege das, was nicht '
        'in deiner Hand liegt, zu Ihm. Wer auf Allah vertraut, dem genügt Er.',
    source: 'Quran 65:2-3',
    action:
        'Nimm eine Sache, die dich beschäftigt: mach heute den nächsten '
        'machbaren Schritt und lass den Rest los.',
  ),
  DailyAdvice(
    title: 'Hilf deinem Nächsten',
    teaser: 'Allah hilft dem Diener, solange dieser seinem Bruder hilft.',
    body:
        'Hilfe muss nicht groß sein, um zu zählen. Eine Nachricht, eine '
        'Mitfahrt, ein Anruf bei jemandem, den alle vergessen haben. Die '
        'Überlieferung verspricht, dass Allah dem beisteht, der anderen '
        'beisteht — und wer eine Not löst, dessen Not wird gelöst.',
    source: 'Muslim 2699',
    action: 'Erledige heute eine kleine Sache für jemanden, ungefragt.',
  ),
  DailyAdvice(
    title: 'Sei demütig',
    teaser: 'Niemand verliert durch Bescheidenheit an Rang.',
    body:
        'Überliefert ist, dass Allah den erhöht, der sich um Seinetwillen '
        'bescheiden macht. Demut ist nicht Selbstabwertung, sondern ein '
        'realistischer Blick: alles, was du hast, ist geliehen — Gesundheit, '
        'Wissen, Zeit, Ansehen.',
    source: 'Muslim 2588; Quran 25:63',
    action:
        'Höre heute in einem Gespräch zu Ende zu, ohne dich zu vergleichen '
        'oder zu korrigieren.',
  ),
  DailyAdvice(
    title: 'Nutze deine Zeit',
    teaser: 'Sura al-Asr schwört bei der Zeit — und nennt uns im Verlust.',
    body:
        'Zeit ist das Einzige, was sich nicht nachkaufen lässt. Al-Asr fasst '
        'es hart zusammen: der Mensch ist im Verlust, außer denen, die '
        'glauben, Gutes tun und einander zur Wahrheit und zur Geduld raten. '
        'Der Maßstab ist nicht Beschäftigung, sondern Inhalt.',
    source: 'Quran 103:1-3',
    action:
        'Streiche heute eine halbe Stunde Bildschirmzeit und stecke sie in '
        'etwas, das bleibt.',
  ),
  DailyAdvice(
    title: 'Bete zur rechten Zeit',
    teaser: 'Gefragt nach der besten Tat: das Gebet zu seiner Zeit.',
    body:
        'Der Prophet ﷺ wurde gefragt, welche Tat Allah am liebsten ist, und '
        'nannte zuerst das Gebet zu seiner Zeit. Nicht das längste Gebet, '
        'nicht das schönste — das pünktliche. Der Rest des Tages ordnet sich '
        'überraschend oft von selbst darum herum.',
    source: 'Bukhari 527, Muslim 85; Quran 29:45',
    action:
        'Bete heute mindestens ein Gebet direkt am Anfang seiner Zeit, nicht '
        'am Ende.',
  ),
  DailyAdvice(
    title: 'Gib Sadaqa',
    teaser: 'Sie löscht Sünden, wie Wasser Feuer löscht.',
    body:
        'Sadaqa ist nicht an Beträge gebunden. Überliefert ist sogar, dass '
        'ein Lächeln ins Gesicht deines Bruders Sadaqa ist. Entscheidend ist '
        'die Regelmäßigkeit: kleine Gaben, die nicht aufhören, sind mehr wert '
        'als eine große, die einmal vorkommt.',
    source: 'Tirmidhi 2616, Tirmidhi 1956',
    action:
        'Gib heute etwas ab — Geld, Essen oder Zeit —, ohne davon zu '
        'erzählen.',
  ),
  DailyAdvice(
    title: 'Kontrolliere deinen Zorn',
    teaser: 'Stark ist, wer sich im Zorn beherrscht.',
    body:
        'Der Prophet ﷺ sagte, der Starke sei nicht der, der andere niederringt, '
        'sondern der, der sich beherrscht, wenn er zornig wird. Der Quran lobt '
        'die, die den Zorn zurückhalten und den Menschen verzeihen. Zorn '
        'verschwindet nicht — er wird gehalten.',
    source: 'Bukhari 6114, Muslim 2609; Quran 3:134',
    action:
        'Wenn heute Wut hochkommt: schweig, atme, und ändere die Körperhaltung, '
        'bevor du sprichst.',
  ),
  DailyAdvice(
    title: 'Pflege die Verwandtschaft',
    teaser: 'Silat ar-Rahim weitet Rizq und Lebenszeit.',
    body:
        'Verwandtschaftsbande zu pflegen heißt nicht, nur die zu besuchen, '
        'die auch zu dir kommen. Gemeint ist gerade der Kontakt zu denen, die '
        'abgebrochen haben. Überliefert ist, dass Allah dem, der die Bande '
        'pflegt, Versorgung und Lebenszeit weitet.',
    source: 'Bukhari 5986',
    action:
        'Ruf heute den Verwandten an, bei dem du es am längsten aufschiebst.',
  ),
  DailyAdvice(
    title: 'Ehre deine Eltern',
    teaser: 'Direkt nach dem Recht Allahs genannt.',
    body:
        'Der Quran stellt die Güte zu den Eltern unmittelbar neben das Verbot, '
        'Allah etwas beizugesellen — und verbietet ausdrücklich schon das '
        'genervte Wort. Gemeint ist der Ton im Alltag, nicht nur die große '
        'Geste an Feiertagen.',
    source: 'Quran 17:23-24',
    action:
        'Sag deinen Eltern heute etwas Freundliches, ohne dass ein Anlass '
        'dafür nötig ist.',
  ),
  DailyAdvice(
    title: 'Achte den Nachbarn',
    teaser: 'Jibril mahnte so oft wegen des Nachbarn, dass …',
    body:
        'Überliefert ist, dass Jibril den Propheten ﷺ so beharrlich wegen des '
        'Nachbarn ermahnte, dass dieser meinte, der Nachbar werde zum Erben '
        'eingesetzt. Nachbarschaft ist im Islam kein Zufall der Wohnlage, '
        'sondern ein Recht — unabhängig vom Glauben des Nachbarn.',
    source: 'Bukhari 6014, Muslim 2624',
    action: 'Grüße heute einen Nachbarn, den du sonst nur anschweigst.',
  ),
  DailyAdvice(
    title: 'Besuche die Kranken',
    teaser: 'Ein Recht des Muslims gegenüber dem Muslim.',
    body:
        'Die Überlieferung zählt die Rechte auf: den Gruß erwidern, der '
        'Einladung folgen, den Kranken besuchen, der Beerdigung folgen. Ein '
        'Besuch dauert zehn Minuten und wird jahrelang erinnert. Wo kein '
        'Besuch möglich ist, zählt der Anruf.',
    source: 'Muslim 2162, Bukhari 1240',
    action:
        'Melde dich heute bei jemandem, der krank ist oder gerade nicht '
        'aufstehen kann.',
  ),
  DailyAdvice(
    title: 'Lies den Quran',
    teaser: 'Jeder Buchstabe zählt — auch die zwei Zeilen zwischendurch.',
    body:
        'Überliefert ist, dass für jeden gelesenen Buchstaben eine gute Tat '
        'geschrieben wird, zehnfach vergolten. Der beste unter euch, heißt es '
        'weiter, sei der, der den Quran lernt und lehrt. Wenig und '
        'regelmäßig schlägt viel und selten.',
    source: 'Tirmidhi 2910, Bukhari 5027',
    action:
        'Lies heute eine Seite — mit Übersetzung, damit du weißt, was du '
        'liest.',
  ),
  DailyAdvice(
    title: 'Strebe nach Wissen',
    teaser: 'Die einzige Bitte um Mehrung im Quran betrifft Wissen.',
    body:
        'Der Quran lehrt die Bitte: Mein Herr, mehre mir mein Wissen. Wissen '
        'zu suchen ist Pflicht, und gemeint ist zuerst das Wissen, das dein '
        'tägliches Handeln richtig macht — Gebet, Reinheit, Umgang mit '
        'Menschen, Geld.',
    source: 'Quran 20:114; Ibn Majah 224',
    action:
        'Lerne heute eine konkrete Sache, die du danach anwenden kannst.',
  ),
  DailyAdvice(
    title: 'Sende Segen auf den Propheten ﷺ',
    teaser: 'Einmal von dir — zehnfach zurück.',
    body:
        'Der Quran ruft die Gläubigen auf, den Segensgruß auf den Propheten ﷺ '
        'zu sprechen. Überliefert ist, dass Allah dem, der einmal Salat auf '
        'ihn spricht, zehnfach begegnet. Es ist die kürzeste Handlung mit dem '
        'sichersten Ertrag.',
    source: 'Quran 33:56; Muslim 408',
    action:
        'Sprich heute bewusst zehnmal Allahumma salli ala Muhammad, verteilt '
        'über den Tag.',
  ),
  DailyAdvice(
    title: 'Verzeihe',
    teaser: 'Verzeihung befreit zuerst den, der verzeiht.',
    body:
        'Der Quran rät, das Schlechte mit dem Besseren abzuwehren — dann '
        'werde der, zwischen dem und dir Feindschaft war, wie ein enger '
        'Freund. Verzeihen heißt nicht, Unrecht gutzuheißen; es heißt, das '
        'Nachtragen abzulegen.',
    source: 'Quran 41:34, 3:134',
    action:
        'Lass heute eine alte Kränkung fallen und sprich denjenigen normal '
        'an.',
  ),
  DailyAdvice(
    title: 'Halte dein Versprechen',
    teaser: 'Wer verspricht und bricht, trägt ein Zeichen der Heuchelei.',
    body:
        'Die Überlieferung nennt drei Zeichen: lügen, wenn man spricht; '
        'brechen, wenn man verspricht; untreu sein, wenn man Vertrauen '
        'bekommt. Der Quran beginnt eine ganze Sura mit dem Aufruf, die '
        'Verträge zu erfüllen. Zusagen sind keine Höflichkeitsformeln.',
    source: 'Bukhari 33, Muslim 59; Quran 5:1',
    action:
        'Erfülle heute eine Zusage, die du schon zweimal verschoben hast — '
        'oder sag ehrlich ab.',
  ),
  DailyAdvice(
    title: 'Denk gut über andere',
    teaser: 'Der Quran verbietet Verdacht, Spionieren und Nachrede in einem Vers.',
    body:
        'Meidet den argwöhnischen Verdacht, spioniert einander nicht nach und '
        'redet nicht übereinander — so fasst es der Quran zusammen. Die '
        'meisten Konflikte beginnen mit einer Deutung, die niemand '
        'nachgeprüft hat.',
    source: 'Quran 49:12',
    action:
        'Such heute für ein Verhalten, das dich gestört hat, eine harmlose '
        'Erklärung.',
  ),
  DailyAdvice(
    title: 'Steh in der Nacht auf',
    teaser: 'Das letzte Drittel der Nacht ist die offenste Zeit für Dua.',
    body:
        'Überliefert ist, dass Allah im letzten Drittel der Nacht ruft, wer '
        'Ihn anruft, damit Er erhöre. Der Quran nennt die Nachtstunde die '
        'wirksamere und deutlichere. Zwei kurze Rakat vor dem Fajr genügen '
        'für den Anfang.',
    source: 'Bukhari 1145, Muslim 758; Quran 73:6',
    action:
        'Stell den Wecker heute Nacht zwanzig Minuten vor Fajr und bete zwei '
        'Rakat.',
  ),
  DailyAdvice(
    title: 'Mache Dua',
    teaser: 'Dua ist nicht Beiwerk zum Gottesdienst — sie ist er.',
    body:
        'Ruft Mich an, Ich erhöre euch, heißt es im Quran. Überliefert ist, '
        'dass die Dua der Gottesdienst selbst ist. Sie darf konkret sein, in '
        'deiner Sprache, mitten im Alltag — für dich und für andere, ohne '
        'dass diese davon wissen.',
    source: 'Quran 40:60; Tirmidhi 3372',
    action:
        'Mach heute eine Dua für jemand anderen, ohne es ihm zu sagen.',
  ),
  DailyAdvice(
    title: 'Verzweifle nicht',
    teaser: 'Kein Zustand ist zu spät für Umkehr.',
    body:
        'Der Quran spricht die an, die maßlos gegen sich selbst waren, und '
        'verbietet ihnen die Verzweiflung an Allahs Barmherzigkeit. Alle '
        'Kinder Adams fehlen, heißt es weiter; die besten unter den '
        'Fehlenden sind die, die umkehren.',
    source: 'Quran 39:53; Tirmidhi 2499',
    action:
        'Nimm heute eine Sache, bei der du aufgegeben hast, und fang klein '
        'wieder an.',
  ),
  DailyAdvice(
    title: 'Verbreite den Salam',
    teaser: 'Der kürzeste Weg zu Zuneigung untereinander.',
    body:
        'Überliefert ist: Ihr kommt nicht ins Paradies, bis ihr glaubt, und '
        'ihr glaubt nicht, bis ihr einander liebt — und der Weg dahin ist, '
        'den Salam untereinander zu verbreiten, auch bei denen, die du nicht '
        'kennst.',
    source: 'Muslim 54',
    action:
        'Grüße heute zuerst — auch dort, wo du sonst wartest, ob gegrüßt '
        'wird.',
  ),
  DailyAdvice(
    title: 'Gönne anderen',
    teaser: 'Glaube ist erst vollständig, wenn du für andern willst, was du für dich willst.',
    body:
        'Keiner von euch glaubt, bis er für seinen Bruder liebt, was er für '
        'sich selbst liebt — so die Überlieferung. Das ist der Prüfstein '
        'gegen Neid: nicht das Gefühl unterdrücken, sondern dem anderen '
        'aktiv Gutes wünschen.',
    source: 'Bukhari 13, Muslim 45',
    action:
        'Mach heute jemandem, den du beneidest, ein ehrliches Kompliment '
        'oder eine Dua.',
  ),
  DailyAdvice(
    title: 'Gedenke des Endes',
    teaser: 'Der Gedanke an den Tod ordnet den Rest.',
    body:
        'Überliefert ist der Rat, oft an den Zerstörer der Genüsse zu denken. '
        'Nicht, um Angst zu machen, sondern um Maßstäbe zu korrigieren: was '
        'heute wichtig erscheint, sieht von dort aus oft sehr klein aus.',
    source: 'Tirmidhi 2307',
    action:
        'Frag dich heute bei einer Entscheidung, ob sie in einem Jahr noch '
        'zählt.',
  ),
  DailyAdvice(
    title: 'Trage keine zu schwere Last',
    teaser: 'Allah legt keiner Seele mehr auf, als sie tragen kann.',
    body:
        'Der Quran schließt die längste Sura mit genau diesem Satz — und '
        'direkt danach folgt die Erleichterung nach der Erschwernis. Wer '
        'überfordert ist, hat sich meistens selbst mehr aufgeladen, als '
        'verlangt war.',
    source: 'Quran 2:286, 94:5-6',
    action:
        'Streiche heute einen Punkt von deiner Liste, den niemand von dir '
        'verlangt hat.',
  ),
];
