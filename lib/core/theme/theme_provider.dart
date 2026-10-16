import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier to manage ThemeMode (System, Light, Dark)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme([bool? currentIsDark]) {
    if (currentIsDark != null) {
      state = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      if (state == ThemeMode.dark) {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.dark;
      }
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
