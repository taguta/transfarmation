import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expert_entity.dart';

abstract class ExpertRemoteDataSource {
  Future<List<ExpertEntity>> getExperts({String? specialization});
  Future<ExpertEntity> getExpertById(String id);
  Future<void> bookConsultation(String expertId, DateTime slot);
}

class ExpertRemoteDataSourceImpl implements ExpertRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpertRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ExpertEntity>> getExperts({String? specialization}) async {
    Query query = firestore.collection('experts');
    
    if (specialization != null && specialization.isNotEmpty) {
      query = query.where('specialization', isEqualTo: specialization);
    }
    
    query = query.where('isAvailable', isEqualTo: true);

    final snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ExpertEntity(
        id: doc.id,
        name: data['name'] as String? ?? 'Unknown Expert',
        specialization: data['specialization'] as String? ?? 'General Agronomy',
        rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
        reviewsCount: data['reviewsCount'] as int? ?? 0,
        consultationFee: (data['consultationFee'] as num?)?.toDouble() ?? 0.0,
        isAvailable: data['isAvailable'] as bool? ?? true,
      );
    }).toList();
  }

  @override
  Future<ExpertEntity> getExpertById(String id) async {
    final doc = await firestore.collection('experts').doc(id).get();
    
    if (!doc.exists) {
      throw Exception("Expert not found");
    }
    
    final data = doc.data() as Map<String, dynamic>;
    return ExpertEntity(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Expert',
      specialization: data['specialization'] as String? ?? 'General Agronomy',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: data['reviewsCount'] as int? ?? 0,
      consultationFee: (data['consultationFee'] as num?)?.toDouble() ?? 0.0,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  @override
  Future<void> bookConsultation(String expertId, DateTime slot) async {
    await firestore.collection('bookings').add({
      'expertId': expertId,
      'slot': slot.toIso8601String(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
