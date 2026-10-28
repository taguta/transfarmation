import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/workspace/workspace.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

class WorkspaceHeader extends ConsumerWidget {
  final String displayName;
  const WorkspaceHeader({super.key, required this.displayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider).current;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionChip(
                avatar: Icon(ws.icon, size: 18, color: AppColors.primary),
                label: Text(ws.name),
                onPressed: () => showWorkspaceSwitcher(context, ref),
                backgroundColor: AppColors.primarySurface,
                side: BorderSide.none,
                labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ),
      ],
    );
  }
}

Future<void> showWorkspaceSwitcher(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final state = ref.watch(workspaceProvider);
        final notifier = ref.read(workspaceProvider.notifier);
        final others = workspaces.keys.where((r) => !state.roles.contains(r));
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            children: [
              Text('Switch workspace', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'One account, many roles. No need to sign out.',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final role in state.roles)
                ListTile(
                  leading: Icon(workspaces[role]!.icon, color: AppColors.primary),
                  title: Text(workspaces[role]!.name),
                  subtitle: Text(workspaces[role]!.tagline),
                  trailing: role == state.active
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    notifier.switchTo(role);
                    Navigator.pop(ctx);
                  },
                ),
              if (others.isNotEmpty) ...[
                const Divider(),
                Text('Add another role', style: AppTextStyles.labelLg),
                for (final role in others)
                  ListTile(
                    leading: Icon(workspaces[role]!.icon, color: AppColors.textSecondary),
                    title: Text(workspaces[role]!.name),
                    subtitle: Text(workspaces[role]!.tagline),
                    trailing: const Icon(Icons.add_rounded),
                    onTap: () {
                      notifier.addRole(role);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

/// Quick-action grid for the active workspace.
class WorkspaceActions extends ConsumerWidget {
  final int columns;
  const WorkspaceActions({super.key, required this.columns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider).current;
    return Column(
      children: [
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            for (final a in ws.actions)
              _ActionTile(action: a, onTap: () => context.push(a.route)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/services'),
            icon: const Icon(Icons.apps_rounded, size: 18),
            label: const Text('All Services'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final WorkspaceAction action;
  final VoidCallback onTap;
  const _ActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
