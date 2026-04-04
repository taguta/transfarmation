import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';

class SyncQueueItem {
  final String id;
  final String type;
  final int retryCount;
  final DateTime? lastAttemptedAt;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.retryCount,
    this.lastAttemptedAt,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      type: map['type'] as String,
      retryCount: map['retryCount'] as int? ?? 0,
      lastAttemptedAt:
          map['lastAttemptedAt'] != null
              ? DateTime.tryParse(map['lastAttemptedAt'] as String)
              : null,
    );
  }
}

final syncItemsProvider = FutureProvider<List<SyncQueueItem>>((ref) async {
  final db = ref.watch(databaseProvider);
  final List<Map<String, dynamic>> maps = await db.query(
    'sync_queue',
    orderBy: 'retryCount ASC',
  );
  return maps.map((e) => SyncQueueItem.fromMap(e)).toList();
});

final syncIsRunningProvider = StateProvider<bool>((ref) => false);
