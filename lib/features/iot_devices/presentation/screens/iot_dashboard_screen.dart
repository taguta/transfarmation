import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

// Dummy IoT Data
final _dummySensors = [
  {
    'id': 'SN-089A',
    'name': 'Field Alpha - Soil Node',
    'type': 'Soil Moisture',
    'status': 'online',
    'battery': 82,
    'currentValue': '42%',
    'trend': 'decreasing', // 'increasing', 'stable'
    'lastUpdated': DateTime.now().subtract(const Duration(minutes: 5)),
  },
  {
    'id': 'SN-042B',
    'name': 'Greenhouse 1 - Ambient',
    'type': 'Temperature',
    'status': 'online',
    'battery': 45,
    'currentValue': '28.4°C',
    'trend': 'stable',
    'lastUpdated': DateTime.now().subtract(const Duration(minutes: 2)),
  },
  {
    'id': 'SN-099C',
    'name': 'Pump Station - Flow',
    'type': 'Water Flow',
    'status': 'offline',
    'battery': 0,
    'currentValue': '0 L/min',
    'trend': 'stable',
    'lastUpdated': DateTime.now().subtract(const Duration(hours: 14)),
  },
];

class IotDashboardScreen extends StatelessWidget {
  const IotDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scanning for Bluetooth sensors...')),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.bluetooth_searching_rounded),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('IoT & Sensors', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Live telemetry from your smart farm hardware',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                  
              const SizedBox(height: AppSpacing.xxl),

              // KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Active Nodes',
                      value: '2/3',
                      icon: Icons.router_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      title: 'Avg Moisture',
                      value: '42%',
                      icon: Icons.water_drop_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),
              
              Text('Live Moisture Chart (Field Alpha)', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              
              // Fl_Chart Implementation
              Container(
                height: 220,
                padding: const EdgeInsets.only(right: 24, left: 16, top: 24, bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 1: return const Text('6am', style: TextStyle(color: AppColors.textTertiary, fontSize: 10));
                              case 4: return const Text('12pm', style: TextStyle(color: AppColors.textTertiary, fontSize: 10));
                              case 7: return const Text('6pm', style: TextStyle(color: AppColors.textTertiary, fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}%', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 8,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 60), FlSpot(1, 55), FlSpot(2, 50),
                          FlSpot(3, 48), FlSpot(4, 45), FlSpot(5, 42),
                          FlSpot(6, 42), FlSpot(7, 40), FlSpot(8, 42),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paired Devices', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              
              ..._dummySensors.map((sensor) => _SensorTile(sensor: sensor)),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
          Text(title, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final Map<String, dynamic> sensor;

  const _SensorTile({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final isOnline = sensor['status'] == 'online';
    final battery = sensor['battery'] as int;
    
    IconData typeIcon;
    Color typeColor;
    
    switch (sensor['type']) {
      case 'Soil Moisture':
        typeIcon = Icons.water_drop_rounded;
        typeColor = Colors.blue;
        break;
      case 'Temperature':
        typeIcon = Icons.thermostat_rounded;
        typeColor = Colors.orange;
        break;
      default:
        typeIcon = Icons.sensors_rounded;
        typeColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isOnline ? typeColor.withValues(alpha: 0.1) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(typeIcon, color: isOnline ? typeColor : AppColors.textTertiary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(sensor['name'] as String, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(battery > 20 ? Icons.battery_full_rounded : Icons.battery_alert_rounded, 
                           size: 14, color: battery > 20 ? AppColors.textSecondary : AppColors.error),
                      const SizedBox(width: 4),
                      Text('$battery% • Sync: ${DateFormat.jm().format(sensor['lastUpdated'] as DateTime)}', 
                           style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(sensor['currentValue'] as String, style: AppTextStyles.h3.copyWith(color: isOnline ? AppColors.textPrimary : AppColors.textTertiary)),
                if (isOnline)
                  Icon(
                    sensor['trend'] == 'increasing' ? Icons.trending_up_rounded 
                    : (sensor['trend'] == 'decreasing' ? Icons.trending_down_rounded : Icons.trending_flat_rounded),
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
