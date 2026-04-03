import '../../domain/entities/commodity.dart';
import '../../domain/repositories/market_price_repository.dart';
import '../datasource/local/commodity_sqlite.dart';
import '../datasource/remote/commodity_firestore.dart';

class MarketPriceRepositoryImpl implements MarketPriceRepository {
  final CommodityLocalDataSource local;
  final CommodityRemoteDataSource remote;

  MarketPriceRepositoryImpl(this.local, this.remote);

  @override
  Future<List<Commodity>> getCommodities() async {
    try {
      final commodities = await remote.fetchCommodities();
      await local.cacheCommodities(commodities);
      return commodities;
    } catch (_) {
      return local.getCommodities();
    }
  }

  @override
  Future<Commodity?> getCommodity(String id) async {
    final all = await getCommodities();
    return all.where((c) => c.id == id).firstOrNull;
  }

  @override
  Future<void> cachePrices(List<Commodity> commodities) {
    return local.cacheCommodities(commodities);
  }
}
