import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/service_partner.dart';

class ServicesLocalDataSource {
  final Database db;

  ServicesLocalDataSource(this.db);

  Future<List<ServicePartner>> getServices() async {
    final rows = await db.query('service_partners');
    
    if (rows.isEmpty) {
      // Fallback seed services ensuring the screen isn't empty prior to the first hydrateInitialData() downward sync.
      return [
        ServicePartner(id: 's1', title: 'AgriFinance ZW', subtitle: 'Loans & Credit', iconCode: '57408', colorHex: '0xFF2E7D32', route: '/financing'),
        ServicePartner(id: 's2', title: 'Farm Inputs Co', subtitle: 'Seeds & Fertilizers', iconCode: '58152', colorHex: '0xFF1976D2', route: '/inputs'),
        ServicePartner(id: 's3', title: 'Market Link', subtitle: 'Sell Produce', iconCode: '58156', colorHex: '0xFFF57C00', route: '/marketplace'),
        ServicePartner(id: 's4', title: 'AgriExpert', subtitle: 'Advisory Services', iconCode: '58296', colorHex: '0xFF00796B', route: '/expert'),
        ServicePartner(id: 's5', title: 'Weather Alerts', subtitle: 'Local Forecasts', iconCode: '57597', colorHex: '0xFF1E88E5', route: '/weather'),
        ServicePartner(id: 's6', title: 'Vet Services', subtitle: 'Diagnosis', iconCode: '58315', colorHex: '0xFFD84315', route: '/diagnosis'),
      ];
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
