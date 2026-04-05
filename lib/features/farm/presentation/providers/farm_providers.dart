import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/farm.dart';
import '../../../../core/providers/data_providers.dart';

final farmProfileRepositoryProvider = Provider((ref) {
  return ref.watch(databaseProvider);
});

class FarmNotifier extends AsyncNotifier<Farm> {
  @override
  Future<Farm> build() async {
    final db = ref.watch(farmProfileRepositoryProvider);
    final data = await db.query('farm_profile', where: 'id = ?', whereArgs: ['farm-001']);
    
    if (data.isEmpty) {
      // Create initial DB if it doesn't exist
      final initialFarm = Farm(
        id: 'farm-001',
        farmerId: 'farmer-001',
        name: 'My Farm',
        province: 'Mashonaland East',
        sizeHectares: 0,
        farmingMethod: FarmingMethod.rainfed,
        crops: [],
        livestock: [],
      );
      await db.insert('farm_profile', {'id': 'farm-001', 'data': jsonEncode(initialFarm.toJson())});
      return initialFarm;
    }
    
    return Farm.fromJson(jsonDecode(data.first['data'] as String));
  }

  Future<void> addCrop(CropRecord crop) async {
    final db = ref.read(farmProfileRepositoryProvider);
    final currentFarm = state.value!;
    
    final updatedFarm = Farm(
      id: currentFarm.id,
      farmerId: currentFarm.farmerId,
      name: currentFarm.name,
      province: currentFarm.province,
      sizeHectares: currentFarm.sizeHectares,
      farmingMethod: currentFarm.farmingMethod,
      crops: [...currentFarm.crops, crop],
      livestock: currentFarm.livestock,
    );
    
    await db.update(
      'farm_profile',
      {'data': jsonEncode(updatedFarm.toJson())},
      where: 'id = ?',
      whereArgs: ['farm-001'],
    );
    
    ref.invalidateSelf();
  }

  Future<void> updateFarmProfile(double sizeHectares, String farmName) async {
    final db = ref.read(farmProfileRepositoryProvider);
    final currentFarm = state.value!;
    
    final updatedFarm = Farm(
      id: currentFarm.id,
      farmerId: currentFarm.farmerId,
      name: farmName,
      province: currentFarm.province,
      sizeHectares: sizeHectares,
      farmingMethod: currentFarm.farmingMethod,
      crops: currentFarm.crops,
      livestock: currentFarm.livestock,
    );
    
    await db.update(
      'farm_profile',
      {'data': jsonEncode(updatedFarm.toJson())},
      where: 'id = ?',
      whereArgs: ['farm-001'],
    );
    
    ref.invalidateSelf();
  }
}

final farmProvider = AsyncNotifierProvider<FarmNotifier, Farm>(FarmNotifier.new);
