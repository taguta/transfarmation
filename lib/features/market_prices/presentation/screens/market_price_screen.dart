import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/commodity.dart';
import '../providers/market_price_providers.dart';

class MarketPriceScreen extends ConsumerWidget {
  const MarketPriceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commodities = ref.watch(filteredCommoditiesProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    final categories = [
      (null, 'All'),
      ('grain', 'Grains'),
      ('oilseed', 'Oilseeds'),
      ('cash_crop', 'Cash Crops'),
      ('livestock', 'Livestock'),
      ('vegetable', 'Vegetables'),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Market Prices', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Real-time commodity prices across Zimbabwe',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),

              const SizedBox(height: AppSpacing.lg),

              // Category filter
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.$1 == selectedCat;
                    return GestureDetector(
                      onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat.$1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.forestGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: isSelected ? AppColors.forestGreen : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          cat.$2,
                          style: AppTextStyles.labelSm.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Price cards
              ...commodities.map((c) => _CommodityCard(commodity: c)),

              const SizedBox(height: AppSpacing.lg),

              // Market info
              _MarketInfoCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Commodity card with mini chart ---
class _CommodityCard extends StatelessWidget {
  final Commodity commodity;
  const _CommodityCard({required this.commodity});

  Color _catColor(String cat) {
    switch (cat) {
      case 'grain': return AppColors.harvestGold;
      case 'oilseed': return AppColors.forestGreen;
      case 'cash_crop': return AppColors.earthBrown;
      case 'livestock': return Colors.brown;
      case 'vegetable': return Colors.green;
      case 'fruit': return Colors.orange;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor(commodity.category);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.trending_up_rounded, size: 20, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(commodity.name, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
                    Text(commodity.unit, style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${commodity.currentPrice.toStringAsFixed(commodity.currentPrice < 10 ? 2 : 0)}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        commodity.isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 14,
                        color: commodity.isUp ? AppColors.forestGreen : Colors.redAccent,
                      ),
                      Text(
                        '${commodity.changePercent.abs().toStringAsFixed(1)}%',
                        style: AppTextStyles.labelSm.copyWith(
                          color: commodity.isUp ? AppColors.forestGreen : Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Mini trend chart
          if (commodity.history.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 48,
              child: CustomPaint(
                size: const Size(double.infinity, 48),
                painter: _MiniChartPainter(
                  points: commodity.history.map((p) => p.price).toList(),
                  color: commodity.isUp ? AppColors.forestGreen : Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(commodity.history.first.month, style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                Text(commodity.history.last.month, style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ],

          // Market listings
          if (commodity.listings.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text('Where to Sell', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            ...commodity.listings.take(3).map((l) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _listingColor(l.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l.type.toUpperCase(),
                      style: AppTextStyles.labelSm.copyWith(color: _listingColor(l.type), fontSize: 9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.buyerName, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
                  ),
                  Text(
                    '\$${l.priceOffered.toStringAsFixed(l.priceOffered < 10 ? 2 : 0)}',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.forestGreen, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Color _listingColor(String type) {
    switch (type) {
      case 'gmb': return Colors.blue;
      case 'private': return AppColors.forestGreen;
      case 'auction': return AppColors.harvestGold;
      case 'export': return Colors.purple;
      default: return AppColors.textSecondary;
    }
  }
}

// --- Mini sparkline chart painter ---
class _MiniChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _MiniChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    if (range == 0) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

// --- Market info ---
class _MarketInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.harvestGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.harvestGold.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: AppColors.harvestGold),
              const SizedBox(width: AppSpacing.sm),
              Text('Market Tips', style: AppTextStyles.h4.copyWith(color: AppColors.harvestGold)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '• GMB prices are gazetted and guaranteed but payment can take 30+ days\n'
            '• Private buyers often pay premium for quality-graded produce\n'
            '• Auction floors offer best tobacco prices — compare with contract prices\n'
            '• Store grain and sell post-harvest (Apr-Jun) for 15-25% higher prices',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary, height: 1.6),
          ),
        ],
      ),
    );
  }
}
