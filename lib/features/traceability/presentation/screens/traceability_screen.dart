import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

// Dummy Provider for Traceability Batches
final traceabilityBatchesProvider = Provider((ref) {
  return [
    {
      'id': 'BATCH-0984-TOM',
      'crop': 'Roma Tomatoes',
      'harvestDate': DateTime.now().subtract(const Duration(days: 2)),
      'weight': '500 kg',
      'quality': 'Grade A',
      'farmName': 'Mutasa Heritage Farm',
    },
    {
      'id': 'BATCH-1102-MZE',
      'crop': 'White Maize',
      'harvestDate': DateTime.now().subtract(const Duration(days: 15)),
      'weight': '2.5 Tonnes',
      'quality': 'Export',
      'farmName': 'Banda Commercial',
    },
  ];
});

class TraceabilityScreen extends ConsumerStatefulWidget {
  const TraceabilityScreen({super.key});

  @override
  ConsumerState<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends ConsumerState<TraceabilityScreen> {
  Map<String, dynamic>? selectedBatch;

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(traceabilityBatchesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Traceability & QR', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Generate verifiable QR codes for your farm produce',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
                  
              const SizedBox(height: AppSpacing.xxl),

              if (selectedBatch == null) ...[
                Text('Select a Recent Harvest Batch', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.md),
                ...batches.map((batch) => _BatchTile(
                      batch: batch,
                      onTap: () => setState(() => selectedBatch = batch),
                    )),
              ] else ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text('Scan to verify origin', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.lg),
                        QrImageView(
                          data: 'https://transfarmation.app/verify/${selectedBatch!['id']}',
                          version: QrVersions.auto,
                          size: 240.0,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(selectedBatch!['id'] as String, style: AppTextStyles.h3.copyWith(letterSpacing: 2.0)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                Text('Verified Data', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.md),
                _DataRow(label: 'Farm', value: selectedBatch!['farmName'] as String),
                _DataRow(label: 'Produce', value: selectedBatch!['crop'] as String),
                _DataRow(label: 'Harvest Date', value: DateFormat.yMMMd().format(selectedBatch!['harvestDate'] as DateTime)),
                _DataRow(label: 'Total Weight', value: selectedBatch!['weight'] as String),
                _DataRow(label: 'Quality Grade', value: selectedBatch!['quality'] as String),

                const SizedBox(height: AppSpacing.xxl),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share PDF'),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.print_rounded),
                        label: const Text('Print Labels'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Select another batch'),
                    onPressed: () => setState(() => selectedBatch = null),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchTile extends StatelessWidget {
  final Map<String, dynamic> batch;
  final VoidCallback onTap;

  const _BatchTile({required this.batch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch['crop'] as String, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
                    Text('${batch['weight']} • ${DateFormat.yMMMd().format(batch['harvestDate'] as DateTime)}', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
