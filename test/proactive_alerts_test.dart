import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/core/alerts/proactive_alerts.dart';
import 'package:transfarmation/features/weather/domain/entities/weather.dart';

SeasonalActivity act(String id, String crop, int start) => SeasonalActivity(
  id: id,
  crop: crop,
  activity: 'Planting',
  description: 'Plant now',
  monthStart: start,
  monthEnd: start + 1,
  regions: const ['II'],
  priority: 'critical',
);

WeatherAlert wx(String id, String sev, DateTime at) => WeatherAlert(
  id: id,
  type: 'frost',
  title: 'Frost warning',
  description: 'Cold night',
  severity: sev,
  region: 'x',
  timestamp: at,
  actionAdvice: 'Cover seedlings',
);

void main() {
  final now = DateTime(2026, 10, 15);

  test('alerts only for crops the farmer grows', () {
    final out = ProactiveAlerts.build(
      now: now,
      grows: {'Maize'},
      weather: const [],
      calendar: [act('a', 'Maize', 10), act('b', 'Tobacco', 10)],
    );
    expect(out.map((n) => n.id), ['stage_a_202610']);
    expect(out.single.title, contains('starts this month'));
  });

  test('gives a heads-up the month before an activity starts', () {
    final out = ProactiveAlerts.build(
      now: now,
      grows: {'Maize'},
      weather: const [],
      calendar: [act('a', 'Maize', 11)],
    );
    expect(out.single.title, contains('coming up next month'));
  });

  test('december looks ahead to january', () {
    final out = ProactiveAlerts.build(
      now: DateTime(2026, 12, 5),
      grows: {'Maize'},
      weather: const [],
      calendar: [act('a', 'Maize', 1)],
    );
    expect(out, hasLength(1));
  });

  test('crop names are matched loosely', () {
    final out = ProactiveAlerts.build(
      now: now,
      grows: {'Soybeans'},
      weather: const [],
      calendar: [act('a', 'Soya Beans', 10)],
    );
    expect(out, hasLength(1));
  });

  test('only fresh warning or critical weather alerts notify', () {
    final out = ProactiveAlerts.build(
      now: now,
      grows: const {},
      weather: [
        wx('fresh', 'warning', now.subtract(const Duration(days: 1))),
        wx('info', 'info', now),
        wx('old', 'critical', now.subtract(const Duration(days: 30))),
      ],
      calendar: const [],
    );
    expect(out.map((n) => n.id), ['wx_fresh']);
  });

  test('ids are stable so alerts are not duplicated', () {
    List<String> ids() => ProactiveAlerts.build(
      now: now,
      grows: {'Maize'},
      weather: const [],
      calendar: [act('a', 'Maize', 10)],
    ).map((n) => n.id).toList();
    expect(ids(), ids());
  });
}
