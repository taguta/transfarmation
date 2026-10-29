import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/core/i18n/app_strings.dart';

void main() {
  test('translated keys always exist in English', () {
    for (final l in [AppLanguage.sn, AppLanguage.nd]) {
      for (final k in AppStrings.table(l).keys) {
        expect(AppStrings.en.containsKey(k), isTrue, reason: '$l has unknown key $k');
      }
    }
  });

  test('a missing translation falls back to English, then to the key', () {
    expect(AppStrings.tr(AppLanguage.sn, 'statement.title'), AppStrings.en['statement.title']);
    expect(AppStrings.tr(AppLanguage.en, 'no.such.key'), 'no.such.key');
  });

  test('languages with no reviewed text are not offered', () {
    expect(AppStrings.isAvailable(AppLanguage.en), isTrue);
    expect(AppStrings.isAvailable(AppLanguage.sn), AppStrings.sn.isNotEmpty);
    expect(AppStrings.isAvailable(AppLanguage.nd), AppStrings.nd.isNotEmpty);
  });
}
