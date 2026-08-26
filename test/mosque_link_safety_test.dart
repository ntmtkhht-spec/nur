import 'package:flutter_test/flutter_test.dart';
import 'package:munir/features/mosques/models/mosque.dart';

void main() {
  group('launchableWebsiteUri', () {
    test('passes http and https through unchanged', () {
      expect(
        launchableWebsiteUri(
          'https://moschee.example/gebetszeiten',
        )?.toString(),
        'https://moschee.example/gebetszeiten',
      );
      expect(
        launchableWebsiteUri('http://moschee.example')?.toString(),
        'http://moschee.example',
      );
    });

    test('assumes https for a bare host, the usual way the tag is written', () {
      expect(
        launchableWebsiteUri('moschee.example')?.toString(),
        'https://moschee.example',
      );
      expect(
        launchableWebsiteUri('  moschee.example/x  ')?.toString(),
        'https://moschee.example/x',
      );
    });

    test('rejects every other scheme', () {
      // OSM tags are world-editable, so these are reachable inputs, not
      // hypotheticals. None of them may reach launchUrl.
      for (final tag in [
        'javascript:alert(1)',
        'intent://scan/#Intent;scheme=zxing;end',
        'file:///etc/passwd',
        'tel:+491234567',
        'mailto:someone@example.org',
        'data:text/html,<script>alert(1)</script>',
      ]) {
        expect(launchableWebsiteUri(tag), isNull, reason: tag);
      }
    });

    test('rejects a tag with no host to open', () {
      expect(launchableWebsiteUri('https://'), isNull);
      expect(launchableWebsiteUri('//evil.example'), isNull);
      expect(launchableWebsiteUri('   '), isNull);
      expect(launchableWebsiteUri(null), isNull);
    });
  });

  group('launchablePhoneUri', () {
    test('builds a tel URI from the digits', () {
      expect(
        launchablePhoneUri('+49 30 1234567')?.toString(),
        'tel:+49301234567',
      );
      expect(
        launchablePhoneUri('030 / 123-4567')?.toString(),
        'tel:0301234567',
      );
    });

    test('drops MMI and USSD characters rather than dialling them', () {
      // A dialler string like *#06# in a world-editable tag must not survive
      // into the URI handed to the OS.
      expect(launchablePhoneUri('*#06#'), isNull);
      expect(
        launchablePhoneUri('+49301234567*#06#')?.toString(),
        'tel:+4930123456706',
      );
    });

    test('offers the first number when the tag lists several', () {
      expect(
        launchablePhoneUri('+49301234567;+49309999999')?.toString(),
        'tel:+49301234567',
      );
    });

    test('rejects a tag with too few digits to dial', () {
      expect(launchablePhoneUri('n/a'), isNull);
      expect(launchablePhoneUri('12'), isNull);
      expect(launchablePhoneUri('   '), isNull);
      expect(launchablePhoneUri(null), isNull);
    });
  });
}
