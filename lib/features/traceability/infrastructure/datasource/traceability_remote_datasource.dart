import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audit_log.dart';

abstract class TraceabilityRemoteDataSource {
  Future<List<AuditLog>> getLogs(String farmId);
}

class TraceabilityRemoteDataSourceImpl implements TraceabilityRemoteDataSource {
  final FirebaseFirestore firestore;

  TraceabilityRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<AuditLog>> getLogs(String farmId) async {
    final query = await firestore
        .collection('traceability_logs')
        .where('farmId', isEqualTo: farmId)
        .orderBy('timestamp', descending: true)
        .get();
        
    return query.docs.map((doc) => AuditLog(id: doc.id)).toList();
  }
}
