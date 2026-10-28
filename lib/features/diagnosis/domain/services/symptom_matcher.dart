import '../../../knowledge/domain/entities/pest_disease.dart';

/// A symptom a farmer can tick. Keywords are matched against the free-text
/// symptom description of each knowledge-base entry.
class SymptomTag {
  final String id;
  final String label;
  final String type; // crop, livestock
  final List<String> keywords;
  const SymptomTag(this.id, this.label, this.type, this.keywords);
}

const symptomTags = <SymptomTag>[
  // Crops
  SymptomTag('holes', 'Holes or chewed leaves', 'crop', ['hole', 'ragged', 'windowpane']),
  SymptomTag('mines', 'Tunnels or mines in leaves', 'crop', ['mines', 'tunnel']),
  SymptomTag('larvae', 'Caterpillars or droppings seen', 'crop', ['larvae', 'frass', 'droppings']),
  SymptomTag('yellow', 'Yellow streaks or yellowing', 'crop', ['yellow']),
  SymptomTag('stunted', 'Stunted growth', 'crop', ['stunted']),
  SymptomTag('spots', 'Brown spots or lesions on leaves', 'crop', ['lesion', 'spots']),
  SymptomTag('defoliation', 'Leaves dropping early', 'crop', ['defoliation']),
  SymptomTag('heads', 'Damaged grain heads or pods', 'crop', ['grain head', 'panicle', 'pods']),
  SymptomTag('birds', 'Flocks of birds on the field', 'crop', ['bird', 'flock']),
  // Livestock
  SymptomTag('fever', 'High fever', 'livestock', ['fever']),
  SymptomTag('diarrhoea', 'Diarrhoea', 'livestock', ['diarrh']),
  SymptomTag('bloody', 'Blood in droppings', 'livestock', ['bloody']),
  SymptomTag('appetite', 'Not eating or losing weight', 'livestock', ['appetite', 'weight loss', 'reluctance to eat']),
  SymptomTag('breathing', 'Coughing or laboured breathing', 'livestock', ['breathing', 'cough', 'sneez', 'nasal']),
  SymptomTag('swelling', 'Swollen glands or under the jaw', 'livestock', ['swollen', 'bottle jaw']),
  SymptomTag('blisters', 'Blisters in mouth or on feet', 'livestock', ['blister']),
  SymptomTag('drooling', 'Drooling', 'livestock', ['drool']),
  SymptomTag('lameness', 'Lameness', 'livestock', ['lameness']),
  SymptomTag('purple', 'Purple skin on ears, snout or belly', 'livestock', ['purple']),
  SymptomTag('production', 'Drop in milk or egg production', 'livestock', ['milk production', 'egg production']),
  SymptomTag('neck', 'Twisted neck or drooping wings', 'livestock', ['twisted neck', 'drooping']),
  SymptomTag('pale', 'Pale gums or eyelids', 'livestock', ['anemia', 'pale']),
  SymptomTag('coat', 'Rough coat or pot belly', 'livestock', ['rough coat', 'pot belly']),
  SymptomTag('death', 'Sudden deaths in the herd or flock', 'livestock', ['sudden death', 'death within']),
];

enum ConfidenceTier {
  likely('Likely match'),
  possible('Possible match'),
  unsure('Not enough to tell');

  final String label;
  const ConfidenceTier(this.label);

  static ConfidenceTier fromConfidence(double c) =>
      c >= SymptomMatcher.likelyThreshold
          ? likely
          : c >= SymptomMatcher.possibleThreshold
              ? possible
              : unsure;
}

class SymptomMatch {
  final PestDisease disease;
  final double confidence;
  final List<String> matchedSymptoms;
  const SymptomMatch(this.disease, this.confidence, this.matchedSymptoms);
}

class SymptomAssessment {
  final List<SymptomMatch> matches;
  final ConfidenceTier tier;
  final bool shouldEscalate;
  final List<String> escalationReasons;
  const SymptomAssessment({
    required this.matches,
    required this.tier,
    required this.shouldEscalate,
    required this.escalationReasons,
  });
}

class SymptomMatcher {
  static const likelyThreshold = 0.6;
  static const possibleThreshold = 0.35;

  /// A symptom check is never conclusive, so confidence is capped here.
  static const maxConfidence = 0.85;
  static const thinEvidenceCap = 0.5;

  static List<SymptomTag> tagsFor(String type) =>
      symptomTags.where((t) => t.type == type).toList();

  static SymptomAssessment assess({
    required String type,
    required List<String> selectedTagIds,
    required List<PestDisease> knowledge,
    String subject = '',
  }) {
    final tags = tagsFor(type);
    final selected = tags.where((t) => selectedTagIds.contains(t.id)).toList();

    var candidates = knowledge
        .where((d) => d.affects == type || d.affects == 'both')
        .toList();

    final reasons = <String>[];
    final needle = subject.trim().toLowerCase();
    if (needle.isNotEmpty) {
      final forSubject = candidates.where((d) {
        final names = type == 'crop' ? d.affectedCrops : d.affectedLivestock;
        return names.any((n) => n.toLowerCase().contains(needle) || needle.contains(n.toLowerCase()));
      }).toList();
      if (forSubject.isNotEmpty) {
        candidates = forSubject;
      } else {
        reasons.add('Our guide has no entries for "${subject.trim()}", so matches are general.');
      }
    }

    final matches = <SymptomMatch>[];
    for (final d in candidates) {
      final text = d.symptoms.toLowerCase();
      final diseaseTags = tags.where((t) => t.keywords.any(text.contains)).toList();
      final hits = selected.where(diseaseTags.contains).toList();
      if (hits.isEmpty) continue;
      final precision = hits.length / selected.length;
      final recall = hits.length / diseaseTags.length;
      var confidence = (0.6 * precision + 0.4 * recall) * maxConfidence;
      // One symptom can never justify a "likely" match.
      if (selected.length < 2) confidence = confidence.clamp(0.0, thinEvidenceCap);
      matches.add(SymptomMatch(d, confidence, hits.map((t) => t.label).toList()));
    }
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    final top = matches.take(3).toList();

    final tier = top.isEmpty
        ? ConfidenceTier.unsure
        : ConfidenceTier.fromConfidence(top.first.confidence);

    if (top.isEmpty) {
      reasons.add('None of the symptoms you chose match a condition in our guide.');
    } else {
      if (tier != ConfidenceTier.likely) {
        reasons.add('The match is weak. Several conditions look alike.');
      }
      if (top.length > 1 && top.first.confidence - top[1].confidence < 0.1) {
        reasons.add('Two conditions fit almost equally well.');
      }
      if (top.first.disease.severity == 'critical') {
        reasons.add('${top.first.disease.name} can be very serious. Get it confirmed.');
      }
    }
    if (selected.length < 2) {
      reasons.add('Only ${selected.length} symptom chosen. More detail gives a better result.');
    }

    return SymptomAssessment(
      matches: top,
      tier: tier,
      shouldEscalate: reasons.any((r) => !r.startsWith('Our guide has no entries')),
      escalationReasons: reasons,
    );
  }
}
