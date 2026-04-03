/// A commodity with current and historical pricing.
class Commodity {
  final String id;
  final String name;
  final String category; // grain, oilseed, cash_crop, livestock, vegetable, fruit
  final String unit; // per tonne, per kg, per head
  final double currentPrice;
  final double previousPrice;
  final List<PricePoint> history; // last 12 months
  final List<MarketListing> listings;

  const Commodity({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentPrice,
    required this.previousPrice,
    this.history = const [],
    this.listings = const [],
  });

  double get changePercent =>
      previousPrice > 0 ? ((currentPrice - previousPrice) / previousPrice) * 100 : 0;
  bool get isUp => currentPrice >= previousPrice;
}

/// A price data point for charting.
class PricePoint {
  final String month;
  final double price;

  const PricePoint({required this.month, required this.price});
}

/// A market listing (who is buying/selling and at what price).
class MarketListing {
  final String id;
  final String buyerName;
  final String location;
  final double priceOffered;
  final String terms; // cash, 30-day, contract
  final String type; // gmb, private, auction, export

  const MarketListing({
    required this.id,
    required this.buyerName,
    required this.location,
    required this.priceOffered,
    required this.terms,
    required this.type,
  });
}
