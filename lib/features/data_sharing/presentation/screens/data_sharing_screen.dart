import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/data_share.dart';
import '../providers/data_share_providers.dart';

final _date = DateFormat.yMMMd();

/// Who can see the farmer's data. Sharing is always a choice the farmer makes
/// here (or when exporting a loan file), and can be stopped in one tap.
class DataSharingScreen extends ConsumerWidget {
  const DataSharingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharesAsync = ref.watch(dataSharesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: const Text('Who can see my data'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showShareSheet(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Share with someone'),
      ),
      body: sharesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load sharing choices: $e')),
        data: (shares) {
          final active = DataSharing.active(shares);
          final past = shares.where((s) => !s.isActive).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96,
            ),
            children: [
              Text(
                'Your ledger, plans and farm details are private to you unless you share '
                'them here. A loan application you submit can be seen by verified lenders. '
                'You can stop sharing at any time.',
                style: AppTextStyles.bodyMd.copyWith(color: Palette.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Sharing now', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              if (active.isEmpty)
                Text(
                  'You are not sharing anything with anyone.',
                  style: AppTextStyles.bodyMd.copyWith(color: Palette.textSecondary),
                )
              else
                for (final s in active) _ShareTile(share: s, ref: ref),
              if (past.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text('Stopped', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                for (final s in past) _ShareTile(share: s, ref: ref),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  final DataShare share;
  final WidgetRef ref;
  const _ShareTile({required this.share, required this.ref});

  Future<void> _revoke(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stop sharing with ${share.recipientName}?'),
        content: Text(
          '${share.recipientName} will no longer be allowed to see: ${share.scope.title}. '
          'Anything they already received stays with them.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Stop sharing')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(dataShareRepositoryProvider).revoke(share.id);
    ref.invalidate(dataSharesProvider);
    messenger.showSnackBar(const SnackBar(content: Text('Sharing stopped.')));
  }

  @override
  Widget build(BuildContext context) {
    final stopped = !share.isActive;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Palette.border),
      ),
      child: Row(
        children: [
          Icon(
            stopped ? Icons.block_rounded : Icons.share_rounded,
            color: stopped ? Palette.textTertiary : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(share.recipientName, style: AppTextStyles.labelLg),
                Text(share.scope.title, style: AppTextStyles.bodyMd),
                Text(
                  stopped
                      ? 'Shared ${_date.format(share.grantedAt.toLocal())}, stopped ${_date.format(share.revokedAt!.toLocal())}'
                      : 'Shared ${_date.format(share.grantedAt.toLocal())}',
                  style: AppTextStyles.caption.copyWith(color: Palette.textTertiary),
                ),
              ],
            ),
          ),
          if (!stopped)
            TextButton(onPressed: () => _revoke(context), child: const Text('Stop')),
        ],
      ),
    );
  }
}

/// Asks who to share with and what. Returns the recipient's name if the farmer
/// shared, or null if they cancelled.
/// [initialRecipient] and [initialScopes] pre-fill the form (for example when
/// exporting a loan file to a known lender).
Future<String?> showShareSheet(
  BuildContext context,
  WidgetRef ref, {
  String initialRecipient = '',
  Set<ShareScope> initialScopes = const {},
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _ShareSheet(
      ref: ref,
      initialRecipient: initialRecipient,
      initialScopes: initialScopes,
    ),
  );
}

class _ShareSheet extends StatefulWidget {
  final WidgetRef ref;
  final String initialRecipient;
  final Set<ShareScope> initialScopes;
  const _ShareSheet({
    required this.ref,
    required this.initialRecipient,
    required this.initialScopes,
  });

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  late final TextEditingController _name;
  late final Set<ShareScope> _scopes;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialRecipient);
    _scopes = {...widget.initialScopes};
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter who you are sharing with');
      return;
    }
    if (_scopes.isEmpty) {
      setState(() => _error = 'Choose what to share');
      return;
    }
    setState(() => _saving = true);
    final farmerId = widget.ref.read(activeFarmerIdProvider);
    await widget.ref.read(dataShareRepositoryProvider).grant(
      farmerId: farmerId,
      recipientName: _name.text,
      scopes: _scopes,
    );
    widget.ref.invalidate(dataSharesProvider);
    if (mounted) Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share with someone', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Who (bank, lender or company name)',
                prefixIcon: Icon(Icons.business_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('What can they see?', style: AppTextStyles.labelLg),
            for (final s in ShareScope.values)
              CheckboxListTile(
                value: _scopes.contains(s),
                onChanged: (v) => setState(() {
                  _error = null;
                  v == true ? _scopes.add(s) : _scopes.remove(s);
                }),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(s.title),
                subtitle: Text(s.description),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(_error!, style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
