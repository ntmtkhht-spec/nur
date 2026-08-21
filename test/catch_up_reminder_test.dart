import 'package:flutter_test/flutter_test.dart';
import 'package:munir/core/services/notification_service.dart';

void main() {
  group('notificationId', () {
    test('is stable for the same day and prayer', () {
      final day = DateTime(2026, 8, 21, 13, 5);

      expect(
        NotificationService.notificationId(day, 'Dhuhr', catchUp: true),
        NotificationService.notificationId(
          DateTime(2026, 8, 21, 23, 59),
          'Dhuhr',
          catchUp: true,
        ),
      );
    });

    test('separates the reminder from the prayer time itself', () {
      final day = DateTime(2026, 8, 21);

      expect(
        NotificationService.notificationId(day, 'Dhuhr', catchUp: true),
        isNot(
          NotificationService.notificationId(day, 'Dhuhr', catchUp: false),
        ),
      );
    });

    test('separates prayers within a day', () {
      final day = DateTime(2026, 8, 21);
      final ids = {
        for (final prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'])
          NotificationService.notificationId(day, prayer, catchUp: false),
      };

      expect(ids.length, 5);
    });

    test('separates days', () {
      expect(
        NotificationService.notificationId(
          DateTime(2026, 8, 21),
          'Asr',
          catchUp: false,
        ),
        isNot(
          NotificationService.notificationId(
            DateTime(2026, 8, 22),
            'Asr',
            catchUp: false,
          ),
        ),
      );
    });

    test('stays inside the 32-bit range Android allows', () {
      // Ten years out, still a valid notification id.
      final id = NotificationService.notificationId(
        DateTime(2036, 12, 31),
        'Isha',
        catchUp: true,
      );

      expect(id, greaterThan(0));
      expect(id, lessThan(2147483647));
    });

    test('does not collide across days and prayers', () {
      final ids = <int>{};
      for (var day = 0; day < 400; day++) {
        for (final prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
          final date = DateTime(2026, 1, 1 + day);
          ids.add(
            NotificationService.notificationId(date, prayer, catchUp: false),
          );
          ids.add(
            NotificationService.notificationId(date, prayer, catchUp: true),
          );
        }
      }

      expect(ids.length, 400 * 5 * 2);
    });
  });

  group('lead time', () {
    test('is the half hour the reminder was specified with', () {
      expect(NotificationService.catchUpLeadTime, const Duration(minutes: 30));
    });
  });
}
