import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/diagnosis.dart';
import '../../../../core/providers/data_providers.dart';

class DiagnosisNotifier extends AsyncNotifier<List<DiagnosisResult>> {
  @override
  Future<List<DiagnosisResult>> build() async {
    final repo = ref.watch(diagnosisRepositoryImplProvider);
    return repo.getDiagnosisHistory('farmer-001');
  }

  Future<void> addResult(DiagnosisResult result) async {
    final repo = ref.read(diagnosisRepositoryImplProvider);
    await repo.saveDiagnosis(result);
    ref.invalidateSelf();
  }
}

final diagnosisHistoryProvider =
    AsyncNotifierProvider<DiagnosisNotifier, List<DiagnosisResult>>(DiagnosisNotifier.new);

/// Loading state for new diagnosis
final diagnosisLoadingProvider = StateProvider<bool>((ref) => false);
