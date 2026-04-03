import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Persisted theme mode provider.
///
/// Stores the user's preference in Hive so it survives app restarts.
/// Defaults to [ThemeMode.light] if nothing is stored.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _boxName = 'settings';
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadFromCache();
    return ThemeMode.light;
  }

  Future<void> _loadFromCache() async {
    try {
      final box = await _openBoxSafe(_boxName);
      if (box != null) {
        final stored = box.get(_key, defaultValue: 'light') as String;
        state = _fromString(stored);
      }
    } catch (e) {
      debugPrint('ThemeModeNotifier: Failed to load theme from cache: $e');
    }
  }

  Future<void> setLight() => _persist(ThemeMode.light);
  Future<void> setDark() => _persist(ThemeMode.dark);
  Future<void> setSystem() => _persist(ThemeMode.system);

  Future<void> toggle() async {
    switch (state) {
      case ThemeMode.system:
        await setLight();
      case ThemeMode.light:
        await setDark();
      case ThemeMode.dark:
        await setSystem();
    }
  }

  Future<void> _persist(ThemeMode mode) async {
    state = mode;
    try {
      final box = await _openBoxSafe(_boxName);
      if (box != null) {
        await box.put(_key, _toString(mode));
      }
    } catch (e) {
      debugPrint('ThemeModeNotifier: Failed to persist theme: $e');
    }
  }

  /// Open a Hive box with lock-file recovery on Windows.
  static Future<Box?> _openBoxSafe(String name) async {
    try {
      return await Hive.openBox(name);
    } on PathAccessException catch (e) {
      debugPrint('Hive lock conflict for "$name": $e — attempting cleanup');
      try {
        final appDir = await getApplicationSupportDirectory();
        final lockFile = File('${appDir.path}/$name.lock');
        if (await lockFile.exists()) {
          await lockFile.delete();
          debugPrint('Deleted stale lock file: ${lockFile.path}');
        }
        return await Hive.openBox(name);
      } catch (retryError) {
        debugPrint('Hive retry also failed for "$name": $retryError');
        return null;
      }
    }
  }

  static String _toString(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  static ThemeMode _fromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}

/// The app-wide theme mode provider.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
