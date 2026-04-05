import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/product.dart';

class MarketplaceLocalDataSource {
  final Database db;

  MarketplaceLocalDataSource(this.db);

  Future<void> saveProduct(Product product) async {
    await db.insert(
      'marketplace_products',
      {
        'id': product.id,
        'sellerId': product.sellerId,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'imageUrls': jsonEncode(product.imageUrls),
        'postedAt': product.postedAt.toIso8601String(),
        'isSynced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts({String? category}) async {
    final List<Map<String, dynamic>> rows;
    if (category != null) {
      rows = await db.query('marketplace_products', where: 'category = ?', whereArgs: [category]);
    } else {
      rows = await db.query('marketplace_products');
    }
    
    return rows.map((r) => Product(
      id: r['id'] as String,
      sellerId: r['sellerId'] as String,
      title: r['title'] as String,
      description: r['description'] as String,
      price: (r['price'] as num).toDouble(),
      category: r['category'] as String,
      imageUrls: List<String>.from(jsonDecode(r['imageUrls'] as String)),
      postedAt: DateTime.parse(r['postedAt'] as String),
    )).toList();
  }

  Future<Product?> getProductById(String id) async {
    final rows = await db.query('marketplace_products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    
    final r = rows.first;
    return Product(
      id: r['id'] as String,
      sellerId: r['sellerId'] as String,
      title: r['title'] as String,
      description: r['description'] as String,
      price: (r['price'] as num).toDouble(),
      category: r['category'] as String,
      imageUrls: List<String>.from(jsonDecode(r['imageUrls'] as String)),
      postedAt: DateTime.parse(r['postedAt'] as String),
    );
  }

  Future<void> deleteProduct(String id) async {
    await db.delete('marketplace_products', where: 'id = ?', whereArgs: [id]);
  }
}
