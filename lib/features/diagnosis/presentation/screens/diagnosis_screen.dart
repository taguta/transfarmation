import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/diagnosis.dart';
import '../providers/diagnosis_providers.dart';

class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(diagnosisHistoryProvider);
    final isLoading = ref.watch(diagnosisLoadingProvider);

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
                  Text('AI Diagnosis', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Photograph a sick crop or animal for instant diagnosis',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),

              const SizedBox(height: AppSpacing.xxl),

              // Capture cards
              Row(
                children: [
                  Expanded(child: _CaptureCard(
                    title: 'Crop',
                    subtitle: 'Scan leaf, stem, or fruit',
                    icon: Icons.grass_rounded,
                    color: AppColors.primary,
                    isLoading: isLoading,
                    onTap: () => _showCapture(context, ref, 'crop'),
                  )),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _CaptureCard(
                    title: 'Livestock',
                    subtitle: 'Scan skin, eyes, or symptoms',
                    icon: Icons.pets_rounded,
                    color: AppColors.secondary,
                    isLoading: isLoading,
                    onTap: () => _showCapture(context, ref, 'livestock'),
                  )),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // How it works
              _HowItWorks(),

              const SizedBox(height: AppSpacing.xxl),

              // History
              Text('Diagnosis History', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              history.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (data) {
                  if (data.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: AppSpacing.md),
                            Text('No diagnoses yet', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: data.map((d) => _DiagnosisHistoryCard(diagnosis: d)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCapture(BuildContext context, WidgetRef ref, String type) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetCtx) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Capture ${type == 'crop' ? 'Crop' : 'Livestock'} Image',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: _CaptureOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(bottomSheetCtx);
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null && context.mounted) {
                        _simulateDiagnosis(ref, type, image.path);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _CaptureOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(bottomSheetCtx);
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null && context.mounted) {
                        _simulateDiagnosis(ref, type, image.path);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateDiagnosis(WidgetRef ref, String type, String imagePath) async {
    ref.read(diagnosisLoadingProvider.notifier).state = true;

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    final result = DiagnosisResult(
      id: 'diag-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      imagePath: imagePath,
      subjectName: type == 'crop' ? 'Tomato' : 'Goat',
      timestamp: DateTime.now(),
      matches: type == 'crop'
          ? const [
              DiagnosisMatch(
                name: 'Tuta absoluta (Leaf Miner)',
                confidence: 0.88,
                description: 'Irregular mines visible in leaf tissue. Typical Tuta absoluta mining pattern.',
                severity: 'critical',
                treatment: 'Apply spinosad or emamectin benzoate. Alternate chemical classes to prevent resistance.',
                prevention: 'Use pheromone traps (5/ha), remove crop residues, avoid planting solanaceae in succession.',
              ),
            ]
          : const [
              DiagnosisMatch(
                name: 'Orf (Sore Mouth)',
                confidence: 0.82,
                description: 'Scabby lesions visible around mouth area. Contagious ecthyma.',
                severity: 'medium',
                treatment: 'Clean lesions with dilute iodine. Apply glycerin. Ensure animal can eat and drink.',
                prevention: 'Vaccination available. Isolate new animals for 2 weeks. Handle with gloves (zoonotic).',
              ),
            ],
    );

    ref.read(diagnosisHistoryProvider.notifier).addResult(result);
    ref.read(diagnosisLoadingProvider.notifier).state = false;
  }
}

class _CaptureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _CaptureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              if (isLoading)
                SizedBox(
                  width: 48, height: 48,
                  child: CircularProgressIndicator(color: color, strokeWidth: 3),
                )
              else
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: color, size: 28),
                ),
              const SizedBox(height: AppSpacing.md),
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.xs),
              Text(title, style: AppTextStyles.labelLg.copyWith(color: color)),
              Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CaptureOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.info),
              const SizedBox(width: AppSpacing.sm),
              Text('How It Works', style: AppTextStyles.labelLg.copyWith(color: AppColors.info)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _step('1', 'Take a clear photo of the affected crop or animal'),
          _step('2', 'AI analyzes the image for diseases, pests, and conditions'),
          _step('3', 'Get instant diagnosis with treatment recommendations'),
        ],
      ),
    );
  }

  Widget _step(String num, String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(num, style: AppTextStyles.caption.copyWith(color: AppColors.info, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary))),
      ],
    ),
  );
}

class _DiagnosisHistoryCard extends StatelessWidget {
  final DiagnosisResult diagnosis;
  const _DiagnosisHistoryCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final topMatch = diagnosis.matches.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  diagnosis.type == 'crop' ? Icons.grass_rounded : Icons.pets_rounded,
                  size: 20,
                  color: diagnosis.type == 'crop' ? AppColors.primary : AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('${diagnosis.subjectName} — ${topMatch.name}',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
                ),
                Text(
                  '${(topMatch.confidence * 100).toInt()}%',
                  style: AppTextStyles.h4.copyWith(
                    color: topMatch.confidence > 0.7 ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
            if (diagnosis.imagePath.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.file(
                  File(diagnosis.imagePath),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(topMatch.description,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary), maxLines: 2),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _severityBadge(topMatch.severity),
                const Spacer(),
                Text(DateFormat.yMMMd().format(diagnosis.timestamp),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),

            // Treatment preview
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medical_services_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(topMatch.treatment,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary), maxLines: 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added prescribed treatment to Cart!'),
                      backgroundColor: AppColors.primary,
                      action: SnackBarAction(
                        label: 'VIEW',
                        textColor: Colors.white,
                        onPressed: () => context.go('/marketplace/cart'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                label: const Text('Add Prescription to Cart'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _severityBadge(String severity) {
    final color = switch (severity) {
      'critical' => AppColors.error,
      'high' => AppColors.warning,
      'medium' => AppColors.accent,
      _ => AppColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(severity.toUpperCase(),
          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
