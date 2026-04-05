import '../entities/product.dart';

abstract class MarketplaceRepository {
  Future<List<Product>> getProducts({String? category});
  Future<Product> getProductById(String id);
  Future<void> listProduct(Product product);
  Future<void> deleteProduct(String id);
}
