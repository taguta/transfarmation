import '../entities/weather.dart';

abstract class WeatherRepository {
  Future<List<WeatherAlert>> getAlerts(String region);
  Future<List<WeatherForecast>> getForecast(String region);
  Future<List<SeasonalActivity>> getSeasonalCalendar(String region);
  Future<void> cacheAlerts(List<WeatherAlert> alerts);
}
