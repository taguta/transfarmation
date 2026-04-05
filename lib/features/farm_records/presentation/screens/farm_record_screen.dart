import 'dart:convert';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/farm.dart';
import '../providers/farm_record_providers.dart';

class FarmRecordScreen extends ConsumerStatefulWidget {
  const FarmRecordScreen({super.key});

  @override
  ConsumerState<FarmRecordScreen> createState() => _FarmRecordScreenState();
}

class _FarmRecordScreenState extends ConsumerState<FarmRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmListProvider);
    final farms = farmsAsync.value ?? [];
    final selectedIndex = ref.watch(selectedFarmIndexProvider);
    final farm = farms.isNotEmpty ? farms[selectedIndex] : null;
    final summary = ref.watch(farmSummaryProvider);

    return Scaffold(
      body: SafeArea(
        child: farm == null
            ? _EmptyState()
            : NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Farm Records', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Track fields, livestock & expenses',
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xxl),

                          // Farm info card
                          _FarmInfoCard(farm: farm),
                          const SizedBox(height: AppSpacing.lg),

                          // Summary stat row
                          _SummaryRow(summary: summary),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.forestGreen,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.forestGreen,
                        tabs: const [
                          Tab(text: 'Fields'),
                          Tab(text: 'Livestock'),
                          Tab(text: 'Expenses'),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _FieldsTab(fields: farm.fields),
                    _LivestockTab(records: farm.livestockRecords),
                    _ExpensesTab(fields: farm.fields),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.mic, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Listening... "Applied 50 kg basal fertilizer..."\nAI mapping to Form Data...')),
                ],
              ),
              backgroundColor: AppColors.forestGreen,
              duration: Duration(seconds: 4),
            ),
          );
        },
        backgroundColor: AppColors.forestGreen,
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: const Text('Log with Voice', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// --- Farm info card ---
class _FarmInfoCard extends StatelessWidget {
  final Farm farm;
  const _FarmInfoCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.forestGreen, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.landscape_rounded, color: Colors.white, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(farm.name, style: AppTextStyles.h2.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(farm.address, style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _FarmChip(icon: Icons.map_rounded, label: '${farm.totalHectares} ha'),
              const SizedBox(width: AppSpacing.sm),
              _FarmChip(icon: Icons.terrain_rounded, label: farm.region),
              const SizedBox(width: AppSpacing.sm),
              _FarmChip(icon: Icons.water_drop_rounded, label: farm.waterSource),
            ],
          ),
          if (farm.latitude != null && farm.longitude != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, color: Colors.white60, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${farm.latitude!.toStringAsFixed(4)}, ${farm.longitude!.toStringAsFixed(4)}',
                  style: AppTextStyles.bodySm.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FarmChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FarmChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

// --- Summary row ---
class _SummaryRow extends StatelessWidget {
  final Map<String, dynamic> summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox();
    return Row(
      children: [
        _StatCard(icon: Icons.grid_view_rounded, label: 'Fields', value: '${summary['fieldCount']}', color: AppColors.forestGreen),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(icon: Icons.grass_rounded, label: 'Planted', value: '${summary['plantedHa']} ha', color: AppColors.harvestGold),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(icon: Icons.pets_rounded, label: 'Livestock', value: '${summary['totalLivestock']}', color: AppColors.earthBrown),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(icon: Icons.attach_money_rounded, label: 'Expenses', value: '\$${summary['totalExpenses']?.toStringAsFixed(0)}', color: Colors.redAccent),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.h4.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// --- Fields tab ---
class _FieldsTab extends StatefulWidget {
  final List<FarmField> fields;
  const _FieldsTab({required this.fields});

  @override
  State<_FieldsTab> createState() => _FieldsTabState();
}

class _FieldsTabState extends State<_FieldsTab> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Field Layout', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(Icons.map_rounded), label: Text('GIS Map')),
                  ButtonSegment(value: false, icon: Icon(Icons.list_rounded), label: Text('List')),
                ],
                selected: {_showMap},
                onSelectionChanged: (val) => setState(() => _showMap = val.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showMap
              ? InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _GisFarmPainter(fields: widget.fields),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: widget.fields.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _FieldCard(field: widget.fields[index]),
                ),
        ),
      ],
    );
  }
}

class _GisFarmPainter extends CustomPainter {
  final List<FarmField> fields;
  _GisFarmPainter({required this.fields});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F8E9)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()..color = Colors.green.withValues(alpha: 0.1)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    for (double i = 0; i < size.height; i += 40) canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final path = Path();
      
      // Generate deterministic polygons based on index for the mockup
      final w = size.width / 2.5;
      final h = size.height / 2.5;
      final offsetX = (i % 2) * (w + 20) + 20;
      final offsetY = (i ~/ 2) * (h + 20) + 20;

      path.moveTo(offsetX, offsetY);
      path.lineTo(offsetX + w, offsetY + (i % 2 == 0 ? 10 : -10));
      path.lineTo(offsetX + w - 20, offsetY + h);
      path.lineTo(offsetX + 10, offsetY + h + 10);
      path.close();

      Color fillColor;
      switch (field.status) {
        case 'growing': fillColor = AppColors.forestGreen; break;
        case 'planted': fillColor = AppColors.harvestGold; break;
        case 'harvested': fillColor = Colors.blue; break;
        default: fillColor = AppColors.textSecondary;
      }

      canvas.drawPath(path, Paint()..color = fillColor.withValues(alpha: 0.6)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.stroke..strokeWidth = 3);

      textPainter.text = TextSpan(
        text: '${field.name}\n${field.currentCrop}\n${field.hectares} ha',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offsetX + w / 4, offsetY + h / 3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FieldCard extends StatelessWidget {
  final FarmField field;
  const _FieldCard({required this.field});

  Color _statusColor(String status) {
    switch (status) {
      case 'growing':
        return AppColors.forestGreen;
      case 'planted':
        return AppColors.harvestGold;
      case 'harvested':
        return Colors.blue;
      case 'fallow':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(field.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(field.name, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  field.status.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(field.currentCrop, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _FieldDetail(icon: Icons.square_foot_rounded, label: '${field.hectares} ha'),
              const SizedBox(width: AppSpacing.lg),
              _FieldDetail(icon: Icons.calendar_today_rounded, label: field.season),
              _FieldDetail(icon: Icons.calendar_today_rounded, label: field.season),
              if (field.yieldTonnes != null) ...[
                const SizedBox(width: AppSpacing.lg),
                _FieldDetail(icon: Icons.inventory_2_rounded, label: '${field.yieldTonnes} t'),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final payloadRaw = '${field.id}|${field.currentCrop}|${DateTime.now().toIso8601String()}|${field.yieldTonnes}';
                final hash = sha256.convert(utf8.encode(payloadRaw)).toString();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Traceability Payload Generated:\n${hash.substring(0, 16)}...'),
                    backgroundColor: AppColors.forestGreen,
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Export Traceability Payload'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                side: const BorderSide(color: AppColors.forestGreen),
              ),
            ),
          ),
          if (field.expenses.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
                Text(
                  '\$${field.totalExpenses.toStringAsFixed(0)}',
                  style: AppTextStyles.h4.copyWith(color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '\$${field.costPerHectare.toStringAsFixed(0)}/ha',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FieldDetail({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// --- Livestock tab ---
class _LivestockTab extends StatelessWidget {
  final List<LivestockRecord> records;
  const _LivestockTab({required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final rec = records[index];
        return _LivestockCard(record: rec);
      },
    );
  }
}

class _LivestockCard extends StatelessWidget {
  final LivestockRecord record;
  const _LivestockCard({required this.record});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'cattle':
        return Icons.pets_rounded;
      case 'poultry':
        return Icons.egg_rounded;
      case 'goat':
        return Icons.pets_rounded;
      case 'pig':
        return Icons.pets_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.earthBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_typeIcon(record.type), size: 20, color: AppColors.earthBrown),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name ?? record.tagNumber ?? '${record.breed} ${record.sex}',
                      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      '${record.type.toUpperCase()} • ${record.breed}',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (record.weight != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.harvestGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${record.weight!.toStringAsFixed(0)} kg',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.harvestGold, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          if (record.vetEvents.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text('Recent Vet Events', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            ...record.vetEvents.take(2).map((v) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    v.type == 'vaccination' ? Icons.vaccines_rounded : Icons.medical_services_rounded,
                    size: 14, color: AppColors.forestGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(v.description, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
                  ),
                  Text(
                    DateFormat('dd MMM').format(v.date),
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

// --- Expenses tab ---
class _ExpensesTab extends StatelessWidget {
  final List<FarmField> fields;
  const _ExpensesTab({required this.fields});

  @override
  Widget build(BuildContext context) {
    // Gather all expenses from all fields
    final allExpenses = <MapEntry<String, FieldExpense>>[];
    for (final f in fields) {
      for (final e in f.expenses) {
        allExpenses.add(MapEntry(f.name, e));
      }
    }
    allExpenses.sort((a, b) => b.value.date.compareTo(a.value.date));

    // Category totals
    final catTotals = <String, double>{};
    for (final e in allExpenses) {
      catTotals[e.value.category] = (catTotals[e.value.category] ?? 0) + e.value.amount;
    }
    final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Category breakdown
        Text('Expense Breakdown', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.md),
        ...sortedCats.map((cat) {
          final total = allExpenses.fold<double>(0, (s, e) => s + e.value.amount);
          final pct = total > 0 ? cat.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    cat.key[0].toUpperCase() + cat.key.substring(1),
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.borderLight,
                      color: _categoryColor(cat.key),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 60,
                  child: Text(
                    '\$${cat.value.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppSpacing.xxl),

        // Recent transactions
        Text('Recent Transactions', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.md),
        ...allExpenses.take(10).map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _categoryColor(entry.value.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(_categoryIcon(entry.value.category), size: 18, color: _categoryColor(entry.value.category)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.value.description, style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
                      Text(entry.key, style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-\$${entry.value.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.labelMd.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      DateFormat('dd MMM').format(entry.value.date),
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'seed': return AppColors.forestGreen;
      case 'fertilizer': return AppColors.harvestGold;
      case 'chemicals': return Colors.orange;
      case 'labour': return Colors.blue;
      case 'equipment': return Colors.purple;
      case 'transport': return AppColors.earthBrown;
      default: return AppColors.textSecondary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'seed': return Icons.grass_rounded;
      case 'fertilizer': return Icons.science_rounded;
      case 'chemicals': return Icons.bug_report_rounded;
      case 'labour': return Icons.people_rounded;
      case 'equipment': return Icons.build_rounded;
      case 'transport': return Icons.local_shipping_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }
}

// --- Tab bar delegate ---
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

// --- Empty state ---
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.landscape_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.lg),
            Text('No Farm Records', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first farm to start tracking fields, livestock and expenses.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Farm initiated. Data will be saved locally first.')),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Farm'),
            ),
          ],
        ),
      ),
    );
  }
}
