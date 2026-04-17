import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/questionnaire_result.dart';
import '../services/questionnaire_storage.dart';
import '../theme/opto_spacing.dart';
import '../widgets/design_system/opto_action_button.dart';
import '../widgets/design_system/opto_card.dart';
import '../widgets/design_system/opto_section_header.dart';
import '../widgets/design_system/opto_segmented_control.dart';

class QuestionnaireFormScreen extends StatefulWidget {
  const QuestionnaireFormScreen({super.key});

  @override
  State<QuestionnaireFormScreen> createState() =>
      _QuestionnaireFormScreenState();
}

class _QuestionnaireFormScreenState extends State<QuestionnaireFormScreen> {
  final TextEditingController _patientCtrl = TextEditingController();

  late List<CvsqAnswer?> _cvsq;
  late List<int?> _fss;

  @override
  void initState() {
    super.initState();
    _cvsq = List<CvsqAnswer?>.filled(16, null);
    _fss = List<int?>.filled(5, null);
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    super.dispose();
  }

  int get _answeredCount => _cvsq.where((a) => a != null).length;
  bool get _canSave => _answeredCount == 16;
  int get _liveScore =>
      _cvsq.whereType<CvsqAnswer>().fold(0, (s, a) => s + a.score);

  Future<void> _save(AppLocalizations l) async {
    if (!_canSave) return;
    final answers = _cvsq.whereType<CvsqAnswer>().toList(growable: false);
    final q = QuestionnaireResult(
      id: const Uuid().v4(),
      patientName: _patientCtrl.text.trim(),
      completedAt: DateTime.now(),
      cvsqAnswers: answers,
      fssAnswers: List<int?>.unmodifiable(_fss),
      cvsqTotalScore: QuestionnaireResult.computeCvsqTotal(answers),
    );
    await QuestionnaireStorage.addOrUpdate(q);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.questionnaireSavedSnack)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(l, colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OptoSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientField(l, colorScheme),
                    const SizedBox(height: OptoSpacing.md),
                    OptoSectionHeader(title: l.questionnaireCvsqSection),
                    const SizedBox(height: OptoSpacing.sm),
                    _buildCvsqGrid(l, colorScheme),
                    const SizedBox(height: OptoSpacing.md),
                    OptoSectionHeader(title: l.questionnaireFssSection),
                    const SizedBox(height: OptoSpacing.sm),
                    _buildFssGrid(l, colorScheme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildFooter(l, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.questionnaireFormTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            l.questionnaireAnsweredCount(_answeredCount),
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPatientField(AppLocalizations l, ColorScheme cs) {
    return OptoCard(
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            child: TextField(
              controller: _patientCtrl,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: l.questionnairePatientLabel,
                hintStyle: TextStyle(color: cs.onSurfaceVariant),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvsqGrid(AppLocalizations l, ColorScheme cs) {
    return OptoCard(
      padding: const EdgeInsets.all(OptoSpacing.sm),
      child: Column(
        children: List.generate(CvsqItem.values.length, (i) {
          return _buildCvsqRow(i, l, cs);
        }),
      ),
    );
  }

  Widget _buildCvsqRow(int i, AppLocalizations l, ColorScheme cs) {
    final label = _cvsqItemLabel(i, l);
    final answer = _cvsq[i];
    final freq = answer?.frequency;
    final inten = answer?.intensity;
    final intensityDisabled = freq == CvsqFrequency.never;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              '${i + 1}. $label',
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            flex: 3,
            child: OptoSegmentedControl<CvsqFrequency?>(
              items: [
                OptoSegmentItem(value: CvsqFrequency.never, label: l.cvsqFreqNever),
                OptoSegmentItem(value: CvsqFrequency.occasional, label: l.cvsqFreqOccasional),
                OptoSegmentItem(value: CvsqFrequency.habitual, label: l.cvsqFreqHabitual),
              ],
              selected: freq,
              onSelected: (f) => _setFrequency(i, f!),
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            flex: 2,
            child: Opacity(
              opacity: intensityDisabled ? 0.4 : 1.0,
              child: IgnorePointer(
                ignoring: intensityDisabled,
                child: OptoSegmentedControl<CvsqIntensity?>(
                  items: [
                    OptoSegmentItem(value: CvsqIntensity.moderate, label: l.cvsqIntModerate),
                    OptoSegmentItem(value: CvsqIntensity.intense, label: l.cvsqIntIntense),
                  ],
                  selected: inten,
                  onSelected: (v) => _setIntensity(i, v!),
                ),
              ),
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          SizedBox(
            width: 36,
            child: Text(
              '${answer?.score ?? "-"}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setFrequency(int idx, CvsqFrequency f) {
    setState(() {
      final current = _cvsq[idx];
      if (f == CvsqFrequency.never) {
        _cvsq[idx] = const CvsqAnswer(frequency: CvsqFrequency.never, intensity: null);
      } else {
        _cvsq[idx] = CvsqAnswer(frequency: f, intensity: current?.intensity);
      }
    });
  }

  void _setIntensity(int idx, CvsqIntensity v) {
    setState(() {
      final current = _cvsq[idx];
      if (current == null || current.frequency == CvsqFrequency.never) return;
      _cvsq[idx] = current.copyWith(intensity: v);
    });
  }

  Widget _buildFssGrid(AppLocalizations l, ColorScheme cs) {
    return OptoCard(
      padding: const EdgeInsets.all(OptoSpacing.sm),
      child: Column(
        children: List.generate(FssItem.values.length, (i) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: Text(
                    _fssItemLabel(i, l),
                    style: TextStyle(fontSize: 13, color: cs.onSurface),
                  ),
                ),
                const SizedBox(width: OptoSpacing.sm),
                Text(l.fssAnchorAgree,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                const SizedBox(width: 4),
                Expanded(
                  child: OptoSegmentedControl<int?>(
                    items: List.generate(
                      7,
                      (n) => OptoSegmentItem(value: n + 1, label: '${n + 1}'),
                    ),
                    selected: _fss[i],
                    onSelected: (v) => _setFss(i, v),
                  ),
                ),
                const SizedBox(width: 4),
                Text(l.fssAnchorDisagree,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _setFss(int idx, int? v) {
    setState(() {
      if (_fss[idx] == v) {
        _fss[idx] = null; // tap-again to clear
      } else {
        _fss[idx] = v;
      }
    });
  }

  Widget _buildFooter(AppLocalizations l, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l.questionnaireScoreLabel}: $_liveScore · ${l.questionnaireAnsweredCount(_answeredCount)}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          Opacity(
            opacity: _canSave ? 1.0 : 0.4,
            child: IgnorePointer(
              ignoring: !_canSave,
              child: OptoActionButton(
                label: l.questionnaireSaveButton,
                icon: Icons.save,
                onPressed: () => _save(l),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cvsqItemLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.cvsqItem1;
      case 1: return l.cvsqItem2;
      case 2: return l.cvsqItem3;
      case 3: return l.cvsqItem4;
      case 4: return l.cvsqItem5;
      case 5: return l.cvsqItem6;
      case 6: return l.cvsqItem7;
      case 7: return l.cvsqItem8;
      case 8: return l.cvsqItem9;
      case 9: return l.cvsqItem10;
      case 10: return l.cvsqItem11;
      case 11: return l.cvsqItem12;
      case 12: return l.cvsqItem13;
      case 13: return l.cvsqItem14;
      case 14: return l.cvsqItem15;
      case 15: return l.cvsqItem16;
      default: throw StateError('invalid CVS-Q index $i');
    }
  }

  String _fssItemLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.fssItem1;
      case 1: return l.fssItem2;
      case 2: return l.fssItem3;
      case 3: return l.fssItem4;
      case 4: return l.fssItem5;
      default: throw StateError('invalid FSS index $i');
    }
  }
}
