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

    if (rows.isEmpty) {
      return [
        Product(
          id: 'mp1',
          sellerId: 'farmer_1',
          title: 'Premium Maize Seed (SC 719)',
          description: 'High yielding, drought tolerant variety. 10kg bag.',
          price: 25.0,
          category: 'inputs',
          imageUrls: [],
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Product(
          id: 'mp2',
          sellerId: 'farmer_2',
          title: 'Fresh Grade A Tomatoes',
          description: 'Boxes of fresh tomatoes from the farm.',
          price: 15.0,
          category: 'produce',
          imageUrls: [],
          postedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ].where((p) => category == null || p.category == category).toList();
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
