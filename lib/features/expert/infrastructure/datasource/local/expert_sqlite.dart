import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/expert_entity.dart';

class ExpertLocalDataSource {
  final Database db;

  ExpertLocalDataSource(this.db);

  Future<List<ExpertEntity>> getExperts({String? specialization}) async {
    final List<Map<String, dynamic>> rows;
    if (specialization != null && specialization.isNotEmpty) {
      rows = await db.query('experts', where: 'specialization = ? AND isAvailable = 1', whereArgs: [specialization]);
    } else {
      rows = await db.query('experts', where: 'isAvailable = 1');
    }

    if (rows.isEmpty) {
      // Seed initial offline fallback data to avoid empty screens prior to downward sync
      return [
        ExpertEntity(id: 'e1', name: 'Dr. John', specialization: 'Agronomy', rating: 4.8, reviewsCount: 120, consultationFee: 15.0, isAvailable: true),
        ExpertEntity(id: 'e2', name: 'Jane Smith', specialization: 'Veterinary', rating: 4.9, reviewsCount: 95, consultationFee: 20.0, isAvailable: true),
      ].where((e) => specialization == null || specialization.isEmpty || e.specialization == specialization).toList();
    }

    return rows.map((r) => ExpertEntity(
      id: r['id'] as String,
      name: r['name'] as String,
      specialization: r['specialization'] as String,
      rating: (r['rating'] as num).toDouble(),
      reviewsCount: r['reviewsCount'] as int,
      consultationFee: (r['consultationFee'] as num).toDouble(),
      isAvailable: (r['isAvailable'] as int) == 1,
    )).toList();
  }

  Future<ExpertEntity> getExpertById(String id) async {
    final rows = await db.query('experts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) {
      return ExpertEntity(id: id, name: 'Dr. John', specialization: 'Agronomy', rating: 4.8, reviewsCount: 120, consultationFee: 15.0, isAvailable: true);
    }
    
    final r = rows.first;
    return ExpertEntity(
      id: r['id'] as String,
      name: r['name'] as String,
      specialization: r['specialization'] as String,
      rating: (r['rating'] as num).toDouble(),
      reviewsCount: r['reviewsCount'] as int,
      consultationFee: (r['consultationFee'] as num).toDouble(),
      isAvailable: (r['isAvailable'] as int) == 1,
    );
  }

  Future<void> bookConsultation(String expertId, DateTime slot) async {
    final id = 'book_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'id': id,
      'expertId': expertId,
      'slot': slot.toIso8601String(),
      'status': 'pending',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await db.insert('bookings', payload, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('sync_queue', {
      'id': id,
      'type': 'booking',
      'payload': jsonEncode(payload),
      'retryCount': 0,
    });
  }
}
