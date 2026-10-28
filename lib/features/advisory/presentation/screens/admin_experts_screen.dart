import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/expert_application.dart';
import '../providers/advisory_providers.dart';

/// Admin-only queue for verifying agronomists and vets.
class AdminExpertsScreen extends ConsumerWidget {
  const AdminExpertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: const Text('Verify Experts'),
      ),
      body: admin.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not check admin access.')),
        data: (ok) => !ok
            ? const Center(child: Text('This page is for administrators only.'))
            : const _Queue(),
      ),
    );
  }
}

class _Queue extends ConsumerWidget {
  const _Queue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(pendingApplicationsProvider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load applications: $e')),
      data: (apps) {
        if (apps.isEmpty) {
          return const Center(child: Text('No applications waiting.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: apps.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _AppCard(app: apps[i]),
        );
      },
    );
  }
}

class _AppCard extends ConsumerWidget {
  final ExpertApplication app;
  const _AppCard({required this.app});

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject application'),
        content: TextField(
          controller: note,
          decoration: const InputDecoration(labelText: 'Reason (shown to the applicant)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
        ],
      ),
    );
    final reason = note.text.trim();
    note.dispose();
    final admin = ref.read(currentFarmerIdProvider);
    if (ok == true && admin != null) {
      await ref.read(advisoryRemoteProvider).reject(app, admin, reason);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(currentFarmerIdProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app.name, style: AppTextStyles.h4),
            Text('${app.profession} · ${app.email}', style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            Text('Licence: ${app.licenceNumber}', style: AppTextStyles.labelLg),
            if (app.organisation.isNotEmpty) Text('Organisation: ${app.organisation}'),
            Text('Applied ${DateFormat.yMMMd().format(app.submittedAt)}', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                FilledButton(
                  onPressed: admin == null
                      ? null
                      : () => ref.read(advisoryRemoteProvider).approve(app, admin),
                  child: const Text('Approve'),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => _reject(context, ref),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
