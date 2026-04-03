import '../entities/crop.dart';
import '../entities/livestock.dart';
import '../entities/pest_disease.dart';

abstract class KnowledgeRepository {
  Future<List<Crop>> getAllCrops();
  Future<List<Crop>> getCropsByCategory(String category);
  Future<Crop?> getCropById(String id);
  Future<List<Crop>> searchCrops(String query);

  Future<List<Livestock>> getAllLivestock();
  Future<List<Livestock>> getLivestockByCategory(String category);
  Future<Livestock?> getLivestockById(String id);
  Future<List<Livestock>> searchLivestock(String query);

  Future<List<PestDisease>> getAllPestsDiseases();
  Future<List<PestDisease>> getPestDiseasesByType(String type);
  Future<List<PestDisease>> searchPestsDiseases(String query);
}
