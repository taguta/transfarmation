import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/iot_providers.dart';
import '../../domain/entities/sensor_node.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class ScanSensorDialog extends ConsumerStatefulWidget {
  const ScanSensorDialog({super.key});

  @override
  ConsumerState<ScanSensorDialog> createState() => _ScanSensorDialogState();
}

class _ScanSensorDialogState extends ConsumerState<ScanSensorDialog> {
  bool _isScanning = true;
  bool _isSaving = false;
  SensorNode? _discoveredNode;

  @override
  void initState() {
    super.initState();
    _simulateScan();
  }

  void _simulateScan() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    final r = Random();
    final types = ['Soil Moisture', 'Temperature', 'Water Flow'];
    final selectedType = types[r.nextInt(types.length)];
    
    setState(() {
      _isScanning = false;
      _discoveredNode = SensorNode(
        id: 'SN-${r.nextInt(900) + 100}X',
        name: 'New Node - $selectedType',
        type: selectedType,
        status: 'online',
        battery: 100,
        currentValue: selectedType == 'Soil Moisture' ? '0%' : (selectedType == 'Temperature' ? '25°C' : '0 L/min'),
        trend: 'stable',
        lastUpdated: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Hardware Node', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          
          if (_isScanning) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            const Center(child: Text('Scanning for Bluetooth devices in range...')),
          ] else if (_discoveredNode != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_connected_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_discoveredNode!.id, style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                        Text('Detected as ${_discoveredNode!.type}', style: AppTextStyles.bodySm),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                await ref.read(iotRepositoryProvider).saveSensor(_discoveredNode!);
                ref.invalidate(sensorsProvider);
                if (mounted) Navigator.pop(context);
              },
              child: _isSaving ? const CircularProgressIndicator() : const Text('Pair & Save'),
            )
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
