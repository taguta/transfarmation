import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasource/local/weather_sqlite.dart';
import '../datasource/remote/weather_firestore.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherLocalDataSource local;
  final WeatherRemoteDataSource remote;

  WeatherRepositoryImpl(this.local, this.remote);

  @override
  Future<List<WeatherAlert>> getAlerts(String region) async {
    try {
      final alerts = await remote.fetchAlerts(region);
      await local.cacheAlerts(alerts);
      return alerts;
    } catch (_) {
      return local.getAlerts(region);
    }
  }

  @override
  Future<List<WeatherForecast>> getForecast(String region) {
    return remote.fetchForecast(region);
  }

  @override
  Future<List<SeasonalActivity>> getSeasonalCalendar(String region) async {
    // Seasonal calendar is static data — could be bundled or fetched once
    return [];
  }

  @override
  Future<void> cacheAlerts(List<WeatherAlert> alerts) {
    return local.cacheAlerts(alerts);
  }
}
