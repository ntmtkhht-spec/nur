# Design QA: kontinuierlicher Quran-Lesebereich

- Source visual truth: `C:\Users\ntmtk\Desktop\Computer\nur\artifacts\design-qa\quran-reading-reference.png`
- Implementation screenshot: `C:\Users\ntmtk\Desktop\Computer\nur\artifacts\design-qa\quran-reading-implementation.png`
- Combined comparison: `C:\Users\ntmtk\Desktop\Computer\nur\artifacts\design-qa\quran-reading-comparison.png`
- State: Al-Faatiha geöffnet, erster Vers sichtbar, Transliteration und deutsche Übersetzung aktiv; Kopfzeile zeigt nur den lateinischen Surennamen
- Device viewport: Android emulator, 1080 × 2400 px at 420 dpi (approximately 411 × 914 Flutter logical pixels)
- Source pixels: 599 × 393 px; source density unknown
- Implementation pixels: 1080 × 2400 px
- Density normalization: the implementation's 1080 × 708 px reading-region crop was downsampled to 599 × 393 px for the combined comparison. The source was kept at native size.

## Full-view comparison evidence

The full implementation capture shows several consecutive ayat on one continuous `AppColors.background` surface. Rounded cards, shadows, per-ayah white fills, outer margins, and selection borders are absent. Consecutive ayat are separated only by a low-contrast one-pixel divider. The reader app bar now shows only `Al-Faatihah`; the Arabic surah name is not duplicated in the header.

## Focused region comparison evidence

The combined comparison places the reference and the normalized implementation side by side. Both use the same content hierarchy: Arabic verse with an inline ornamental ayah number, then centered transliteration, then centered translation. A separate focused crop was not needed because the combined image is already a close crop of the complete changed component and all relevant typography is readable.

## Required fidelity surfaces

- Fonts and typography: the hierarchy and alignment match the reference principle. The app intentionally retains its existing Arabic and Latin typography, as requested, rather than copying the screenshot's fonts or colors.
- Spacing and layout rhythm: one continuous surface, generous vertical reading space, inline verse marker, and no card radii/elevation. The app bar remains the product's existing navigation instead of copying the reference's `Aya 1:1` control.
- Colors and visual tokens: the existing cream, dark-green, dark-text, and muted-text tokens are preserved. Screenshot colors were intentionally not copied.
- Image quality and asset fidelity: no new raster imagery is required for this layout change. The existing scalable ayah ornament stays sharp at emulator density.
- Copy and content: live Quran data, transliteration, and German translation are retained; no placeholder or dump data was introduced.

## Findings

No actionable P0, P1, or P2 mismatch remains for the requested change. The intentional differences are the retained app palette, typography, navigation, and audio controls.

## Comparison history

- Pass 1: no P0/P1/P2 issue found. The requested card removal, continuous background, inline ayah marker, text hierarchy, and subtle separation are all visible in the captured implementation. No visual correction iteration was required.

## Interaction and runtime checks

- Opened the Quran tab.
- Opened Al-Faatiha from the surah list.
- Verified the reader header shows the Latin surah name without the Arabic surah name.
- Verified multiple consecutive ayat and the persistent audio controls.
- No Flutter exception was observed during the checked flow.

## Follow-up polish

No blocking polish remains.

final result: passed
