import 'package:flutter/foundation.dart';

enum CvsqFrequency {
  never(0),
  occasional(1),
  habitual(2);

  const CvsqFrequency(this.value);
  final int value;
}

enum CvsqIntensity {
  moderate(1),
  intense(2);

  const CvsqIntensity(this.value);
  final int value;
}

enum CvsqItem {
  burning,
  itching,
  foreignBody,
  tearing,
  excessiveBlinking,
  redEye,
  eyePain,
  heavyEyelids,
  dryness,
  blurredVision,
  doubleVision,
  nearFocusDifficulty,
  lightSensitivity,
  colorHalos,
  worseningVision,
  headache,
}

enum FssItem {
  fatigueLevel,
  motivationLevel,
  stressLevel,
  fatigueInterferes,
  sleepHours,
}

@immutable
class CvsqAnswer {
  const CvsqAnswer({required this.frequency, required this.intensity});

  final CvsqFrequency frequency;
  final CvsqIntensity? intensity;

  int get score {
    if (frequency == CvsqFrequency.never) return 0;
    if (intensity == null) return 0;
    return frequency.value * intensity!.value;
  }

  CvsqAnswer copyWith({
    CvsqFrequency? frequency,
    CvsqIntensity? intensity,
    bool clearIntensity = false,
  }) {
    return CvsqAnswer(
      frequency: frequency ?? this.frequency,
      intensity: clearIntensity ? null : (intensity ?? this.intensity),
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'intensity': intensity?.name,
      };

  factory CvsqAnswer.fromJson(Map<String, dynamic> json) => CvsqAnswer(
        frequency: CvsqFrequency.values.byName(json['frequency'] as String),
        intensity: json['intensity'] == null
            ? null
            : CvsqIntensity.values.byName(json['intensity'] as String),
      );
}

@immutable
class QuestionnaireResult {
  const QuestionnaireResult({
    required this.id,
    required this.patientName,
    required this.completedAt,
    required this.cvsqAnswers,
    required this.fssAnswers,
    required this.cvsqTotalScore,
  });

  final String id;
  final String patientName;
  final DateTime completedAt;
  final List<CvsqAnswer> cvsqAnswers; // length 16, CvsqItem.values order
  final List<int?> fssAnswers;        // length 5, each 1..7 or null
  final int cvsqTotalScore;

  static int computeCvsqTotal(List<CvsqAnswer> answers) =>
      answers.fold(0, (sum, a) => sum + a.score);

  QuestionnaireResult copyWith({
    String? id,
    String? patientName,
    DateTime? completedAt,
    List<CvsqAnswer>? cvsqAnswers,
    List<int?>? fssAnswers,
    int? cvsqTotalScore,
  }) {
    return QuestionnaireResult(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      completedAt: completedAt ?? this.completedAt,
      cvsqAnswers: cvsqAnswers ?? this.cvsqAnswers,
      fssAnswers: fssAnswers ?? this.fssAnswers,
      cvsqTotalScore: cvsqTotalScore ?? this.cvsqTotalScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'completedAt': completedAt.toIso8601String(),
        'cvsqAnswers': cvsqAnswers.map((a) => a.toJson()).toList(),
        'fssAnswers': fssAnswers,
        'cvsqTotalScore': cvsqTotalScore,
      };

  factory QuestionnaireResult.fromJson(Map<String, dynamic> json) =>
      QuestionnaireResult(
        id: json['id'] as String,
        patientName: json['patientName'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
        cvsqAnswers: (json['cvsqAnswers'] as List)
            .map((e) => CvsqAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
        fssAnswers: (json['fssAnswers'] as List)
            .map((e) => e == null ? null : (e as num).toInt())
            .toList(),
        cvsqTotalScore: (json['cvsqTotalScore'] as num).toInt(),
      );
}
