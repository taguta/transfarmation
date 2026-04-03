import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/market_prices/domain/entities/commodity.dart';

void main() {
  group('Commodity entity', () {
    test('calculates changePercent up', () {
      final commodity = Commodity(
        id: '1',
        name: 'White Maize',
        category: 'grain',
        unit: 'per tonne',
        currentPrice: 390,
        previousPrice: 360,
      );

      expect(commodity.changePercent, closeTo(8.33, 0.1));
      expect(commodity.isUp, true);
    });

    test('calculates changePercent down', () {
      final commodity = Commodity(
        id: '2',
        name: 'Soya Beans',
        category: 'oilseed',
        unit: 'per tonne',
        currentPrice: 680,
        previousPrice: 700,
      );

      expect(commodity.changePercent, closeTo(-2.86, 0.1));
      expect(commodity.isUp, false);
    });

    test('changePercent is 0 when previous is 0', () {
      final commodity = Commodity(
        id: '3',
        name: 'Test',
        category: 'grain',
        unit: 'per tonne',
        currentPrice: 100,
        previousPrice: 0,
      );

      expect(commodity.changePercent, 0);
    });
  });

  group('FarmInput entity', () {
    // FarmInput tests are in input entity tests
  });
}
