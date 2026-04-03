import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/diagnosis.dart';

class DiagnosisNotifier extends Notifier<List<DiagnosisResult>> {
  @override
  List<DiagnosisResult> build() => _mockHistory;

  void addResult(DiagnosisResult result) {
    state = [result, ...state];
  }

  static final _mockHistory = [
    DiagnosisResult(
      id: 'diag-001',
      type: 'crop',
      imagePath: '',
      subjectName: 'Maize',
      timestamp: DateTime(2026, 3, 28),
      matches: const [
        DiagnosisMatch(
          name: 'Fall Armyworm Damage',
          confidence: 0.92,
          description: 'Larvae feeding damage visible in maize whorl. Ragged holes and frass present.',
          severity: 'high',
          treatment: 'Apply emamectin benzoate or Bt-based biopesticide directly into the whorl. Spray early morning.',
          prevention: 'Scout weekly from 2 weeks after emergence. Consider push-pull intercropping with Desmodium.',
        ),
        DiagnosisMatch(
          name: 'Stalk Borer',
          confidence: 0.15,
          description: 'Possible stalk borer entry holes but less likely based on frass pattern.',
          severity: 'medium',
          treatment: 'Apply granular insecticide into the whorl.',
          prevention: 'Remove and destroy crop residues after harvest.',
        ),
      ],
    ),
    DiagnosisResult(
      id: 'diag-002',
      type: 'livestock',
      imagePath: '',
      subjectName: 'Cattle',
      timestamp: DateTime(2026, 3, 25),
      matches: const [
        DiagnosisMatch(
          name: 'Lumpy Skin Disease',
          confidence: 0.87,
          description: 'Raised nodules visible on skin surface. Characteristic firm lumps on neck and body.',
          severity: 'high',
          treatment: 'Supportive therapy: antibiotics for secondary infections, anti-inflammatory drugs. Isolate affected animals.',
          prevention: 'Annual vaccination with LSD vaccine. Control biting flies and ticks.',
        ),
      ],
    ),
  ];
}

final diagnosisHistoryProvider =
    NotifierProvider<DiagnosisNotifier, List<DiagnosisResult>>(DiagnosisNotifier.new);

/// Loading state for new diagnosis
final diagnosisLoadingProvider = StateProvider<bool>((ref) => false);
