// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OptoView';

  @override
  String get menuTitle => 'OptoViewApp - Menu';

  @override
  String get menuStart => 'Start';

  @override
  String get menuCredits => 'Credits';

  @override
  String get testMenuTitle => 'Choose an exercise';

  @override
  String get testPeripheralTitle => 'Peripheral stimulation';

  @override
  String get testPeripheralSubtitle => 'Train dynamic peripheral perception.';

  @override
  String get testLocalizationTitle => 'Peripheral localization';

  @override
  String get testLocalizationSubtitle => 'Train peripheral localization.';

  @override
  String get testComingSoonTitle => 'More coming soon';

  @override
  String get testComingSoonSubtitle => 'New evaluation protocols.';

  @override
  String get testComingSoonSnackbar => 'We are working on more specialized tests.';

  @override
  String get configPeripheralTitle => 'Peripheral stimulation test';

  @override
  String get configLocalizationTitle => 'Peripheral localization test';

  @override
  String get startTest => 'Start test';

  @override
  String get presetsTitle => 'Presets';

  @override
  String get presetsHint => 'Select a preset or customize each option below.';

  @override
  String get presetStandard => 'Standard';

  @override
  String get presetStandardDesc => 'Balanced configuration for general use';

  @override
  String get presetEasy => 'Easy';

  @override
  String get presetEasyDesc => 'Large and slow stimuli, ideal for beginners';

  @override
  String get presetAdvanced => 'Advanced';

  @override
  String get presetAdvancedDesc => 'Fast, small stimuli with distractors';

  @override
  String get presetLocStandardDesc => 'Match center, medium speed';

  @override
  String get presetLocEasyDesc => 'Touch all, slow, with feedback';

  @override
  String get presetLocAdvancedDesc => 'Same shape, fast, no feedback, 3 stimuli';

  @override
  String get sideTitle => 'Stimulation side';

  @override
  String get sideLeft => 'Left';

  @override
  String get sideRight => 'Right';

  @override
  String get sideTop => 'Top';

  @override
  String get sideBottom => 'Bottom';

  @override
  String get sideBoth => 'Both';

  @override
  String get sideRandom => 'Random';

  @override
  String get sideDescLeft => 'Stimuli will appear only on the left side of the screen.';

  @override
  String get sideDescRight => 'Stimuli will appear only on the right side of the screen.';

  @override
  String get sideDescTop => 'Stimuli will appear only on the top.';

  @override
  String get sideDescBottom => 'Stimuli will appear only on the bottom.';

  @override
  String get sideDescBoth => 'Stimuli can appear on both sides.';

  @override
  String get sideDescRandom => 'The stimuli appearance side will be random each cycle.';

  @override
  String get symbolTitle => 'Stimulus type';

  @override
  String get symbolLetters => 'Letters';

  @override
  String get symbolNumbers => 'Numbers';

  @override
  String get symbolShapes => 'Shapes';

  @override
  String get symbolFormTitle => 'Shape (optional)';

  @override
  String get symbolFormRandom => 'Random';

  @override
  String get formaCircle => 'Circle';

  @override
  String get formaSquare => 'Square';

  @override
  String get formaHeart => 'Heart';

  @override
  String get formaTriangle => 'Triangle';

  @override
  String get formaClover => 'Clover';

  @override
  String get colorTitle => 'Stimulus color';

  @override
  String get colorRed => 'Red';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorWhite => 'White';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorRandom => 'Random';

  @override
  String get speedTitle => 'Speed';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedMedium => 'Medium';

  @override
  String get speedFast => 'Fast';

  @override
  String get movementTitle => 'Stimulus movement';

  @override
  String get movementFixed => 'Fixed';

  @override
  String get movementHorizontal => 'Horizontal';

  @override
  String get movementVertical => 'Vertical';

  @override
  String get movementRandom => 'Random';

  @override
  String get movementDescFixed => 'The stimulus remains static in its position.';

  @override
  String get movementDescHorizontal => 'The stimulus slides from left to right or vice versa.';

  @override
  String get movementDescVertical => 'The stimulus slides from top to bottom or vice versa.';

  @override
  String get movementDescRandom => 'The stimulus randomly alternates between horizontal and vertical displacement.';

  @override
  String get distanceTitle => 'Distance to center';

  @override
  String get distanceRandom => 'Random';

  @override
  String get distanceRandomSubtitle => 'Randomly changes the stimulus distance';

  @override
  String get distanceFixed => 'Fixed';

  @override
  String distanceCurrent(String pct) {
    return 'Current distance: $pct%';
  }

  @override
  String get durationTitle => 'Duration (seconds)';

  @override
  String durationLabel(int value) {
    return '$value s';
  }

  @override
  String get sizeTitle => 'Size (%)';

  @override
  String get sizeRandomToggle => 'Vary size randomly';

  @override
  String get sizeRandomSubtitle => 'When enabled, each stimulus will adjust its size around the configured value.';

  @override
  String get fixationTitle => 'Fixation point';

  @override
  String get fixationFace => 'Face';

  @override
  String get fixationEye => 'Eye';

  @override
  String get fixationDot => 'Dot';

  @override
  String get fixationClover => 'Clover';

  @override
  String get fixationCross => 'Cross';

  @override
  String get backgroundTitle => 'Background & distractor';

  @override
  String get backgroundLight => 'Light';

  @override
  String get backgroundDark => 'Dark';

  @override
  String get backgroundBlue => 'Blue';

  @override
  String get backgroundDistractor => 'Distractor background';

  @override
  String get backgroundDistractorSubtitle => 'Adds a soft low-intensity pattern.';

  @override
  String get backgroundAnimate => 'Animate distractor';

  @override
  String get backgroundAnimateSubtitle => 'Enables subtle pattern movement to increase visual difficulty.';

  @override
  String get locModeTitle => 'Localization mode';

  @override
  String get locModeTouchAll => 'Touch all';

  @override
  String get locModeMatchCenter => 'Match center';

  @override
  String get locModeSameColor => 'Same color';

  @override
  String get locModeSameShape => 'Same shape';

  @override
  String get locModeTouchAllDesc => 'Touch all stimuli that appear';

  @override
  String get locModeMatchCenterDesc => 'Only touch those matching the center';

  @override
  String get locModeSameColorDesc => 'Only touch those with the same color as the center';

  @override
  String get locModeSameShapeDesc => 'Only touch those with the same shape as the center';

  @override
  String get locInteractionTitle => 'Interaction options';

  @override
  String get locCenterFixed => 'Fixed center';

  @override
  String get locCenterFixedOn => 'The central stimulus does not change during the test';

  @override
  String get locCenterFixedOff => 'The central stimulus changes each cycle';

  @override
  String get locFeedback => 'Visual feedback';

  @override
  String get locFeedbackSubtitle => 'Show visual indication on touch (correct/error)';

  @override
  String get locDisappearTitle => 'Stimulus disappearance';

  @override
  String get locDisappearByTime => 'By time';

  @override
  String get locDisappearWaitTouch => 'Wait for touch';

  @override
  String get locSimultaneousTitle => 'Simultaneous stimuli';

  @override
  String testTimeRemaining(int seconds) {
    return 'Time remaining: $seconds s';
  }

  @override
  String testTimeAndHits(int seconds, int hits) {
    return 'Time: $seconds s  |  Correct: $hits';
  }

  @override
  String get testPause => 'Pause';

  @override
  String get testResume => 'Resume';

  @override
  String get testStop => 'Stop';

  @override
  String get testPaused => 'Test Paused';

  @override
  String get testPauseHint => 'The test will resume exactly where you left off.';

  @override
  String get testStatRemaining => 'Remaining';

  @override
  String get testStatElapsed => 'Elapsed';

  @override
  String get testStatStimuli => 'Stimuli';

  @override
  String get countdownReady => 'Get ready!';

  @override
  String get resultsTitle => 'Test results';

  @override
  String get resultsLocTitle => 'Results - Localization';

  @override
  String get resultsCompleted => 'Test completed';

  @override
  String get resultsStopped => 'Test stopped';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsActualDuration => 'Actual duration';

  @override
  String get statsConfigDuration => 'Configured duration';

  @override
  String get statsStimuliShown => 'Stimuli shown';

  @override
  String get statsStimuliPerMinute => 'Stimuli/minute';

  @override
  String get accuracyTitle => 'Accuracy';

  @override
  String get accuracyCorrect => 'Correct';

  @override
  String get accuracyErrors => 'Errors';

  @override
  String get accuracyMissed => 'Missed';

  @override
  String get accuracyPercent => 'Accuracy %';

  @override
  String get reactionTitle => 'Reaction time';

  @override
  String get reactionAvg => 'Average';

  @override
  String get reactionBest => 'Best';

  @override
  String get reactionWorst => 'Worst';

  @override
  String get configUsedTitle => 'Configuration used';

  @override
  String get resultsRepeat => 'Repeat test';

  @override
  String get resultsHome => 'Back to menu';

  @override
  String get summaryKeySide => 'Side';

  @override
  String get summaryKeyStimulus => 'Stimulus';

  @override
  String get summaryKeyColor => 'Color';

  @override
  String get summaryKeySpeed => 'Speed';

  @override
  String get summaryKeyMovement => 'Movement';

  @override
  String get summaryKeyDistance => 'Distance';

  @override
  String get summaryKeySize => 'Size';

  @override
  String get summaryKeyDuration => 'Duration';

  @override
  String get summaryKeyFixation => 'Fixation';

  @override
  String get summaryKeyBackground => 'Background';

  @override
  String get summaryKeyMode => 'Mode';

  @override
  String get summaryKeyCenter => 'Center';

  @override
  String get summaryKeyFeedback => 'Feedback';

  @override
  String get summaryKeyDisappear => 'Disappearance';

  @override
  String get summaryKeySimultaneous => 'Simultaneous stimuli';

  @override
  String get summaryKeyInteraction => 'Interaction';

  @override
  String get summaryKeyVisualization => 'Visualization';

  @override
  String get summaryKeyDirection => 'Direction';

  @override
  String get summaryKeyRings => 'Rings';

  @override
  String get summaryKeyLettersPerRing => 'Letters/ring';

  @override
  String get summaryKeyRandomLetters => 'Random letters';

  @override
  String get summaryDistRandom => 'Random';

  @override
  String summarySizeRandom(String pct) {
    return '~$pct% (random)';
  }

  @override
  String get summaryDistractorAnimated => ' + Animated distractor';

  @override
  String get summaryDistractor => ' + Distractor';

  @override
  String get summaryCenterFixed => 'Fixed';

  @override
  String get summaryCenterChanging => 'Changing';

  @override
  String get summaryYes => 'Yes';

  @override
  String get summaryNo => 'No';

  @override
  String get testMacdonaldTitle => 'MacDonald Chart';

  @override
  String get testMacdonaldSubtitle => 'Train peripheral vision with ring letters.';

  @override
  String get configMacdonaldTitle => 'MacDonald Chart Test';

  @override
  String get macInteractionTitle => 'Interaction mode';

  @override
  String get macInteractionTouch => 'Touch letters';

  @override
  String get macInteractionTouchDesc => 'Touch each letter as you see it';

  @override
  String get macInteractionTimed => 'Timed reading';

  @override
  String get macInteractionTimedDesc => 'Read aloud with a timer';

  @override
  String get macInteractionSequential => 'Sequential reading';

  @override
  String get macInteractionSequentialDesc => 'The app highlights letters one by one, you read them';

  @override
  String get macInteractionFieldDetection => 'Field detection';

  @override
  String get macInteractionFieldDetectionDesc => 'Letters appear one at a time at random positions. Touch each letter before it disappears';

  @override
  String get macVisualizationTitle => 'Visualization mode';

  @override
  String get macVisualizationComplete => 'Complete';

  @override
  String get macVisualizationCompleteDesc => 'All letters visible from the start';

  @override
  String get macVisualizationProgressive => 'Progressive';

  @override
  String get macVisualizationProgressiveDesc => 'Letters appear one by one';

  @override
  String get macVisualizationByRings => 'By rings';

  @override
  String get macVisualizationByRingsDesc => 'Letters appear ring by ring';

  @override
  String get macDirectionTitle => 'Reading direction';

  @override
  String get macDirectionCenterOut => 'Center → Out';

  @override
  String get macDirectionOutCenter => 'Out → Center';

  @override
  String get macDirectionClockwise => 'Clockwise';

  @override
  String get macDirectionCounterClockwise => 'Counter-clockwise';

  @override
  String get macContentTitle => 'Content type';

  @override
  String get macContentLetters => 'Letters';

  @override
  String get macContentNumbers => 'Numbers';

  @override
  String get summaryKeyContent => 'Content';

  @override
  String get macRingsTitle => 'Number of rings';

  @override
  String get macLettersPerRingTitle => 'Letters per ring (first ring)';

  @override
  String get macRandomLetters => 'Random letters';

  @override
  String get macRandomLettersSubtitle => 'If disabled, uses the A-Z sequence';

  @override
  String get macRevealSpeedTitle => 'Reveal speed';

  @override
  String get resultsMacTitle => 'Results - MacDonald Chart';

  @override
  String get macStatsRingsCompleted => 'Rings completed';

  @override
  String get macStatsTimePerRing => 'Time per ring';

  @override
  String get macStatsLettersShown => 'Letters shown';

  @override
  String get macStatsAvgPerRing => 'Average per ring';

  @override
  String get presetMacStandardDesc => 'By rings, timed reading';

  @override
  String get presetMacEasyDesc => 'Touch letters, all visible, slow';

  @override
  String get presetMacAdvancedDesc => 'Sequential, progressive, fast';

  @override
  String get presetMacFieldDetectionDesc => 'Visual field detection, touch letters';

  @override
  String get macHitMapTitle => 'Hits map';

  @override
  String get macMissMapTitle => 'Misses map';

  @override
  String get macNextRing => 'Next ring';

  @override
  String macRingLabel(int number) {
    return 'Ring $number';
  }

  @override
  String get patientName => 'Patient name';

  @override
  String get patientNameHint => 'Enter the patient\'s name';

  @override
  String get menuHistory => 'History';

  @override
  String get historyTitle => 'Results history';

  @override
  String get historyEmpty => 'No saved results yet.';

  @override
  String get historyClearAll => 'Clear all';

  @override
  String get historyClearAllTitle => 'Delete all results';

  @override
  String get historyClearAllMessage => 'This will permanently delete all saved results. This action cannot be undone.';

  @override
  String get historyClearAllConfirm => 'Delete all';

  @override
  String get historyCancel => 'Cancel';

  @override
  String get historyDelete => 'Delete';

  @override
  String bulkSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get bulkDeselectAll => 'Deselect all';

  @override
  String get bulkSelectAll => 'Select all';

  @override
  String get bulkExportTitle => 'Export selected';

  @override
  String get bulkReportTitle => 'Bulk Report';

  @override
  String get historyDeleteTitle => 'Delete result';

  @override
  String get historyDeleteMessage => 'Are you sure you want to delete this result?';

  @override
  String get historyDetailTitle => 'Result details';

  @override
  String get historyTestPeripheral => 'Peripheral stimulation';

  @override
  String get historyTestLocalization => 'Peripheral localization';

  @override
  String get historyTestMacdonald => 'MacDonald Chart';

  @override
  String get historySearchHint => 'Search by patient or test...';

  @override
  String get historyNoResults => 'No results for this search.';

  @override
  String get historyUnnamedPatient => 'Unnamed';

  @override
  String historyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get historyGroupByPatient => 'By patient';

  @override
  String get historyOrderByDate => 'By date';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get themeLight => 'Light mode';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsAppName => 'Optoview';

  @override
  String get creditsDescription => 'This application has been developed with the help of the licensed optometrist expert in visual therapy\nEstefanía Rodríguez-Bobada Lillo.';

  @override
  String get creditsCompany => 'Company';

  @override
  String get creditsYear => 'Year';

  @override
  String get creditsVersion => 'Version';

  @override
  String get creditsBack => 'Back';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsStart => 'Start';

  @override
  String get showInstructions => 'Show instructions';

  @override
  String get showInstructionsSubtitle => 'Display explanatory text before starting the test';

  @override
  String get instructFixation => 'Keep your eyes on the central fixation point';

  @override
  String instructStimuliSide(String side) {
    return 'Stimuli will appear on: $side';
  }

  @override
  String instructStimuliType(String type) {
    return 'Stimulus type: $type';
  }

  @override
  String instructSpeed(String speed) {
    return 'Speed: $speed';
  }

  @override
  String instructDuration(int duration) {
    return 'Duration: $duration seconds';
  }

  @override
  String get instructLocTouchAll => 'Touch all stimuli that appear';

  @override
  String get instructLocMatchCenter => 'Touch only stimuli that match the center';

  @override
  String get instructLocSameColor => 'Touch only stimuli with the same color as the center';

  @override
  String get instructLocSameShape => 'Touch only stimuli with the same shape as the center';

  @override
  String get instructLocFeedback => 'You will see visual feedback when you touch (correct/error)';

  @override
  String instructLocSimultaneous(int count) {
    return '$count stimuli will appear at once';
  }

  @override
  String get instructMacTouch => 'Touch each letter in the order they appear';

  @override
  String get instructMacTimed => 'Read the letters aloud as fast as you can';

  @override
  String get instructMacSequential => 'Read each letter when it is highlighted on screen';

  @override
  String get instructMacFieldDetection => 'Touch each letter before it disappears. They will appear at random positions';

  @override
  String get instructMacVisComplete => 'All letters will be visible from the start';

  @override
  String get instructMacVisProgressive => 'Letters will appear one by one';

  @override
  String get instructMacVisByRings => 'Letters will appear ring by ring';

  @override
  String instructMacContent(String content) {
    return 'Content: $content';
  }

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportExcel => 'Excel';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportPatientSummary => 'Export summary';

  @override
  String get exportSelectPatient => 'Select a patient';

  @override
  String get exportReportTitle => 'OptoView Report';

  @override
  String exportReportGenerated(String date) {
    return 'Report generated on $date';
  }

  @override
  String get exportNoResults => 'No results to export';

  @override
  String exportPatientReport(String name) {
    return 'Patient summary: $name';
  }

  @override
  String get exportTestDate => 'Date';

  @override
  String get exportTestType => 'Test type';

  @override
  String get exportAccuracy => 'Accuracy';

  @override
  String get exportDuration => 'Duration';

  @override
  String get exportReactionTime => 'Reaction time';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupExportTooltip => 'Export all results as JSON';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupImportTooltip => 'Import results from JSON file';

  @override
  String backupExportSuccess(int count) {
    return 'Backup exported with $count results';
  }

  @override
  String backupImportSuccess(int count) {
    return '$count new results imported';
  }

  @override
  String get backupImportNone => 'No new results found to import';

  @override
  String get backupImportError => 'Error reading backup file';

  @override
  String get backupNoResults => 'No results to export';

  @override
  String get renameTitle => 'Rename patient';

  @override
  String get renameHint => 'New patient name';

  @override
  String get renameSave => 'Save';

  @override
  String get renameSuccess => 'Name updated';

  @override
  String get questionnaireMenuTitle => 'CVS-Q Questionnaire';

  @override
  String get questionnaireMenuSubtitle => 'Visual symptoms assessment';

  @override
  String get questionnaireFormTitle => 'CVS-Q Questionnaire';

  @override
  String get questionnaireCvsqSection => 'Visual symptoms (CVS-Q)';

  @override
  String get questionnaireFssSection => 'Fatigue and motivation — optional';

  @override
  String questionnaireAnsweredCount(int answered) {
    return '$answered/16 answered';
  }

  @override
  String get questionnaireScoreLabel => 'CVS-Q Score';

  @override
  String get questionnaireSaveButton => 'Save';

  @override
  String get questionnaireSavedSnack => 'Questionnaire saved';

  @override
  String get questionnairePatientLabel => 'Patient name';

  @override
  String get cvsqFreqHeader => 'Frequency';

  @override
  String get cvsqIntHeader => 'Intensity';

  @override
  String get cvsqFreqNever => 'Never';

  @override
  String get cvsqFreqOccasional => 'Occasionally';

  @override
  String get cvsqFreqHabitual => 'Habitually or always';

  @override
  String get cvsqIntModerate => 'Moderate';

  @override
  String get cvsqIntIntense => 'Intense';

  @override
  String get cvsqItem1 => 'Burning sensation';

  @override
  String get cvsqItem2 => 'Itching';

  @override
  String get cvsqItem3 => 'Foreign body sensation';

  @override
  String get cvsqItem4 => 'Tearing';

  @override
  String get cvsqItem5 => 'Excessive blinking';

  @override
  String get cvsqItem6 => 'Red eye';

  @override
  String get cvsqItem7 => 'Eye pain';

  @override
  String get cvsqItem8 => 'Heavy eyelids';

  @override
  String get cvsqItem9 => 'Dryness';

  @override
  String get cvsqItem10 => 'Blurred vision';

  @override
  String get cvsqItem11 => 'Double vision';

  @override
  String get cvsqItem12 => 'Difficulty focusing near';

  @override
  String get cvsqItem13 => 'Increased light sensitivity';

  @override
  String get cvsqItem14 => 'Colored halos around lights';

  @override
  String get cvsqItem15 => 'Feeling that vision has worsened';

  @override
  String get cvsqItem16 => 'Headache';

  @override
  String get fssItem1 => 'Fatigue level';

  @override
  String get fssItem2 => 'Motivation level';

  @override
  String get fssItem3 => 'Stress level';

  @override
  String get fssItem4 => 'Fatigue interferes with task performance';

  @override
  String get fssItem5 => 'Hours of sleep';

  @override
  String get fssAnchorAgree => 'Agree';

  @override
  String get fssAnchorDisagree => 'Disagree';

  @override
  String get historyTestQuestionnaire => 'Questionnaire';

  @override
  String questionnaireHistorySubtitle(int score) {
    return 'CVS-Q · Score: $score';
  }

  @override
  String get exportQuestionnaireTitle => 'CVS-Q Questionnaire';

  @override
  String get exportQuestionnaireBulkTitle => 'Questionnaires';

  @override
  String get exportItemNumber => '#';

  @override
  String get exportItemName => 'Item';

  @override
  String get exportFrequency => 'Frequency';

  @override
  String get exportIntensity => 'Intensity';

  @override
  String get exportScore => 'Score';

  @override
  String get exportValueScale => 'Value (1-7)';
}
