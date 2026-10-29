import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../advisory/presentation/providers/advisory_providers.dart';
import '../../../advisory/presentation/screens/expert_application_view.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/loan_application.dart';
import '../providers/credit_desk_providers.dart';

final _money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

class CreditDeskScreen extends ConsumerWidget {
  const CreditDeskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(currentFarmerIdProvider) != null;
    final verified = ref.watch(isVerifiedLenderProvider);

    Widget body;
    if (!signedIn) {
      body = const Center(child: Text('Sign in to use the Credit Desk.'));
    } else {
      body = verified.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not check your lender status. Connect and retry.')),
        data: (ok) => ok
            ? const _Desk()
            : const ExpertApplicationView(
                professions: ['Lender'],
                title: 'Apply as a verified lender',
                blurb: 'Banks, microfinance institutions and merchants can review farmer '
                    'applications here once the Transfarmation team verifies them.',
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Credit Desk'),
      ),
      body: body,
    );
  }
}

class _Desk extends StatelessWidget {
  const _Desk();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'To review'), Tab(text: 'My decisions'), Tab(text: 'My offers')]),
          Expanded(
            child: TabBarView(
              children: [
                _List(provider: pendingApplicationsForLenderProvider, empty: 'No applications waiting.'),
                _List(provider: decidedApplicationsProvider, empty: 'You have not decided any applications yet.'),
                const _OffersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  final StreamProvider<List<LoanApplication>> provider;
  final String empty;
  const _List({required this.provider, required this.empty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(provider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load applications: $e')),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(empty));
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _Tile(app: items[i]),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final LoanApplication app;
  const _Tile({required this.app});

  @override
  Widget build(BuildContext context) {
    final hasPlan = app.plan != null;
    final color = switch (app.status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };
    return Card(
      child: ListTile(
        title: Text('${_money.format(app.amount)} · ${app.purpose}'),
        subtitle: Text(
          '${app.farmName.isEmpty ? 'Farm' : app.farmName}, ${app.province}\n'
          '${app.cropType} · ${app.farmSize ?? '?'} ha · ${app.repaymentPeriod}'
          '${hasPlan ? '\nFeasibility plan attached' : ''}',
        ),
        isThreeLine: true,
        trailing: Text(app.status, style: AppTextStyles.labelMd.copyWith(color: color)),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => _ReviewScreen(app: app)),
        ),
      ),
    );
  }
}

class _ReviewScreen extends ConsumerStatefulWidget {
  final LoanApplication app;
  const _ReviewScreen({required this.app});

  @override
  ConsumerState<_ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<_ReviewScreen> {
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _decide(bool approve) async {
    final uid = ref.read(currentFarmerIdProvider);
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      final v = await ref.read(advisoryRemoteProvider).verification(uid);
      await ref.read(creditDeskRemoteProvider).decide(
        loanId: widget.app.id,
        approve: approve,
        lenderUid: uid,
        lenderName: (v?['name'] as String?) ?? 'Lender',
        note: _note.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record the decision: $e')),
        );
      }
    }
  }

  Widget _kv(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(a), Text(b, style: AppTextStyles.labelLg)],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final score = a.indicativeScore;
    final plan = a.plan;
    final dscr = plan?['dscr'] as num?;

    return Scaffold(
      appBar: AppBar(title: Text(_money.format(a.amount))),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('The request', style: AppTextStyles.h4),
          _kv('Amount', _money.format(a.amount)),
          _kv('Purpose', a.purpose),
          _kv('Period', a.repaymentPeriod),
          _kv('Applied', DateFormat.yMMMd().format(a.createdAt)),
          const SizedBox(height: AppSpacing.lg),
          Text('The farm (as stated by the farmer)', style: AppTextStyles.h4),
          _kv('Farm', a.farmName),
          _kv('Province', a.province),
          _kv('Size', '${a.farmSize ?? '?'} ha'),
          _kv('Main crop', a.cropType),
          _kv('Farming type', a.farmingType),
          const SizedBox(height: AppSpacing.lg),
          Text('Indicative score: ${score.score}/100 (grade ${score.grade})', style: AppTextStyles.h4),
          Text(
            'Based only on farm details the farmer typed in. There is no repayment '
            'history on the platform for a first-time borrower, and nothing here is verified.',
            style: AppTextStyles.bodySm.copyWith(color: Palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (plan == null)
            Text('No feasibility plan was shared.', style: AppTextStyles.bodyMd)
          else ...[
            Text('Feasibility plan (shared with consent)', style: AppTextStyles.h4),
            _kv('Crop', '${plan['crop']} · ${plan['hectares']} ha'),
            _kv('Revenue (24 mo)', _money.format((plan['revenue'] as num?) ?? 0)),
            _kv('Costs', _money.format((plan['costs'] as num?) ?? 0)),
            _kv('Net profit', _money.format((plan['netProfit'] as num?) ?? 0)),
            _kv('Debt cover', dscr == null ? 'No loan' : dscr.toStringAsFixed(2)),
            _kv('Lowest cash', _money.format((plan['minCash'] as num?) ?? 0)),
            for (final w in (plan['warnings'] as List? ?? const [])) Text('- $w', style: AppTextStyles.bodySm),
            Text(
              'The numbers are the farmer\'s own estimates using standard crop figures.',
              style: AppTextStyles.caption.copyWith(color: Palette.textTertiary),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          if (a.isPending) ...[
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Note to the farmer (conditions, reason, next steps)',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Approving records an approval in principle. Disbursement and repayment '
              'are arranged directly with the farmer; payments are not handled in the app yet.',
              style: AppTextStyles.caption.copyWith(color: Palette.textTertiary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : () => _decide(true),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _decide(false),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text('Decision: ${a.status}', style: AppTextStyles.h4),
            if (a.decisionNote?.isNotEmpty == true) Text(a.decisionNote!),
          ],
        ],
      ),
    );
  }
}

class _OffersTab extends ConsumerWidget {
  const _OffersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(myOffersProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _publish(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New offer'),
      ),
      body: offers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load your offers: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  'Publish an offer and farmers can compare it with others when they apply.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final o in items)
                Card(
                  child: ListTile(
                    title: Text('${_money.format((o['amount'] as num?) ?? 0)} at ${o['interestRate']}% a year'),
                    subtitle: Text('${o['repaymentPeriod']} · about ${_money.format((o['monthlyPayment'] as num?) ?? 0)}/month\n${o['conditions'] ?? ''}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Withdraw',
                      onPressed: () => ref.read(creditDeskRemoteProvider).withdrawOffer(o['id'] as String),
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    final amount = TextEditingController();
    final rate = TextEditingController();
    final months = TextEditingController(text: '12');
    final conditions = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish an offer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (USD)')),
              TextField(controller: rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Interest (% a year)')),
              TextField(controller: months, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Period (months)')),
              TextField(controller: conditions, maxLines: 3, decoration: const InputDecoration(labelText: 'Conditions (collateral, history, etc.)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Publish')),
        ],
      ),
    );
    final a = double.tryParse(amount.text.trim());
    final r = double.tryParse(rate.text.trim());
    final m = int.tryParse(months.text.trim());
    final c = conditions.text.trim();
    final uid = ref.read(currentFarmerIdProvider);
    if (ok == true && uid != null && a != null && a > 0 && r != null && r >= 0 && m != null && m > 0) {
      final v = await ref.read(advisoryRemoteProvider).verification(uid);
      await ref.read(creditDeskRemoteProvider).publishOffer(
        lenderUid: uid,
        lenderName: (v?['name'] as String?) ?? 'Lender',
        amount: a,
        annualRatePct: r,
        months: m,
        conditions: c,
      );
    } else if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount, rate and period.')),
      );
    }
  }
}
