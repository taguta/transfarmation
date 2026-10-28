import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/expert_application.dart';
import '../providers/advisory_providers.dart';

/// Shown on the Advisory Desk to someone who is not yet a verified expert:
/// the application form, or the status of the one they already sent.
class ExpertApplicationView extends ConsumerWidget {
  /// Professions the applicant can choose from (e.g. Agronomist, Veterinarian or Lender).
  final List<String> professions;
  final String title;
  final String blurb;
  const ExpertApplicationView({
    super.key,
    this.professions = const ['Agronomist', 'Veterinarian'],
    this.title = 'Become a verified expert',
    this.blurb = 'Farmers trust advice from verified agronomists and vets. Send your '
        'details and the team will check your licence.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(myApplicationProvider);
    return app.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _msg(Icons.cloud_off_rounded, 'Could not load your application',
          'Connect to the internet and try again.'),
      data: (a) {
        if (a == null) return _Form(professions: professions, title: title, blurb: blurb);
        if (a.isPending) {
          return _msg(Icons.hourglass_top_rounded, 'Application under review',
              'The Transfarmation team is checking your licence. Requests appear here once you are verified.');
        }
        if (a.isRejected) {
          return _Rejected(app: a);
        }
        // Approved: re-check verification so the desk opens.
        WidgetsBinding.instance.addPostFrameCallback((_) => ref.invalidate(isVerifiedExpertProvider));
        return _msg(Icons.verified_rounded, 'You are verified', 'Opening the desk...');
      },
    );
  }

  static Widget _msg(IconData icon, String title, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(text,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _Rejected extends ConsumerWidget {
  final ExpertApplication app;
  const _Rejected({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentFarmerIdProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('Application not approved', style: AppTextStyles.h3),
            if (app.reviewNote?.isNotEmpty == true) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(app.reviewNote!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: uid == null
                  ? null
                  : () => ref.read(advisoryRemoteProvider).withdraw(uid),
              child: const Text('Apply again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  final List<String> professions;
  final String title;
  final String blurb;
  const _Form({required this.professions, required this.title, required this.blurb});

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _licence = TextEditingController();
  final _org = TextEditingController();
  late String _profession = widget.professions.first;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _licence.dispose();
    _org.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_key.currentState?.validate() ?? false)) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(advisoryRemoteProvider).submitApplication(
        ExpertApplication(
          uid: user.uid,
          name: _name.text.trim(),
          profession: _profession,
          licenceNumber: _licence.text.trim(),
          organisation: _org.text.trim(),
          email: user.email ?? '',
          status: 'pending',
          submittedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send your application: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(widget.title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.blurb,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _profession,
            items: [
              for (final p in widget.professions) DropdownMenuItem(value: p, child: Text(p)),
            ],
            onChanged: (v) => _profession = v ?? _profession,
            decoration: const InputDecoration(labelText: 'I am a'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _licence,
            decoration: const InputDecoration(labelText: 'Registration / licence number'),
            validator: (v) => (v == null || v.trim().length < 3) ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _org,
            decoration: const InputDecoration(labelText: 'Organisation (optional)'),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Send application'),
          ),
        ],
      ),
    );
  }
}
