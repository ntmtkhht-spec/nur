/// Renders the published legal pages from the same text the app shows.
///
/// Google Play will not accept a listing without a publicly reachable privacy
/// policy, and it requires the account deletion route to be documented on the
/// open web rather than only inside the app. Both are generated here so the
/// published page and the in-app screens cannot drift apart — the alternative,
/// a hand-maintained copy of the text, is exactly how a privacy policy ends up
/// describing a version of the app that no longer exists.
///
/// Run with: dart run tool/build_legal_site.dart [output-dir]
library;

import 'dart:io';

import 'package:munir/features/legal/legal_documents.dart';
import 'package:munir/features/legal/legal_profile.dart';

void main(List<String> args) {
  final outputDir = Directory(args.isEmpty ? 'site' : args.first);
  outputDir.createSync(recursive: true);

  final pages = <String, String>{
    'index.html': _page(
      title: 'Datenschutzerklärung',
      document: LegalDocument.privacy,
      active: 'index.html',
    ),
    'impressum.html': _page(
      title: 'Impressum',
      document: LegalDocument.imprint,
      active: 'impressum.html',
    ),
    'konto-loeschen.html': _page(
      title: 'Konto löschen',
      document: LegalDocument.accountDeletion,
      active: 'konto-loeschen.html',
    ),
  };

  pages.forEach((name, html) {
    File('${outputDir.path}/$name').writeAsStringSync(html);
    stdout.writeln('wrote ${outputDir.path}/$name');
  });
}

const _navigation = [
  ('index.html', 'Datenschutz'),
  ('impressum.html', 'Impressum'),
  ('konto-loeschen.html', 'Konto löschen'),
];

String _page({
  required String title,
  required LegalDocument document,
  required String active,
}) {
  final nav = _navigation
      .map(
        (item) => item.$1 == active
            ? '<a href="${item.$1}" aria-current="page">${_escape(item.$2)}</a>'
            : '<a href="${item.$1}">${_escape(item.$2)}</a>',
      )
      .join('\n        ');

  final sections = document.sections.map(_section).join('\n');

  // The deletion page carries the anchor Play's console links to, so an old
  // "#konto-loeschen" link keeps resolving after the page was split out.
  final anchor = active == 'konto-loeschen.html'
      ? ' id="konto-loeschen"'
      : '';

  return '''<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_escape(title)} — ${_escape(LegalProfile.appName)}</title>
<meta name="description" content="${_escape(document.intro)}">
<style>
:root {
  color-scheme: light dark;
  --bg: #faf7f0;
  --card: #ffffff;
  --ink: #1c2b23;
  --muted: #5f6f66;
  --accent: #16402d;
  --gold: #b8894a;
  --line: #e6e0d4;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #101713;
    --card: #17211b;
    --ink: #e9efea;
    --muted: #9aa8a0;
    --accent: #7fbf9a;
    --gold: #d0a367;
    --line: #24312a;
  }
}
* { box-sizing: border-box; }
body {
  margin: 0;
  padding: 0 20px 80px;
  background: var(--bg);
  color: var(--ink);
  font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}
.wrap { max-width: 720px; margin: 0 auto; }
header { padding: 40px 0 8px; }
.app { color: var(--accent); font-weight: 800; letter-spacing: .02em; }
h1 { font-size: 1.9rem; line-height: 1.2; margin: 8px 0 4px; }
.stand { color: var(--muted); font-size: .85rem; margin: 0; }
.intro { color: var(--muted); margin: 16px 0 0; }
nav { display: flex; flex-wrap: wrap; gap: 8px; margin: 24px 0 8px; }
nav a {
  padding: 7px 14px;
  border: 1px solid var(--line);
  border-radius: 999px;
  color: var(--muted);
  text-decoration: none;
  font-size: .9rem;
}
nav a[aria-current="page"] {
  background: var(--accent);
  border-color: var(--accent);
  color: var(--bg);
  font-weight: 700;
}
section {
  background: var(--card);
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 20px 22px;
  margin: 16px 0;
}
h2 { font-size: 1.05rem; margin: 0 0 10px; }
p { margin: 0 0 12px; overflow-wrap: anywhere; }
ul { margin: 0; padding-left: 20px; }
li { margin-bottom: 8px; overflow-wrap: anywhere; }
li::marker { color: var(--gold); }
footer { color: var(--muted); font-size: .82rem; margin-top: 32px; }
a { color: var(--accent); }
</style>
</head>
<body>
<div class="wrap">
  <header>
    <div class="app">${_escape(LegalProfile.appName)}</div>
    <h1$anchor>${_escape(document.title)}</h1>
    <p class="stand">Stand: ${_escape(LegalProfile.lastUpdated)}</p>
    <p class="intro">${_escape(document.intro)}</p>
    <nav>
        $nav
    </nav>
  </header>
$sections
  <footer>
    ${_escape(LegalProfile.operatorName)} · ${_escape(LegalProfile.operatorPostalCity)} ·
    <a href="mailto:${_escape(LegalProfile.contactEmail)}">${_escape(LegalProfile.contactEmail)}</a>
  </footer>
</div>
</body>
</html>
''';
}

String _section(LegalSection section) {
  final buffer = StringBuffer()
    ..writeln('  <section>')
    ..writeln('    <h2>${_escape(section.title)}</h2>');

  for (final paragraph in section.paragraphs) {
    buffer.writeln('    <p>${_linkify(paragraph)}</p>');
  }

  if (section.bullets.isNotEmpty) {
    buffer.writeln('    <ul>');
    for (final bullet in section.bullets) {
      buffer.writeln('      <li>${_linkify(bullet)}</li>');
    }
    buffer.writeln('    </ul>');
  }

  buffer.write('  </section>');
  return buffer.toString();
}

/// Escapes the text, then turns bare URLs into links and newlines into breaks.
///
/// The escape has to happen first: doing it afterwards would mangle the markup
/// this adds.
String _linkify(String text) {
  final escaped = _escape(text).replaceAll('\n', '<br>');
  return escaped.replaceAllMapped(
    RegExp(r'https?://[^\s<]+'),
    (match) => '<a href="${match[0]}">${match[0]}</a>',
  );
}

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
