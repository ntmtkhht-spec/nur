import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the tab shown by the main shell's bottom navigation.
///
/// Lives in a provider rather than in the shell's own state so widgets nested
/// inside a tab (for example the home screen's prayer progress card) can send
/// the user to another tab without the bottom bar disappearing, which is what
/// happens when such a screen is pushed onto the navigator instead.
class MainTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final mainTabIndexProvider =
    NotifierProvider<MainTabIndexNotifier, int>(MainTabIndexNotifier.new);

/// Tab index of the prayers screen inside the main shell.
const int prayersTabIndex = 1;
