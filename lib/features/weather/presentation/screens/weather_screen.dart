import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/weather.dart';
import '../providers/weather_providers.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(weatherAlertsProvider);
    final forecast = ref.watch(weeklyForecastProvider);
    final activities = ref.watch(currentMonthActivitiesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weather & Calendar', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Forecasts, alerts & farming calendar',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),

              // Alerts
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text('Active Alerts', style: AppTextStyles.h3.copyWith(color: AppColors.error)),
                const SizedBox(height: AppSpacing.md),
                ...alerts.map((a) => _AlertCard(alert: a)),
              ],

              // 7-day forecast
              const SizedBox(height: AppSpacing.xxl),
              Text('7-Day Forecast', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => _ForecastCard(forecast: forecast[i], isToday: i == 0),
                ),
              ),

              // Seasonal calendar
              const SizedBox(height: AppSpacing.xxl),
              Text('This Month\'s Activities', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Based on Zimbabwe agro-ecological calendar',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.md),
              if (activities.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: Text('No critical activities this month',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textTertiary)),
                  ),
                )
              else
                ...activities.map((a) => _ActivityCard(activity: a)),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final WeatherAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.severity) {
      'critical' => AppColors.error,
      'warning' => AppColors.warning,
      _ => AppColors.info,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_weatherIcon(alert.type), size: 20, color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(alert.title,
                      style: AppTextStyles.labelLg.copyWith(color: color)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(alert.severity.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(alert.description, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(alert.actionAdvice,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _weatherIcon(String type) => switch (type) {
    'frost' => Icons.ac_unit_rounded,
    'drought' => Icons.wb_sunny_rounded,
    'flood' => Icons.water_rounded,
    'heatwave' => Icons.thermostat_rounded,
    'hail' => Icons.grain_rounded,
    'storm' => Icons.thunderstorm_rounded,
    _ => Icons.warning_rounded,
  };
}

class _ForecastCard extends StatelessWidget {
  final WeatherForecast forecast;
  final bool isToday;
  const _ForecastCard({required this.forecast, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primarySurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isToday ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday ? 'Today' : DateFormat.E().format(forecast.date),
            style: AppTextStyles.caption.copyWith(
              color: isToday ? AppColors.primary : AppColors.textTertiary,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Icon(_conditionIcon(forecast.condition), size: 28,
              color: isToday ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(height: AppSpacing.xs),
          Text('${forecast.tempHigh.toInt()}°',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
          Text('${forecast.tempLow.toInt()}°',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          if (forecast.rainChance > 20) ...[
            const SizedBox(height: 2),
            Text('${forecast.rainChance}%',
                style: AppTextStyles.caption.copyWith(color: AppColors.info, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  IconData _conditionIcon(String condition) => switch (condition) {
    'sunny' => Icons.wb_sunny_rounded,
    'partly_cloudy' => Icons.wb_cloudy_rounded,
    'cloudy' => Icons.cloud_rounded,
    'rain' => Icons.water_drop_rounded,
    'thunderstorm' => Icons.thunderstorm_rounded,
    _ => Icons.wb_cloudy_rounded,
  };
}

class _ActivityCard extends StatelessWidget {
  final SeasonalActivity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final color = switch (activity.priority) {
      'critical' => AppColors.error,
      'recommended' => AppColors.accent,
      _ => AppColors.info,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4, height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(activity.crop,
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: AppSpacing.sm),
                      Text('•', style: TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(activity.activity,
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(activity.description,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary), maxLines: 2),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(activity.priority.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }
}
