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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add functionality via Sync Queue working.')),
          );
        },
        backgroundColor: AppColors.forestGreen,
        child: const Icon(Icons.add, color: Colors.white),
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
class _FieldsTab extends StatelessWidget {
  final List<FarmField> fields;
  const _FieldsTab({required this.fields});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final field = fields[index];
        return _FieldCard(field: field);
      },
    );
  }
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
              if (field.yieldTonnes != null) ...[
                const SizedBox(width: AppSpacing.lg),
                _FieldDetail(icon: Icons.inventory_2_rounded, label: '${field.yieldTonnes} t'),
              ],
            ],
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
