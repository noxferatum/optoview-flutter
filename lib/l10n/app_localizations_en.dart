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
  String get testPaused => 'TEST PAUSED';

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
}
