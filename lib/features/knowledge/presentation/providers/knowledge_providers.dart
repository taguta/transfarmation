import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/crop.dart';
import '../../domain/entities/livestock.dart';
import '../../domain/entities/pest_disease.dart';
import '../../infrastructure/repositories/knowledge_repository_impl.dart';

final knowledgeRepoProvider = Provider((ref) => KnowledgeRepositoryImpl());

final cropsProvider = FutureProvider<List<Crop>>((ref) {
  return ref.read(knowledgeRepoProvider).getAllCrops();
});

final livestockProvider = FutureProvider<List<Livestock>>((ref) {
  return ref.read(knowledgeRepoProvider).getAllLivestock();
});

final pestsDiseasesProvider = FutureProvider<List<PestDisease>>((ref) {
  return ref.read(knowledgeRepoProvider).getAllPestsDiseases();
});

final cropSearchProvider =
    FutureProvider.family<List<Crop>, String>((ref, query) {
  if (query.isEmpty) return ref.read(knowledgeRepoProvider).getAllCrops();
  return ref.read(knowledgeRepoProvider).searchCrops(query);
});

final livestockSearchProvider =
    FutureProvider.family<List<Livestock>, String>((ref, query) {
  if (query.isEmpty) return ref.read(knowledgeRepoProvider).getAllLivestock();
  return ref.read(knowledgeRepoProvider).searchLivestock(query);
});

final pestDiseaseSearchProvider =
    FutureProvider.family<List<PestDisease>, String>((ref, query) {
  if (query.isEmpty) return ref.read(knowledgeRepoProvider).getAllPestsDiseases();
  return ref.read(knowledgeRepoProvider).searchPestsDiseases(query);
});
