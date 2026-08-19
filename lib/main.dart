import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/providers.dart';
import 'core/services/auth_service.dart';
import 'core/services/sync_service.dart';
import 'firebase_options.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App is light-only: keep the system bars styled for a light background
  // regardless of the OS dark mode setting.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Lets the auth service clear Firestore data before deleting the
        // account without depending on Firestore itself.
        userDocumentDeleterProvider.overrideWith(
          (ref) => (uid) => ref.read(syncServiceProvider).deleteUserData(uid),
        ),
      ],
      child: const MunirApp(),
    ),
  );
}
