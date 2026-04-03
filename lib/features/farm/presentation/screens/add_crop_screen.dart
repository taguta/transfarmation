import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/farm.dart';
import '../providers/farm_providers.dart';

class AddCropScreen extends ConsumerStatefulWidget {
  const AddCropScreen({super.key});

  @override
  ConsumerState<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends ConsumerState<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCrop = 'Maize';
  double _area = 1;
  double? _expectedYield;
  DateTime _plantedDate = DateTime.now();
  String? _notes;

  static const _crops = [
    'Maize',
    'Soya Beans',
    'Tobacco',
    'Groundnuts',
    'Cotton',
    'Sunflower',
    'Wheat',
    'Sugar Cane',
    'Tomatoes',
    'Onions',
    'Potatoes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Crop Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Crop type
            Text(
              'Crop Type',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              items: _crops
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCrop = v!),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.grass_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Area
            Text(
              'Area (hectares)',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _area,
                    min: 0.5,
                    max: 50,
                    divisions: 99,
                    label: '${_area.toStringAsFixed(1)} ha',
                    onChanged: (v) => setState(() => _area = v),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    _area.toStringAsFixed(1),
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Planted date
            Text(
              'Planted Date',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _plantedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _plantedDate = picked);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                '${_plantedDate.day}/${_plantedDate.month}/${_plantedDate.year}',
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Expected yield
            Text(
              'Expected Yield (tons)',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'e.g., 12.5',
                prefixIcon: Icon(Icons.scale_rounded),
                suffixText: 'tons',
              ),
              onChanged: (v) =>
                  _expectedYield = double.tryParse(v),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Notes
            Text(
              'Notes (optional)',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Fertilizer used, irrigation notes, etc.',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
                alignLabelWithHint: true,
              ),
              onChanged: (v) => _notes = v.isEmpty ? null : v,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Summary card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'This record will be saved locally and synced when online.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Submit
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              ),
              child: const Text('Save Crop Record'),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final crop = CropRecord(
      id: 'crop-${DateTime.now().millisecondsSinceEpoch}',
      cropName: _selectedCrop,
      areHectares: _area,
      status: CropStatus.planted,
      plantedDate: _plantedDate,
      expectedHarvest: _plantedDate.add(const Duration(days: 150)),
      expectedYield: _expectedYield,
      notes: _notes,
    );

    ref.read(farmProvider.notifier).addCrop(crop);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedCrop crop record saved!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    context.pop();
  }
}
