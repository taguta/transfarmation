import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../infrastructure/datasource/local/marketplace_sqlite.dart';
import '../../infrastructure/repositories/marketplace_repository_impl.dart';

final marketplaceDataSourceProvider = Provider<MarketplaceLocalDataSource>((ref) {
  return MarketplaceLocalDataSource(ref.watch(databaseProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(
    local: ref.watch(marketplaceDataSourceProvider),
    db: ref.watch(databaseProvider),
  );
});

final marketplaceProductsProvider = FutureProvider.family<List<Product>, String?>((ref, category) {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getProducts(category: category);
});
