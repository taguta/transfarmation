import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/weather/domain/entities/weather.dart';
import '../../features/weather/presentation/providers/weather_providers.dart';
import '../providers/data_providers.dart';

/// Turns weather warnings and the farmer's crop calendar into notifications
/// without waiting for the farmer to open those screens.
class ProactiveAlerts {
  /// Weather warnings older than this are history, not news.
  static const weatherFreshness = Duration(days: 7);

  /// Normalises "Soybeans", "soya beans", "Soya Beans" to one key.
  static String cropKey(String name) {
    final n = name.trim().toLowerCase();
    if (n.startsWith('soy')) return 'soya beans';
    if (n == 'tomato') return 'tomatoes';
    return n;
  }

  static List<AppNotification> build({
    required DateTime now,
    required Set<String> grows,
    required List<WeatherAlert> weather,
    required List<SeasonalActivity> calendar,
  }) {
    final out = <AppNotification>[];

    for (final w in weather) {
      final serious = w.severity == 'warning' || w.severity == 'critical';
      if (!serious || now.difference(w.timestamp) > weatherFreshness) continue;
      out.add(AppNotification(
        id: 'wx_${w.id}',
        title: w.title,
        body: w.actionAdvice.isNotEmpty ? w.actionAdvice : w.description,
        type: NotificationType.advisory,
        timestamp: now,
        actionRoute: '/weather',
      ));
    }

    final owned = grows.map(cropKey).toSet();
    final thisMonth = now.month;
    final nextMonth = thisMonth == 12 ? 1 : thisMonth + 1;
    final stamp = '${now.year}${thisMonth.toString().padLeft(2, '0')}';

    for (final a in calendar) {
      if (!owned.contains(cropKey(a.crop))) continue;
      final startsNow = a.monthStart == thisMonth;
      final startsNext = a.monthStart == nextMonth;
      if (!startsNow && !startsNext) continue;
      out.add(AppNotification(
        id: 'stage_${a.id}_$stamp',
        title: startsNow
            ? '${a.crop}: ${a.activity} starts this month'
            : '${a.crop}: ${a.activity} is coming up next month',
        body: a.description,
        type: NotificationType.advisory,
        timestamp: now,
        actionRoute: '/knowledge',
      ));
    }
    return out;
  }
}

/// Crops and livestock the active farmer keeps, from the local farm records.
Future<Set<String>> loadGrows(Database db, String farmerId) async {
  final crops = await db.rawQuery(
    'SELECT DISTINCT f.currentCrop AS name FROM farm_fields f '
    'JOIN farms fm ON fm.id = f.farmId WHERE fm.farmerId = ? AND f.currentCrop IS NOT NULL',
    [farmerId],
  );
  final animals = await db.rawQuery(
    'SELECT DISTINCT l.type AS name FROM livestock_records l '
    'JOIN farms fm ON fm.id = l.farmId WHERE fm.farmerId = ? AND l.type IS NOT NULL',
    [farmerId],
  );
  return {
    for (final r in [...crops, ...animals])
      if ((r['name'] as String?)?.isNotEmpty == true) r['name'] as String,
  };
}

/// Runs the engine and stores any new alerts. Alert ids are deterministic, so
/// an alert is created once and a read alert stays read.
final proactiveAlertsProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final farmerId = ref.watch(activeFarmerIdProvider);
  final weather = await ref.watch(weatherAlertsProvider.future);
  final calendar = ref.watch(seasonalCalendarProvider);
  final grows = await loadGrows(db, farmerId);

  final drafts = ProactiveAlerts.build(
    now: DateTime.now(),
    grows: grows,
    weather: weather,
    calendar: calendar,
  );

  var added = 0;
  for (final n in drafts) {
    final id = await db.insert(
      'notifications',
      n.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    if (id != 0) added++;
  }
  if (added > 0) ref.invalidate(notificationProvider);
  return added;
});
