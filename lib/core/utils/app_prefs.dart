import 'package:hive_flutter/hive_flutter.dart';

/// Small per-device preferences (onboarding state, chosen role).
/// Every access is guarded so a storage failure never blocks the UI.
class AppPrefs {
  static const _boxName = 'app_prefs';

  static Future<Box> _box() => Hive.openBox(_boxName);

  static Future<bool> get onboardingDone async {
    try {
      return (await _box()).get('onboardingDone', defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<String> get language async {
    try {
      return (await _box()).get('language', defaultValue: 'en') as String;
    } catch (_) {
      return 'en';
    }
  }

  static Future<void> setLanguage(String code) async {
    try {
      await (await _box()).put('language', code);
    } catch (_) {}
  }

  static Future<String> get role async {
    try {
      return (await _box()).get('role', defaultValue: 'Farmer') as String;
    } catch (_) {
      return 'Farmer';
    }
  }

  /// All roles this person holds, e.g. a farmer who is also a buyer.
  static Future<List<String>> get roles async {
    try {
      final box = await _box();
      final stored = box.get('roles');
      if (stored is List && stored.isNotEmpty) return stored.cast<String>();
      return [box.get('role', defaultValue: 'Farmer') as String];
    } catch (_) {
      return ['Farmer'];
    }
  }

  /// Whose data this device currently holds, so it can be cleared when a
  /// different person signs in. Null when no one has signed in yet.
  static Future<String?> get dataOwnerUid async {
    try {
      return (await _box()).get('dataOwnerUid') as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setDataOwnerUid(String? uid) async {
    try {
      final box = await _box();
      if (uid == null) {
        await box.delete('dataOwnerUid');
      } else {
        await box.put('dataOwnerUid', uid);
      }
    } catch (_) {}
  }

  static Future<void> setRoles(List<String> roles) async {
    try {
      await (await _box()).put('roles', roles);
    } catch (_) {}
  }

  static Future<void> setRole(String role) async {
    try {
      await (await _box()).put('role', role);
    } catch (_) {}
  }

  static Future<void> completeOnboarding(String role) async {
    try {
      final box = await _box();
      await box.put('onboardingDone', true);
      await box.put('role', role);
    } catch (_) {}
  }
}
