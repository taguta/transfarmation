import '../entities/farm.dart';

abstract class FarmRepository {
  Future<void> saveFarm(Farm farm);
  Future<List<Farm>> getFarms(String farmerId);
  Future<void> deleteFarm(String farmId);
  Future<void> saveField(String farmId, FarmField field);
  Future<void> saveLivestock(String farmId, LivestockRecord record);
}
