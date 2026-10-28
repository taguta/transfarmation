import '../../../../core/utils/picked_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../knowledge/presentation/providers/knowledge_providers.dart';
import '../../domain/entities/diagnosis.dart';
import '../../domain/services/symptom_matcher.dart';
import '../providers/diagnosis_providers.dart';

class SymptomCheckScreen extends ConsumerStatefulWidget {
  final String type; // crop | livestock
  const SymptomCheckScreen({super.key, required this.type});

  @override
  ConsumerState<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends ConsumerState<SymptomCheckScreen> {
  final _subject = TextEditingController();
  final _selected = <String>{};
  String? _imagePath;
  SymptomAssessment? _assessment;
  DiagnosisResult? _result;
  bool _saved = false;
  bool _escalated = false;
  bool _busy = false;

  bool get _isCrop => widget.type == 'crop';

  @override
  void dispose() {
    _subject.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image != null && mounted) setState(() => _imagePath = image.path);
  }

  Future<void> _check() async {
    setState(() => _busy = true);
    final knowledge = await ref.read(pestsDiseasesProvider.future);
    final assessment = SymptomMatcher.assess(
      type: widget.type,
      selectedTagIds: _selected.toList(),
      knowledge: knowledge,
      subject: _subject.text,
    );
    final labels = SymptomMatcher.tagsFor(widget.type)
        .where((t) => _selected.contains(t.id))
        .map((t) => t.label)
        .toList();
    final subject = _subject.text.trim();

    setState(() {
      _assessment = assessment;
      _saved = false;
      _escalated = false;
      _busy = false;
      _result = DiagnosisResult(
        id: 'diag-${DateTime.now().millisecondsSinceEpoch}',
        type: widget.type,
        imagePath: _imagePath ?? '',
        subjectName: subject.isEmpty ? (_isCrop ? 'Crop' : 'Animal') : subject,
        timestamp: DateTime.now(),
        symptoms: labels,
        matches: [
          for (final m in assessment.matches)
            DiagnosisMatch(
              name: m.disease.name,
              confidence: m.confidence,
              description: m.disease.description,
              severity: m.disease.severity,
              treatment: m.disease.treatment,
              prevention: m.disease.prevention,
            ),
        ],
      );
    });
  }

  Future<void> _save() async {
    final r = _result;
    if (r == null || _saved) return;
    await ref.read(diagnosisHistoryProvider.notifier).addResult(r);
    if (mounted) setState(() => _saved = true);
  }

  Future<void> _escalate() async {
    final r = _result;
    if (r == null || _escalated) return;
    setState(() => _busy = true);
    await _save();
    await ref.read(diagnosisHistoryProvider.notifier).escalate(r);
    if (mounted) {
      setState(() {
        _escalated = true;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = SymptomMatcher.tagsFor(widget.type);
    final assessment = _assessment;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/diagnosis'),
        ),
        title: Text(_isCrop ? 'Check a Crop' : 'Check an Animal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _subject,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: _isCrop ? 'Which crop? (e.g. Maize, Tomatoes)' : 'Which animal? (e.g. Cattle, Goats, Chickens)',
              prefixIcon: Icon(_isCrop ? Icons.grass_rounded : Icons.pets_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What do you see?', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tick everything that applies. More detail gives a better result.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final t in tags)
                FilterChip(
                  label: Text(t.label),
                  selected: _selected.contains(t.id),
                  onSelected: (on) => setState(() {
                    on ? _selected.add(t.id) : _selected.remove(t.id);
                    _assessment = null;
                    _result = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _photoRow(),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _selected.isEmpty || _busy ? null : _check,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Check symptoms'),
          ),
          if (assessment != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _AssessmentBanner(assessment: assessment),
            if (assessment.shouldEscalate) ...[
              const SizedBox(height: AppSpacing.md),
              _EscalationCard(
                hasPhoto: _imagePath != null,
                reasons: assessment.escalationReasons,
                escalated: _escalated,
                busy: _busy,
                onAsk: _escalate,
                onOpenChat: () => context.go('/expert'),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            for (final m in assessment.matches) _MatchCard(match: m),
            if (assessment.matches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: OutlinedButton.icon(
                  onPressed: _saved ? null : _save,
                  icon: Icon(_saved ? Icons.check_rounded : Icons.bookmark_add_outlined),
                  label: Text(_saved ? 'Saved to history' : 'Save to history'),
                ),
              ),
            if (!assessment.shouldEscalate) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: _escalated || _busy ? null : _escalate,
                icon: const Icon(Icons.support_agent_rounded),
                label: Text(_escalated ? 'Sent to an agronomist' : 'Ask an agronomist anyway'),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _photoRow() {
    return Row(
      children: [
        if (_imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: PickedImage(_imagePath!, width: 72, height: 72, fit: BoxFit.cover),
          ),
        if (_imagePath != null) const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(_imagePath == null ? 'Add photo' : 'Retake'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Gallery'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssessmentBanner extends StatelessWidget {
  final SymptomAssessment assessment;
  const _AssessmentBanner({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final tier = assessment.tier;
    final color = switch (tier) {
      ConfidenceTier.likely => AppColors.success,
      ConfidenceTier.possible => AppColors.warning,
      ConfidenceTier.unsure => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tier.label, style: AppTextStyles.h3.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This is a guide based on the symptoms you ticked. It is not a '
            'confirmed diagnosis and no lab test or photo analysis was done.',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }
}

class _EscalationCard extends StatelessWidget {
  final List<String> reasons;
  final bool escalated;
  final bool busy;
  final VoidCallback onAsk;
  final VoidCallback onOpenChat;
  final bool hasPhoto;
  const _EscalationCard({
    this.hasPhoto = false,
    required this.reasons,
    required this.escalated,
    required this.busy,
    required this.onAsk,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            Text('We recommend asking an agronomist', style: AppTextStyles.labelLg),
          ]),
          const SizedBox(height: AppSpacing.sm),
          for (final r in reasons) Text('• $r', style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.md),
          if (escalated) ...[
            Text(
              'Request saved. It is sent to the advisory team when you are online${hasPhoto ? ' (your photo is attached if it is under 500 KB)' : ''}.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.success),
            ),
            TextButton(onPressed: onOpenChat, child: const Text('Open expert chat')),
          ] else
            FilledButton.icon(
              onPressed: busy ? null : onAsk,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Ask an agronomist'),
            ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final SymptomMatch match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final d = match.disease;
    final pct = (match.confidence * 100).round();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(d.name, style: AppTextStyles.h4)),
              Text('$pct%', style: AppTextStyles.h4),
            ]),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(value: match.confidence, minHeight: 6),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Matches: ${match.matchedSymptoms.join(', ')}', style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            Text(d.description, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            Text('What to do', style: AppTextStyles.labelLg),
            Text(d.treatment, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            Text('Prevention', style: AppTextStyles.labelLg),
            Text(d.prevention, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Confirm the product and dose with an agronomist or vet before treating.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
