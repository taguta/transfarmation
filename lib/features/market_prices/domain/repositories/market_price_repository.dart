import '../entities/commodity.dart';

abstract class MarketPriceRepository {
  Future<List<Commodity>> getCommodities();
  Future<Commodity?> getCommodity(String id);
  Future<void> cachePrices(List<Commodity> commodities);
}
