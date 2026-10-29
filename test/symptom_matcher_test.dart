import 'package:flutter_test/flutter_test.dart';
import 'package:transfarmation/features/diagnosis/domain/services/symptom_matcher.dart';
import 'package:transfarmation/features/knowledge/domain/entities/pest_disease.dart';
import 'package:transfarmation/features/knowledge/infrastructure/repositories/knowledge_repository_impl.dart';

void main() {
  late final List<PestDisease> knowledge;
  setUpAll(() async {
    knowledge = await KnowledgeRepositoryImpl().getAllPestsDiseases();
  });

  test('foot-and-mouth symptoms rank foot and mouth first', () {
    final a = SymptomMatcher.assess(
      type: 'livestock',
      selectedTagIds: ['blisters', 'drooling', 'lameness'],
      knowledge: knowledge,
      subject: 'Cattle',
    );
    expect(a.matches.first.disease.name, contains('Foot and Mouth'));
    expect(a.matches.first.confidence, lessThanOrEqualTo(SymptomMatcher.maxConfidence));
  });

  test('a single symptom is never a likely match and escalates', () {
    final a = SymptomMatcher.assess(
      type: 'livestock',
      selectedTagIds: ['fever'],
      knowledge: knowledge,
    );
    expect(a.tier, isNot(ConfidenceTier.likely));
    expect(a.shouldEscalate, isTrue);
  });

  test('the more symptoms ticked, the more confidence is allowed', () {
    expect(SymptomMatcher.capFor(1), 0.5);
    expect(SymptomMatcher.capFor(2), 0.7);
    expect(SymptomMatcher.capFor(3), 0.8);
    expect(SymptomMatcher.capFor(4), SymptomMatcher.maxConfidence);
  });

  test('two symptoms never score above 70%, even on a full match', () {
    final a = SymptomMatcher.assess(
      type: 'crop',
      selectedTagIds: ['holes', 'larvae'],
      knowledge: knowledge,
      subject: 'Maize',
    );
    expect(a.matches.first.confidence, lessThanOrEqualTo(0.7));
  });

  test('crop symptoms never return livestock conditions', () {
    final a = SymptomMatcher.assess(
      type: 'crop',
      selectedTagIds: ['holes', 'larvae'],
      knowledge: knowledge,
    );
    expect(a.matches, isNotEmpty);
    expect(a.matches.every((m) => m.disease.affects != 'livestock'), isTrue);
  });

  test('critical conditions always recommend an agronomist', () {
    final a = SymptomMatcher.assess(
      type: 'crop',
      selectedTagIds: ['holes', 'larvae'],
      knowledge: knowledge,
      subject: 'Maize',
    );
    expect(a.matches.first.disease.severity, 'critical');
    expect(a.shouldEscalate, isTrue);
  });

  test('no matching symptoms gives an unsure result that escalates', () {
    final a = SymptomMatcher.assess(
      type: 'crop',
      selectedTagIds: ['birds'],
      knowledge: const [],
    );
    expect(a.tier, ConfidenceTier.unsure);
    expect(a.shouldEscalate, isTrue);
  });
}
