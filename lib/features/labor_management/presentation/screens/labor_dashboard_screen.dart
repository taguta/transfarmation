import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/labor_models.dart';
import '../providers/labor_providers.dart';

class LaborDashboardScreen extends ConsumerWidget {
  const LaborDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(workersProvider);
    final tasks = ref.watch(tasksProvider);
    final totalSpent = ref.watch(totalLaborCostProvider);

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
                  Text('Labor & Tasks', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Worker dialog coming soon')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text('Manage farm workers and daily assignments',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
              
              const SizedBox(height: AppSpacing.xxl),

              // KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Active Workers',
                      value: workers.length.toString(),
                      icon: Icons.people_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      title: 'Labor Spent',
                      value: '\$${totalSpent.toStringAsFixed(2)}',
                      icon: Icons.payments_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Workers List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Team Registry', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (workers.isEmpty)
                const Center(child: Text('No workers registered.'))
              else
                ...workers.map((w) => _WorkerCard(worker: w)),

              const SizedBox(height: AppSpacing.xxl),

              // Daily Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending Tasks', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assign Task dialog coming soon')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...tasks.where((t) => t.status != 'completed').map((t) => _TaskCard(task: t, workerName: workers.firstWhere((w) => w.id == t.assignedWorkerId, orElse: () => Worker(id: '', name: 'Unassigned', role: '', dailyWage: 0, phone: '')).name)),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
          Text(title, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;
  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    final roleColor = worker.role == 'Permanent' ? AppColors.primary : (worker.role == 'Seasonal' ? AppColors.harvestGold : AppColors.secondary);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(worker.name.substring(0, 1).toUpperCase(), 
                  style: AppTextStyles.h4.copyWith(color: roleColor)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name, style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimary)),
                  Text(worker.phone, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(worker.role, style: AppTextStyles.caption.copyWith(color: roleColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text('\$${worker.dailyWage.toStringAsFixed(2)}/day', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final FarmTask task;
  final String workerName;
  const _TaskCard({required this.task, required this.workerName});

  @override
  Widget build(BuildContext context) {
    final isPending = task.status == 'pending';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              isPending ? Icons.radio_button_unchecked_rounded : Icons.pending_actions_rounded,
              color: isPending ? AppColors.textTertiary : AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name, style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.textPrimary,
                    decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
                  )),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(workerName, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(DateFormat('MMM d').format(task.date), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
