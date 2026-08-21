# Quran-Übersetzungsprüfung

Stand: 21.08.2026

Die App lädt den arabischen Originaltext, eine veröffentlichte Übersetzung, die Alafasy-Audioausgabe und die englische Transliteration über die Editions-API von Al Quran Cloud. Die Übersetzung wird abhängig von der App-Sprache über eine feste Editions-ID ausgewählt:

| Sprache | Edition | Quelle/Übersetzer |
| --- | --- | --- |
| Deutsch | `de.bubenheim` | Bubenheim & Elyas |
| English | `en.sahih` | Saheeh International |
| Français | `fr.hamidullah` | Muhammad Hamidullah |
| Türkçe | `tr.diyanet` | Diyanet İşleri Başkanlığı |

Für die arabische App-Sprache wird keine Tafsir-Ausgabe als Übersetzung ausgegeben; dort bleibt das Feld leer und es wird nur der arabische Originaltext angezeigt.

## Vollständige Zuordnungsprüfung

Die fünf Ausgaben `quran-uthmani`, `de.bubenheim`, `en.sahih`, `fr.hamidullah` und `tr.diyanet` wurden für alle 114 Suren und insgesamt 6.236 Ayat geladen. Für jede Ausgabe wurden Anzahl, `numberInSurah` und globale Ayah-Nummer gegen den arabischen Originaltext verglichen:

- `de.bubenheim`: 114 Suren, 6.236 Ayat, 0 Zuordnungsfehler
- `en.sahih`: 114 Suren, 6.236 Ayat, 0 Zuordnungsfehler
- `fr.hamidullah`: 114 Suren, 6.236 Ayat, 0 Zuordnungsfehler
- `tr.diyanet`: 114 Suren, 6.236 Ayat, 0 Zuordnungsfehler

Der Runtime-Loader führt dieselbe Identitätsprüfung pro geöffneter Sure erneut durch und weist unvollständige, doppelte oder verschobene Ayah-Daten zurück. Die App verwendet keine lokal selbst formulierten Quran-Übersetzungen.

## Quellen

- [Al Quran Cloud API-Dokumentation](https://alquran.cloud/api) – Editions- und Multi-Edition-Surah-Endpunkte
- [Quran.com: Bubenheim-&-Nadeem-Übersetzung](https://quran.com/en/nuh/translation/de-bubenheim) – Übersetzerangabe und veröffentlichter deutscher Text
