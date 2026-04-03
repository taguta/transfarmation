import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/farming_contract.dart';

class ContractLocalDataSource {
  final Database db;
  ContractLocalDataSource(this.db);

  Future<void> saveContract(FarmingContract contract) async {
    await db.insert('farming_contracts', {
      'id': contract.id,
      'buyerName': contract.buyerName,
      'buyerType': contract.buyerType,
      'commodity': contract.commodity,
      'pricePerUnit': contract.pricePerUnit,
      'unit': contract.unit,
      'minQuantity': contract.minQuantity,
      'season': contract.season,
      'region': contract.region,
      'requirements': jsonEncode(contract.requirements),
      'buyerProvides': jsonEncode(contract.buyerProvides),
      'deadline': contract.deadline.toIso8601String(),
      'status': contract.status,
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FarmingContract>> getContracts() async {
    final rows = await db.query('farming_contracts');
    return rows
        .map(
          (r) => FarmingContract(
            id: r['id'] as String,
            buyerName: r['buyerName'] as String,
            buyerType: r['buyerType'] as String? ?? '',
            commodity: r['commodity'] as String,
            pricePerUnit: (r['pricePerUnit'] as num).toDouble(),
            unit: r['unit'] as String? ?? 'tonne',
            minQuantity: r['minQuantity'] as int? ?? 0,
            season: r['season'] as String? ?? '',
            region: r['region'] as String? ?? '',
            requirements: _decodeList(r['requirements']),
            buyerProvides: _decodeList(r['buyerProvides']),
            deadline: DateTime.parse(r['deadline'] as String),
            status: r['status'] as String? ?? 'open',
          ),
        )
        .toList();
  }

  List<String> _decodeList(Object? value) {
    if (value == null) return [];
    try {
      return List<String>.from(jsonDecode(value as String));
    } catch (_) {
      return [];
    }
  }
}
