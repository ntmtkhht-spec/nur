import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/surah/providers/quran_progress_provider.dart';
import '../../features/tasbih/providers/tasbih_provider.dart';
import '../providers/providers.dart';

/// Mirrors the prayer tracker and a few preferences into Firestore so they
/// survive a device change.
///
/// The device stays the source of truth: everything keeps working offline and
/// without an account, and syncing only copies what is already stored
/// locally. Nothing here is required for the app to function.
class SyncService {
  SyncService(this._ref);

  final Ref _ref;

  static const _collection = 'users';

  /// Every call here is awaited by someone who is waiting on a screen, and
  /// none of them fails on its own when there is no connection.
  ///
  /// Firestore keeps a write made offline in a local queue and flushes it
  /// once the connection is back — the right behaviour, and the reason a
  /// timeout here loses nothing. But the future returned by `set` only
  /// completes when the server has acknowledged the write, which offline
  /// never happens. Sign-out awaited exactly that, so signing out with no
  /// connection spun forever instead of reporting that it could not save.
  ///
  /// Twenty seconds: long enough for a slow mobile connection to finish a
  /// document this size, short enough that a stuck screen is a moment rather
  /// than a hang.
  static const _deadline = Duration(seconds: 20);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance.collection(_collection).doc(uid);

  /// Writes the local tracker and preferences to the user's document.
  Future<void> push(String uid) async {
    final tracker = _ref.read(prayerTrackerProvider);
    final prefs = <String, dynamic>{
      'language': _ref.read(appLanguageProvider),
      'name': _ref.read(userNameProvider),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _doc(uid)
        .set({
          'tracker': tracker,
          'preferences': prefs,
          'tasbihLifetime': _ref.read(tasbihProvider).lifetimeCount,
          'quranProgress': _ref.read(quranReadingProgressProvider).toJson(),
        }, SetOptions(merge: true))
        .timeout(_deadline);
  }

  /// Reads the remote document and merges it into local state.
  ///
  /// Merge, not replace: a prayer ticked off on either device should stay
  /// ticked, so remote and local entries are unioned rather than one
  /// overwriting the other.
  ///
  /// Every field is type-checked rather than cast. The security rules bound
  /// what this app may write, not what the document holds — a field written
  /// by an older build, by a future one, or straight from the console can
  /// carry any type at all, and a cast that misses turns a background sync
  /// into a crash. A field that does not look right is skipped; the local
  /// value stands, which is the same outcome as the field being absent.
  Future<void> pull(String uid) async {
    final snapshot = await _doc(uid).get().timeout(_deadline);
    final data = snapshot.data();
    if (data == null) return;

    final remoteTracker = data['tracker'];
    if (remoteTracker is Map) {
      final entries = <String, bool>{
        for (final entry in remoteTracker.entries)
          if (entry.key is String) entry.key as String: entry.value == true,
      };
      // Key validation itself belongs to the notifier, which is the boundary
      // every merge goes through.
      if (entries.isNotEmpty) {
        _ref.read(prayerTrackerProvider.notifier).mergeRemote(entries);
      }
    }

    final remoteLifetime = data['tasbihLifetime'];
    if (remoteLifetime is int) {
      _ref.read(tasbihProvider.notifier).mergeRemoteLifetime(remoteLifetime);
    }

    final remoteQuranProgress = data['quranProgress'];
    if (remoteQuranProgress is Map) {
      await _ref
          .read(quranReadingProgressProvider.notifier)
          .mergeRemote(Map<String, dynamic>.from(remoteQuranProgress));
    }

    final remotePrefs = data['preferences'];
    if (remotePrefs is Map) {
      final name = remotePrefs['name'];
      // Trimming and the length ceiling live in the notifier, for the same
      // reason: settings writes through it too.
      if (name is String && name.trim().isNotEmpty) {
        _ref.read(userNameProvider.notifier).update(name);
      }
    }
  }

  /// Removes everything stored for this user. Called before deleting the
  /// account itself, which both stores require to be possible in-app.
  Future<void> deleteUserData(String uid) async {
    await _doc(uid).delete().timeout(_deadline);
  }
}

final syncServiceProvider = Provider<SyncService>(SyncService.new);
