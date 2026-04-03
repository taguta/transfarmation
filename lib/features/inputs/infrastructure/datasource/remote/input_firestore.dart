import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/farm_input.dart';

class InputRemoteDataSource {
  final FirebaseFirestore firestore;
  InputRemoteDataSource(this.firestore);

  Future<List<FarmInput>> fetchInputs({String? category}) async {
    Query<Map<String, dynamic>> query = firestore.collection('farm_inputs');
    if (category != null) query = query.where('category', isEqualTo: category);

    final snap = await query.get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return FarmInput(
        id: doc.id,
        name: d['name'] as String? ?? '',
        category: d['category'] as String? ?? '',
        supplier: d['supplier'] as String? ?? '',
        description: d['description'] as String? ?? '',
        price: (d['price'] as num?)?.toDouble() ?? 0,
        unit: d['unit'] as String? ?? 'each',
        bulkPrice: (d['bulkPrice'] as num?)?.toDouble(),
        bulkMinQuantity: d['bulkMinQuantity'] as int?,
        isVerified: d['isVerified'] as bool? ?? false,
        inStock: d['inStock'] as bool? ?? true,
      );
    }).toList();
  }

  Future<void> sendSubsidyApplication(SubsidyApplication app) async {
    await firestore.collection('subsidy_applications').doc(app.id).set({
      'programId': app.programId,
      'programName': app.programName,
      'status': app.status,
      'appliedDate': app.appliedDate.toIso8601String(),
      'amountApproved': app.amountApproved,
      'notes': app.notes,
    });
  }
}
