import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/escalation.dart';
import '../providers/advisory_providers.dart';
import 'expert_application_view.dart';

String _waited(Duration d) {
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes} min';
  if (d.inDays < 1) return '${d.inHours} h';
  return '${d.inDays} d';
}

class AdvisoryDeskScreen extends ConsumerWidget {
  const AdvisoryDeskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verified = ref.watch(isVerifiedExpertProvider);
    final signedIn = ref.watch(currentFarmerIdProvider) != null;

    Widget body;
    if (!signedIn) {
      body = const _Notice(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to use the Advisory Desk',
        text: 'The desk is for verified agronomists and vets.',
      );
    } else {
      body = verified.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Notice(
          icon: Icons.cloud_off_rounded,
          title: 'Could not check your expert status',
          text: 'Connect to the internet and try again.',
        ),
        data: (ok) => ok
            ? const _Desk()
            : const ExpertApplicationView(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Advisory Desk'),
      ),
      body: body,
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Notice({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) => Center(
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

class _Desk extends ConsumerWidget {
  const _Desk();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Waiting'), Tab(text: 'My answers')]),
          Expanded(
            child: TabBarView(
              children: [
                _List(provider: openEscalationsProvider, empty: 'No farmers are waiting. Well done.'),
                _List(provider: answeredEscalationsProvider, empty: 'You have not answered any requests yet.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  final StreamProvider<List<Escalation>> provider;
  final String empty;
  const _List({required this.provider, required this.empty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(provider).when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _Notice(
        icon: Icons.error_outline_rounded,
        title: 'Could not load requests',
        text: '$e',
      ),
      data: (items) {
        if (items.isEmpty) {
          return _Notice(icon: Icons.inbox_rounded, title: empty, text: '');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _Tile(item: items[i]),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final Escalation item;
  const _Tile({required this.item});

  @override
  Widget build(BuildContext context) {
    final top = item.matches.isEmpty ? null : item.matches.first;
    final critical = item.matches.any((m) => m.severity == 'critical');
    return Card(
      child: ListTile(
        leading: Icon(
          item.type == 'crop' ? Icons.grass_rounded : Icons.pets_rounded,
          color: critical ? AppColors.error : AppColors.primary,
        ),
        title: Text(item.subjectName.isEmpty ? 'Unnamed' : item.subjectName),
        subtitle: Text(
          [
            if (top != null) '${top.name} (${(top.confidence * 100).round()}%)' else 'No match found',
            item.symptoms.join(', '),
          ].where((s) => s.isNotEmpty).join('\n'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_waited(item.waiting), style: AppTextStyles.labelMd),
            Text(item.isOpen ? 'waiting' : 'answered', style: AppTextStyles.caption),
          ],
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => _CaseScreen(item: item)),
        ),
      ),
    );
  }
}

class _CaseScreen extends ConsumerStatefulWidget {
  final Escalation item;
  const _CaseScreen({required this.item});

  @override
  ConsumerState<_CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends ConsumerState<_CaseScreen> {
  final _reply = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final uid = ref.read(currentFarmerIdProvider);
    final text = _reply.text.trim();
    if (uid == null || text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(advisoryRemoteProvider).reply(widget.item.id, text, uid);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send the reply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(title: Text(item.subjectName.isEmpty ? 'Case' : item.subjectName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (item.photoBase64 != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.memory(
                base64Decode(item.photoBase64!),
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Text('The photo could not be shown.'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text('Reported by the farmer', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [for (final s in item.symptoms) Chip(label: Text(s))],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What the app suggested', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.sm),
          if (item.matches.isEmpty)
            const Text('Nothing in the guide matched these symptoms.')
          else
            for (final m in item.matches)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(m.name),
                subtitle: Text('Severity: ${m.severity}'),
                trailing: Text('${(m.confidence * 100).round()}%'),
              ),
          const SizedBox(height: AppSpacing.lg),
          if (item.isOpen) ...[
            Text('Your advice', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reply,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Say what you think it is, what to do now, and when to call a vet or visit.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send reply'),
            ),
          ] else ...[
            Text('Your reply', style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.sm),
            Text(item.reply ?? ''),
          ],
        ],
      ),
    );
  }
}
