import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/weather.dart';

class WeatherRemoteDataSource {
  final FirebaseFirestore firestore;
  WeatherRemoteDataSource(this.firestore);

  Future<List<WeatherAlert>> fetchAlerts(String region) async {
    final snap = await firestore.collection('weather_alerts')
        .where('region', isEqualTo: region)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return WeatherAlert(
        id: doc.id,
        type: d['type'] as String? ?? '',
        title: d['title'] as String? ?? '',
        description: d['description'] as String? ?? '',
        severity: d['severity'] as String? ?? 'info',
        region: d['region'] as String? ?? '',
        timestamp: d['timestamp'] != null
            ? (d['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        actionAdvice: d['actionAdvice'] as String? ?? '',
      );
    }).toList();
  }

  Future<List<WeatherForecast>> fetchForecast(String region) async {
    final snap = await firestore.collection('weather_forecasts')
        .where('region', isEqualTo: region)
        .orderBy('date')
        .limit(7)
        .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return WeatherForecast(
        date: d['date'] != null
            ? (d['date'] as Timestamp).toDate()
            : DateTime.now(),
        condition: d['condition'] as String? ?? 'sunny',
        tempHigh: (d['tempHigh'] as num?)?.toDouble() ?? 0,
        tempLow: (d['tempLow'] as num?)?.toDouble() ?? 0,
        rainChance: d['rainChance'] as int? ?? 0,
        rainfall: (d['rainfall'] as num?)?.toDouble() ?? 0,
        humidity: d['humidity'] as int? ?? 0,
        windSpeed: d['windSpeed'] as String? ?? '',
      );
    }).toList();
  }
}
