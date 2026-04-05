import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../infrastructure/datasource/marketplace_remote_datasource.dart';
import '../../infrastructure/repositories/marketplace_repository_impl.dart';

final marketplaceDataSourceProvider = Provider<MarketplaceRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return MarketplaceRemoteDataSourceImpl(firestore);
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final dataSource = ref.watch(marketplaceDataSourceProvider);
  return MarketplaceRepositoryImpl(dataSource);
});

final marketplaceProductsProvider = FutureProvider.family<List<Product>, String?>((ref, category) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getProducts(category: category);
});
