import '../../domain/entities/product.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasource/marketplace_remote_datasource.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remoteDataSource;

  MarketplaceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts({String? category}) {
    return remoteDataSource.getProducts(category: category);
  }

  @override
  Future<Product> getProductById(String id) {
    return remoteDataSource.getProductById(id);
  }

  @override
  Future<void> listProduct(Product product) {
    return remoteDataSource.listProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) {
    return remoteDataSource.deleteProduct(id);
  }
}
