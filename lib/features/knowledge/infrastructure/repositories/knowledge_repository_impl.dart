import '../../domain/entities/crop.dart';
import '../../domain/entities/livestock.dart';
import '../../domain/entities/pest_disease.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../datasource/local/knowledge_local_data.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  @override
  Future<List<Crop>> getAllCrops() async => KnowledgeLocalData.crops;

  @override
  Future<List<Crop>> getCropsByCategory(String category) async =>
      KnowledgeLocalData.crops.where((c) => c.category == category).toList();

  @override
  Future<Crop?> getCropById(String id) async =>
      KnowledgeLocalData.crops.where((c) => c.id == id).firstOrNull;

  @override
  Future<List<Crop>> searchCrops(String query) async {
    final q = query.toLowerCase();
    return KnowledgeLocalData.crops
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Livestock>> getAllLivestock() async =>
      KnowledgeLocalData.livestock;

  @override
  Future<List<Livestock>> getLivestockByCategory(String category) async =>
      KnowledgeLocalData.livestock
          .where((l) => l.category == category)
          .toList();

  @override
  Future<Livestock?> getLivestockById(String id) async =>
      KnowledgeLocalData.livestock.where((l) => l.id == id).firstOrNull;

  @override
  Future<List<Livestock>> searchLivestock(String query) async {
    final q = query.toLowerCase();
    return KnowledgeLocalData.livestock
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.breed.toLowerCase().contains(q) ||
            l.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<PestDisease>> getAllPestsDiseases() async =>
      KnowledgeLocalData.pestsDiseases;

  @override
  Future<List<PestDisease>> getPestDiseasesByType(String type) async =>
      KnowledgeLocalData.pestsDiseases
          .where((p) => p.type == type)
          .toList();

  @override
  Future<List<PestDisease>> searchPestsDiseases(String query) async {
    final q = query.toLowerCase();
    return KnowledgeLocalData.pestsDiseases
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }
}
