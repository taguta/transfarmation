import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<Product>> getProducts({String? category});
  Future<Product> getProductById(String id);
  Future<void> listProduct(Product product);
  Future<void> deleteProduct(String id);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final FirebaseFirestore firestore;

  MarketplaceRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<Product>> getProducts({String? category}) async {
    Query query = firestore.collection('products');
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    query = query.orderBy('postedAt', descending: true);

    final snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id,
        sellerId: data['sellerId'] as String? ?? 'unknown',
        title: data['title'] as String? ?? 'Untitled',
        description: data['description'] as String? ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        category: data['category'] as String? ?? 'General',
        imageUrls: List<String>.from(data['imageUrls'] ?? []),
        postedAt: DateTime.tryParse(data['postedAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final doc = await firestore.collection('products').doc(id).get();
    if (!doc.exists) throw Exception('Product not found');
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      sellerId: data['sellerId'] as String? ?? 'unknown',
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'General',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      postedAt: DateTime.tryParse(data['postedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<void> listProduct(Product product) async {
    await firestore.collection('products').doc(product.id).set({
      'sellerId': product.sellerId,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'imageUrls': product.imageUrls,
      'postedAt': product.postedAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    await firestore.collection('products').doc(id).delete();
  }
}
