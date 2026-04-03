/// Weather alert.
class WeatherAlert {
  final String id;
  final String type; // frost, drought, flood, heatwave, hail, storm
  final String title;
  final String description;
  final String severity; // info, warning, critical
  final String region;
  final DateTime timestamp;
  final String actionAdvice;

  const WeatherAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.region,
    required this.timestamp,
    required this.actionAdvice,
  });
}

/// A seasonal farming activity in the calendar.
class SeasonalActivity {
  final String id;
  final String crop;
  final String activity; // land_prep, planting, weeding, fertilizing, spraying, harvesting
  final String description;
  final int monthStart; // 1-12
  final int monthEnd;
  final List<String> regions;
  final String priority; // critical, recommended, optional

  const SeasonalActivity({
    required this.id,
    required this.crop,
    required this.activity,
    required this.description,
    required this.monthStart,
    required this.monthEnd,
    required this.regions,
    required this.priority,
  });
}

/// Weekly weather forecast.
class WeatherForecast {
  final DateTime date;
  final String condition; // sunny, partly_cloudy, cloudy, rain, thunderstorm
  final double tempHigh;
  final double tempLow;
  final int rainChance; // percentage
  final double rainfall; // mm
  final int humidity; // percentage
  final String windSpeed;

  const WeatherForecast({
    required this.date,
    required this.condition,
    required this.tempHigh,
    required this.tempLow,
    required this.rainChance,
    required this.rainfall,
    required this.humidity,
    required this.windSpeed,
  });
}
