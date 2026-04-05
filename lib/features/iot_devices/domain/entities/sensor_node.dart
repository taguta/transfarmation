class SensorNode {
  final String id;
  final String name;
  final String type;
  final String status;
  final int battery;
  final String currentValue;
  final String trend;
  final DateTime lastUpdated;

  SensorNode({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.battery,
    required this.currentValue,
    required this.trend,
    required this.lastUpdated,
  });
}
