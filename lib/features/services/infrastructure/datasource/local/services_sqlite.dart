import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/service_partner.dart';

class ServicesLocalDataSource {
  final Database db;

  ServicesLocalDataSource(this.db);

  Future<List<ServicePartner>> getServices() async {
    final rows = await db.query('service_partners');
    
    if (rows.isEmpty) {
      return [];
    }

    return rows.map((r) => ServicePartner(
      id: r['id'] as String,
      title: r['title'] as String,
      subtitle: (r['subtitle'] as String?) ?? '',
      iconCode: (r['iconCode'] as String?) ?? '',
      colorHex: (r['colorHex'] as String?) ?? '#000000',
      route: (r['route'] as String?) ?? '',
    )).toList();
  }
}
