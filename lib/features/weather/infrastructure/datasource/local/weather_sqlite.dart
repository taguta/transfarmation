import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/weather.dart';

class WeatherLocalDataSource {
  final Database db;
  WeatherLocalDataSource(this.db);

  Future<void> cacheAlerts(List<WeatherAlert> alerts) async {
    final batch = db.batch();
    for (final a in alerts) {
      batch.insert('weather_alerts', {
        'id': a.id,
        'type': a.type,
        'title': a.title,
        'description': a.description,
        'severity': a.severity,
        'region': a.region,
        'timestamp': a.timestamp.toIso8601String(),
        'actionAdvice': a.actionAdvice,
        'isSynced': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<WeatherAlert>> getAlerts(String region) async {
    final rows = await db.query(
      'weather_alerts',
      where: 'region = ?',
      whereArgs: [region],
      orderBy: 'timestamp DESC',
    );
    return rows
        .map(
          (r) => WeatherAlert(
            id: r['id'] as String,
            type: r['type'] as String,
            title: r['title'] as String,
            description: r['description'] as String? ?? '',
            severity: r['severity'] as String? ?? 'info',
            region: r['region'] as String,
            timestamp: DateTime.parse(r['timestamp'] as String),
            actionAdvice: r['actionAdvice'] as String? ?? '',
          ),
        )
        .toList();
  }
}
