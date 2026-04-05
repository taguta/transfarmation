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
    return local.getAlerts(region);
  }

  @override
  Future<List<WeatherForecast>> getForecast(String region) async {
    try {
      return await remote.fetchForecast(region);
    } catch (_) {
      return [];
    }
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
