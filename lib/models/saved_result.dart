import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'test_result.dart';
import 'localization_result.dart';
import 'macdonald_result.dart';

@immutable
class SavedResult {
  final String id;
  final String testType;
  final String patientName;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int durationActualSeconds;
  final bool completedNaturally;
  final int totalStimuliShown;
  final int? correctTouches;
  final int? incorrectTouches;
  final int? missedStimuli;
  final double? accuracy;
  final double? avgReactionTimeMs;
  final double? bestReactionTimeMs;
  final double? worstReactionTimeMs;
  final double? stimuliPerMinute;
  final int? anillosCompletados;
  final List<double>? tiempoPorAnillo;
  final List<LetterEvent>? letterEvents;
  final Map<String, String> configSummary;

  const SavedResult({
    required this.id,
    required this.testType,
    required this.patientName,
    required this.startedAt,
    required this.finishedAt,
    required this.durationActualSeconds,
    required this.completedNaturally,
    required this.totalStimuliShown,
    this.correctTouches,
    this.incorrectTouches,
    this.missedStimuli,
    this.accuracy,
    this.avgReactionTimeMs,
    this.bestReactionTimeMs,
    this.worstReactionTimeMs,
    this.stimuliPerMinute,
    this.anillosCompletados,
    this.tiempoPorAnillo,
    this.letterEvents,
    required this.configSummary,
  });

  factory SavedResult.fromTestResult(TestResult result, AppLocalizations l) {
    return SavedResult(
      id: '${result.startedAt.millisecondsSinceEpoch}',
      testType: 'peripheral',
      patientName: result.patientName,
      startedAt: result.startedAt,
      finishedAt: result.finishedAt,
      durationActualSeconds: result.durationActualSeconds,
      completedNaturally: result.completedNaturally,
      totalStimuliShown: result.totalStimuliShown,
      stimuliPerMinute:
          result.durationActualSeconds > 0 ? result.stimuliPerMinute : null,
      configSummary: result.config.localizedSummary(l),
    );
  }

  factory SavedResult.fromLocalizationResult(
      LocalizationResult result, AppLocalizations l) {
    return SavedResult(
      id: '${result.startedAt.millisecondsSinceEpoch}',
      testType: 'localization',
      patientName: result.patientName,
      startedAt: result.startedAt,
      finishedAt: result.finishedAt,
      durationActualSeconds: result.durationActualSeconds,
      completedNaturally: result.completedNaturally,
      totalStimuliShown: result.totalStimuliShown,
      correctTouches: result.correctTouches,
      incorrectTouches: result.incorrectTouches,
      missedStimuli: result.missedStimuli,
      accuracy: result.accuracy,
      avgReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.avgReactionTimeMs : null,
      bestReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.bestReactionTimeMs : null,
      worstReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.worstReactionTimeMs : null,
      stimuliPerMinute:
          result.durationActualSeconds > 0 ? result.stimuliPerMinute : null,
      configSummary: result.config.localizedSummary(l),
    );
  }

  factory SavedResult.fromMacDonaldResult(
      MacDonaldResult result, AppLocalizations l) {
    return SavedResult(
      id: '${result.startedAt.millisecondsSinceEpoch}',
      testType: 'macdonald',
      patientName: result.patientName,
      startedAt: result.startedAt,
      finishedAt: result.finishedAt,
      durationActualSeconds: result.durationActualSeconds,
      completedNaturally: result.completedNaturally,
      totalStimuliShown: result.totalLetrasShown,
      correctTouches: result.correctTouches,
      incorrectTouches: result.incorrectTouches,
      missedStimuli: result.missedLetras,
      accuracy: result.accuracy,
      avgReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.avgReactionTimeMs : null,
      bestReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.bestReactionTimeMs : null,
      worstReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.worstReactionTimeMs : null,
      anillosCompletados: result.anillosCompletados,
      tiempoPorAnillo: result.tiempoPorAnillo.isNotEmpty
          ? List.unmodifiable(result.tiempoPorAnillo)
          : null,
      letterEvents: result.letterEvents.isNotEmpty
          ? List.unmodifiable(result.letterEvents)
          : null,
      configSummary: result.config.localizedSummary(l),
    );
  }

  SavedResult copyWith({String? patientName}) => SavedResult(
        id: id,
        testType: testType,
        patientName: patientName ?? this.patientName,
        startedAt: startedAt,
        finishedAt: finishedAt,
        durationActualSeconds: durationActualSeconds,
        completedNaturally: completedNaturally,
        totalStimuliShown: totalStimuliShown,
        correctTouches: correctTouches,
        incorrectTouches: incorrectTouches,
        missedStimuli: missedStimuli,
        accuracy: accuracy,
        avgReactionTimeMs: avgReactionTimeMs,
        bestReactionTimeMs: bestReactionTimeMs,
        worstReactionTimeMs: worstReactionTimeMs,
        stimuliPerMinute: stimuliPerMinute,
        anillosCompletados: anillosCompletados,
        tiempoPorAnillo: tiempoPorAnillo,
        letterEvents: letterEvents,
        configSummary: configSummary,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'testType': testType,
        'patientName': patientName,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'durationActualSeconds': durationActualSeconds,
        'completedNaturally': completedNaturally,
        'totalStimuliShown': totalStimuliShown,
        if (correctTouches != null) 'correctTouches': correctTouches,
        if (incorrectTouches != null) 'incorrectTouches': incorrectTouches,
        if (missedStimuli != null) 'missedStimuli': missedStimuli,
        if (accuracy != null) 'accuracy': accuracy,
        if (avgReactionTimeMs != null) 'avgReactionTimeMs': avgReactionTimeMs,
        if (bestReactionTimeMs != null)
          'bestReactionTimeMs': bestReactionTimeMs,
        if (worstReactionTimeMs != null)
          'worstReactionTimeMs': worstReactionTimeMs,
        if (stimuliPerMinute != null) 'stimuliPerMinute': stimuliPerMinute,
        if (anillosCompletados != null)
          'anillosCompletados': anillosCompletados,
        if (tiempoPorAnillo != null) 'tiempoPorAnillo': tiempoPorAnillo,
        if (letterEvents != null)
          'letterEvents': letterEvents!.map((e) => e.toJson()).toList(),
        'configSummary': configSummary,
      };

  factory SavedResult.fromJson(Map<String, dynamic> json) => SavedResult(
        id: json['id'] as String,
        testType: json['testType'] as String,
        patientName: json['patientName'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        finishedAt: DateTime.parse(json['finishedAt'] as String),
        durationActualSeconds: json['durationActualSeconds'] as int,
        completedNaturally: json['completedNaturally'] as bool,
        totalStimuliShown: json['totalStimuliShown'] as int,
        correctTouches: json['correctTouches'] as int?,
        incorrectTouches: json['incorrectTouches'] as int?,
        missedStimuli: json['missedStimuli'] as int?,
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        avgReactionTimeMs: (json['avgReactionTimeMs'] as num?)?.toDouble(),
        bestReactionTimeMs: (json['bestReactionTimeMs'] as num?)?.toDouble(),
        worstReactionTimeMs: (json['worstReactionTimeMs'] as num?)?.toDouble(),
        stimuliPerMinute: (json['stimuliPerMinute'] as num?)?.toDouble(),
        anillosCompletados: json['anillosCompletados'] as int?,
        tiempoPorAnillo: (json['tiempoPorAnillo'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList(),
        letterEvents: (json['letterEvents'] as List<dynamic>?)
            ?.map((e) => LetterEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        configSummary:
            Map<String, String>.from(json['configSummary'] as Map),
      );
}
