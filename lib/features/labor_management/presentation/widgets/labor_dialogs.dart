import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/labor_providers.dart';
import '../../domain/entities/labor_models.dart';
import '../../../../theme/app_theme.dart';

class AddWorkerDialog extends ConsumerStatefulWidget {
  const AddWorkerDialog({super.key});

  @override
  ConsumerState<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends ConsumerState<AddWorkerDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();
  String _role = 'Seasonal';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Farm Worker', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
          const SizedBox(height: 12),
          TextField(controller: _wageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Wage (\$)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            items: ['Permanent', 'Seasonal', 'Contractor'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _role = v!),
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              final worker = Worker(
                id: 'WKR-${DateTime.now().millisecondsSinceEpoch}',
                name: _nameCtrl.text,
                role: _role,
                dailyWage: double.tryParse(_wageCtrl.text) ?? 10.0,
                phone: _phoneCtrl.text,
              );
              await ref.read(laborRepositoryProvider).saveWorker(worker);
              ref.invalidate(workersProvider);
              if (mounted) Navigator.pop(context);
            },
            child: _isLoading ? const CircularProgressIndicator() : const Text('Save Worker'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class AssignTaskDialog extends ConsumerStatefulWidget {
  const AssignTaskDialog({super.key});

  @override
  ConsumerState<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends ConsumerState<AssignTaskDialog> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String? _workerId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workersProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Assign Task', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Task Description')),
          const SizedBox(height: 12),
          workersAsync.when(
            data: (workers) => DropdownButtonFormField<String>(
              value: _workerId,
              items: workers.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
              onChanged: (v) => setState(() => _workerId = v),
              decoration: const InputDecoration(labelText: 'Assign To'),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => Text('Error loading workers: $e'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Extra Cost (\$)')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_workerId == null || _nameCtrl.text.isEmpty) return;
              setState(() => _isLoading = true);
              final task = FarmTask(
                id: 'TSK-${DateTime.now().millisecondsSinceEpoch}',
                name: _nameCtrl.text,
                assignedWorkerId: _workerId!,
                date: DateTime.now(),
                status: 'pending',
                estimatedCost: double.tryParse(_costCtrl.text) ?? 0.0,
              );
              await ref.read(laborRepositoryProvider).saveTask(task);
              ref.invalidate(tasksProvider);
              if (mounted) Navigator.pop(context);
            },
            child: _isLoading ? const CircularProgressIndicator() : const Text('Assign'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
