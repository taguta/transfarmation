import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather.dart';

// ─── Weather Alerts ─────────────────────────────────
final weatherAlertsProvider = Provider<List<WeatherAlert>>((ref) {
  return [
    WeatherAlert(
      id: 'wa-001',
      type: 'drought',
      title: 'Dry Spell Warning — Mashonaland',
      description: 'Extended dry spell expected for 2-3 weeks in Mashonaland provinces. Minimal rainfall forecast.',
      severity: 'warning',
      region: 'Mashonaland East',
      timestamp: DateTime(2026, 4, 3),
      actionAdvice: 'Conserve soil moisture with mulching. Delay top dressing if soil is very dry. Irrigate if possible. Consider supplementary feeding for livestock.',
    ),
    WeatherAlert(
      id: 'wa-002',
      type: 'frost',
      title: 'Early Frost Risk — Highveld',
      description: 'Temperatures may drop below 5°C in Highveld areas from mid-April. Frost risk for late crops.',
      severity: 'warning',
      region: 'Harare / Highveld',
      timestamp: DateTime(2026, 4, 2),
      actionAdvice: 'Harvest mature crops immediately. Cover vulnerable vegetables with frost cloth. Move tender nursery plants under cover.',
    ),
    WeatherAlert(
      id: 'wa-003',
      type: 'heatwave',
      title: 'Heatwave — Lowveld',
      description: 'Temperatures exceeding 38°C expected in Lowveld areas for the next 5 days.',
      severity: 'critical',
      region: 'Masvingo / Lowveld',
      timestamp: DateTime(2026, 4, 1),
      actionAdvice: 'Provide extra water for livestock. Provide shade. Irrigate crops in early morning or late evening. Avoid spraying chemicals in extreme heat.',
    ),
  ];
});

// ─── 7-Day Forecast ──────────────────────────────────
final weeklyForecastProvider = Provider<List<WeatherForecast>>((ref) {
  final today = DateTime(2026, 4, 3);
  return [
    WeatherForecast(date: today, condition: 'partly_cloudy', tempHigh: 28, tempLow: 14, rainChance: 10, rainfall: 0, humidity: 45, windSpeed: '12 km/h'),
    WeatherForecast(date: today.add(const Duration(days: 1)), condition: 'sunny', tempHigh: 30, tempLow: 15, rainChance: 5, rainfall: 0, humidity: 40, windSpeed: '10 km/h'),
    WeatherForecast(date: today.add(const Duration(days: 2)), condition: 'sunny', tempHigh: 31, tempLow: 16, rainChance: 5, rainfall: 0, humidity: 38, windSpeed: '8 km/h'),
    WeatherForecast(date: today.add(const Duration(days: 3)), condition: 'partly_cloudy', tempHigh: 29, tempLow: 15, rainChance: 20, rainfall: 0, humidity: 50, windSpeed: '14 km/h'),
    WeatherForecast(date: today.add(const Duration(days: 4)), condition: 'cloudy', tempHigh: 26, tempLow: 13, rainChance: 40, rainfall: 5, humidity: 60, windSpeed: '16 km/h'),
    WeatherForecast(date: today.add(const Duration(days: 5)), condition: 'rain', tempHigh: 23, tempLow: 12, rainChance: 75, rainfall: 18, humidity: 78, windSpeed: '20 km/h'),
    WeatherForecast(date: today.add(const Duration(days: 6)), condition: 'thunderstorm', tempHigh: 24, tempLow: 13, rainChance: 85, rainfall: 25, humidity: 82, windSpeed: '25 km/h'),
  ];
});

// ─── Seasonal Calendar ───────────────────────────────
final seasonalCalendarProvider = Provider<List<SeasonalActivity>>((ref) {
  return const [
    // ─── Maize ───
    SeasonalActivity(id: 'sc-001', crop: 'Maize', activity: 'Land Preparation', description: 'Clear and plough fields. Apply basal lime if soil is acidic.', monthStart: 8, monthEnd: 10, regions: ['II', 'III', 'IV'], priority: 'critical'),
    SeasonalActivity(id: 'sc-002', crop: 'Maize', activity: 'Planting', description: 'Plant with first effective rains (>30mm). Apply Compound D at planting.', monthStart: 10, monthEnd: 12, regions: ['II', 'III', 'IV'], priority: 'critical'),
    SeasonalActivity(id: 'sc-003', crop: 'Maize', activity: 'Top Dressing', description: 'Apply AN at 4-6 weeks after emergence. Split application if possible.', monthStart: 11, monthEnd: 1, regions: ['II', 'III', 'IV'], priority: 'critical'),
    SeasonalActivity(id: 'sc-004', crop: 'Maize', activity: 'Weeding', description: 'First weeding at 2-3 weeks. Second at 5-6 weeks. Keep fields weed-free to knee height.', monthStart: 11, monthEnd: 1, regions: ['II', 'III', 'IV'], priority: 'critical'),
    SeasonalActivity(id: 'sc-005', crop: 'Maize', activity: 'Pest Scouting', description: 'Scout for Fall Armyworm weekly. Check 20 plants per field.', monthStart: 11, monthEnd: 2, regions: ['II', 'III', 'IV'], priority: 'critical'),
    SeasonalActivity(id: 'sc-006', crop: 'Maize', activity: 'Harvesting', description: 'Harvest when grain moisture is below 12.5%. Dry and shell promptly.', monthStart: 4, monthEnd: 6, regions: ['II', 'III', 'IV'], priority: 'critical'),

    // ─── Tobacco ───
    SeasonalActivity(id: 'sc-010', crop: 'Tobacco', activity: 'Seedbed', description: 'Prepare and fumigate seedbeds. Sow seed on sterilized beds.', monthStart: 7, monthEnd: 8, regions: ['I', 'II'], priority: 'critical'),
    SeasonalActivity(id: 'sc-011', crop: 'Tobacco', activity: 'Transplanting', description: 'Transplant seedlings at 8-10cm height. Apply basal fertilizer.', monthStart: 9, monthEnd: 11, regions: ['I', 'II'], priority: 'critical'),
    SeasonalActivity(id: 'sc-012', crop: 'Tobacco', activity: 'Curing & Sale', description: 'Sequential reaping and curing. Prepare bales for sale at auction floors.', monthStart: 1, monthEnd: 5, regions: ['I', 'II'], priority: 'critical'),

    // ─── Soya Beans ───
    SeasonalActivity(id: 'sc-020', crop: 'Soya Beans', activity: 'Planting', description: 'Plant November-mid December. Inoculate seed with Rhizobium. Apply basal fertilizer.', monthStart: 11, monthEnd: 12, regions: ['II', 'III'], priority: 'critical'),
    SeasonalActivity(id: 'sc-021', crop: 'Soya Beans', activity: 'Harvesting', description: 'Harvest when 90% pods are dry. Cut and windrow before combining.', monthStart: 4, monthEnd: 5, regions: ['II', 'III'], priority: 'critical'),

    // ─── Cattle ───
    SeasonalActivity(id: 'sc-030', crop: 'Cattle', activity: 'Vaccination', description: 'Annual anthrax and blackleg vaccination. Brucellosis for heifers 4-8 months.', monthStart: 8, monthEnd: 9, regions: ['I', 'II', 'III', 'IV', 'V'], priority: 'critical'),
    SeasonalActivity(id: 'sc-031', crop: 'Cattle', activity: 'Dipping Intensify', description: 'Increase dipping frequency to every 7-14 days during wet season. Theileriosis peak.', monthStart: 10, monthEnd: 3, regions: ['I', 'II', 'III', 'IV', 'V'], priority: 'critical'),
    SeasonalActivity(id: 'sc-032', crop: 'Cattle', activity: 'Supplementary Feeding', description: 'Dry season feeding: provide hay, crop residues, mineral licks, and protein supplements.', monthStart: 5, monthEnd: 9, regions: ['III', 'IV', 'V'], priority: 'recommended'),

    // ─── Poultry ───
    SeasonalActivity(id: 'sc-040', crop: 'Poultry', activity: 'Newcastle Vaccine', description: 'Administer Lasota vaccine in drinking water. Repeat every 3 months.', monthStart: 1, monthEnd: 12, regions: ['I', 'II', 'III', 'IV', 'V'], priority: 'critical'),
  ];
});

// ─── Current month filter ───────────────────────────
final currentMonthActivitiesProvider = Provider<List<SeasonalActivity>>((ref) {
  final activities = ref.watch(seasonalCalendarProvider);
  final currentMonth = DateTime.now().month;
  return activities.where((a) {
    if (a.monthStart <= a.monthEnd) {
      return currentMonth >= a.monthStart && currentMonth <= a.monthEnd;
    } else {
      return currentMonth >= a.monthStart || currentMonth <= a.monthEnd;
    }
  }).toList();
});
