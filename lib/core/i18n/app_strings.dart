import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_prefs.dart';

enum AppLanguage {
  en('English'),
  sn('Shona'),
  nd('Ndebele');

  final String label;
  const AppLanguage(this.label);
}

/// Farmer-facing text by language.
///
/// English is the source. Shona and Ndebele stay empty until a native speaker
/// has written and reviewed them: we do not machine-translate text a farmer
/// relies on for money. A missing key falls back to English, and a language
/// with no entries is not offered in the language picker.
class AppStrings {
  static const en = <String, String>{
    'statement.title': 'My Statement',
    'statement.owe': 'You currently owe',
    'statement.takeHome': 'You would take home',
    'statement.owe.sub': 'after counting what you spent and what you still owe on loans.',
    'statement.takeHome.sub': 'if everything were settled today, after costs and loans.',
    'statement.in': 'Money in (sales and other income)',
    'statement.spent': 'Money spent (inputs, labour, levies)',
    'statement.loans': 'Still owed on loans',
    'statement.where': 'Where the money went',
    'statement.note':
        'This is built from the entries in your Farm Ledger and your loans. '
        'Add every sale and cost so the numbers match your real position.',
    'statement.openLedger': 'Open Farm Ledger',
  };

  /// To be filled in by reviewed native-speaker translations. Same keys as [en].
  static const sn = <String, String>{};
  static const nd = <String, String>{};

  static Map<String, String> table(AppLanguage l) => switch (l) {
    AppLanguage.en => en,
    AppLanguage.sn => sn,
    AppLanguage.nd => nd,
  };

  static bool isAvailable(AppLanguage l) => l == AppLanguage.en || table(l).isNotEmpty;

  static String tr(AppLanguage l, String key) => table(l)[key] ?? en[key] ?? key;
}

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    AppPrefs.language.then((code) {
      final l = AppLanguage.values.where((x) => x.name == code).firstOrNull;
      if (l != null && AppStrings.isAvailable(l) && l != state) state = l;
    });
    return AppLanguage.en;
  }

  Future<void> set(AppLanguage l) async {
    if (!AppStrings.isAvailable(l)) return;
    state = l;
    await AppPrefs.setLanguage(l.name);
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, AppLanguage>(AppLanguageNotifier.new);

/// Translate [key] into the language the farmer chose.
String tr(WidgetRef ref, String key) =>
    AppStrings.tr(ref.watch(appLanguageProvider), key);
