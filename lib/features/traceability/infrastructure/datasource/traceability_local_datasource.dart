import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/traceability_batch.dart';

abstract class TraceabilityLocalDataSource {
  Future<List<TraceabilityBatch>> getHarvestBatches();
}

class TraceabilityLocalDataSourceImpl implements TraceabilityLocalDataSource {
  final Database db;
  TraceabilityLocalDataSourceImpl(this.db);

  @override
  Future<List<TraceabilityBatch>> getHarvestBatches() async {
    final result = await db.rawQuery('''
      SELECT 
        f.id as fieldId,
        f.currentCrop as crop,
        f.yieldTonnes as weight,
        f.status,
        farm.name as farmName,
        farm.id as farmId
      FROM farm_fields f
      JOIN farms farm ON f.farmId = farm.id
      WHERE f.status = 'harvested' OR f.status = 'harvesting' OR f.currentCrop IS NOT NULL
    ''');

    return result.map((row) => TraceabilityBatch(
      id: 'BATCH-${row['fieldId'].toString().substring(0, min(4, row['fieldId'].toString().length)).toUpperCase()}-${row['crop'].toString().substring(0, min(3, row['crop'].toString().length)).toUpperCase()}',
      crop: row['crop'] as String,
      harvestDate: DateTime.now().subtract(const Duration(days: 2)),
      weight: '${row['weight'] ?? 0} Tonnes',
      quality: 'Grade A',
      farmName: row['farmName'] as String,
    )).toList();
  }
}
