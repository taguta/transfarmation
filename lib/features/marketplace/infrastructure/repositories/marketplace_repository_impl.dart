import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasource/local/marketplace_sqlite.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceLocalDataSource local;
  final Database db;

  MarketplaceRepositoryImpl({required this.local, required this.db});

  @override
  Future<List<Product>> getProducts({String? category}) async {
    return await local.getProducts(category: category);
  }

  @override
  Future<Product> getProductById(String id) async {
    final product = await local.getProductById(id);
    if (product == null) throw Exception('Product not found offline');
    return product;
  }

  @override
  Future<void> listProduct(Product product) async {
    await local.saveProduct(product);
    await db.insert('sync_queue', {
      'id': product.id,
      'type': 'marketplace_product',
      'payload': jsonEncode({
        'id': product.id,
        'sellerId': product.sellerId,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'imageUrls': product.imageUrls,
        'postedAt': product.postedAt.toIso8601String(),
      }),
      'retryCount': 0,
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    await local.deleteProduct(id);
    // Real implementation would add a delete tombstone to sync queue
    await db.insert('sync_queue', {
      'id': 'del_$id',
      'type': 'marketplace_delete',
      'payload': jsonEncode({'id': id}),
      'retryCount': 0,
    });
  }
}
