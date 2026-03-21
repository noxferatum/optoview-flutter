import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OptoView'**
  String get appTitle;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'OptoViewApp - Menu'**
  String get menuTitle;

  /// No description provided for @menuStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get menuStart;

  /// No description provided for @menuCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get menuCredits;

  /// No description provided for @testMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise'**
  String get testMenuTitle;

  /// No description provided for @testPeripheralTitle.
  ///
  /// In en, this message translates to:
  /// **'Peripheral stimulation'**
  String get testPeripheralTitle;

  /// No description provided for @testPeripheralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train dynamic peripheral perception.'**
  String get testPeripheralSubtitle;

  /// No description provided for @testLocalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Peripheral localization'**
  String get testLocalizationTitle;

  /// No description provided for @testLocalizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train peripheral localization.'**
  String get testLocalizationSubtitle;

  /// No description provided for @testComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'More coming soon'**
  String get testComingSoonTitle;

  /// No description provided for @testComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New evaluation protocols.'**
  String get testComingSoonSubtitle;

  /// No description provided for @testComingSoonSnackbar.
  ///
  /// In en, this message translates to:
  /// **'We are working on more specialized tests.'**
  String get testComingSoonSnackbar;

  /// No description provided for @configPeripheralTitle.
  ///
  /// In en, this message translates to:
  /// **'Peripheral stimulation test'**
  String get configPeripheralTitle;

  /// No description provided for @configLocalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Peripheral localization test'**
  String get configLocalizationTitle;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get startTest;

  /// No description provided for @presetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetsTitle;

  /// No description provided for @presetsHint.
  ///
  /// In en, this message translates to:
  /// **'Select a preset or customize each option below.'**
  String get presetsHint;

  /// No description provided for @presetStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get presetStandard;

  /// No description provided for @presetStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced configuration for general use'**
  String get presetStandardDesc;

  /// No description provided for @presetEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get presetEasy;

  /// No description provided for @presetEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'Large and slow stimuli, ideal for beginners'**
  String get presetEasyDesc;

  /// No description provided for @presetAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get presetAdvanced;

  /// No description provided for @presetAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast, small stimuli with distractors'**
  String get presetAdvancedDesc;

  /// No description provided for @presetLocStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Match center, medium speed'**
  String get presetLocStandardDesc;

  /// No description provided for @presetLocEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'Touch all, slow, with feedback'**
  String get presetLocEasyDesc;

  /// No description provided for @presetLocAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Same shape, fast, no feedback, 3 stimuli'**
  String get presetLocAdvancedDesc;

  /// No description provided for @sideTitle.
  ///
  /// In en, this message translates to:
  /// **'Stimulation side'**
  String get sideTitle;

  /// No description provided for @sideLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get sideLeft;

  /// No description provided for @sideRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get sideRight;

  /// No description provided for @sideTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get sideTop;

  /// No description provided for @sideBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get sideBottom;

  /// No description provided for @sideBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get sideBoth;

  /// No description provided for @sideRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get sideRandom;

  /// No description provided for @sideDescLeft.
  ///
  /// In en, this message translates to:
  /// **'Stimuli will appear only on the left side of the screen.'**
  String get sideDescLeft;

  /// No description provided for @sideDescRight.
  ///
  /// In en, this message translates to:
  /// **'Stimuli will appear only on the right side of the screen.'**
  String get sideDescRight;

  /// No description provided for @sideDescTop.
  ///
  /// In en, this message translates to:
  /// **'Stimuli will appear only on the top.'**
  String get sideDescTop;

  /// No description provided for @sideDescBottom.
  ///
  /// In en, this message translates to:
  /// **'Stimuli will appear only on the bottom.'**
  String get sideDescBottom;

  /// No description provided for @sideDescBoth.
  ///
  /// In en, this message translates to:
  /// **'Stimuli can appear on both sides.'**
  String get sideDescBoth;

  /// No description provided for @sideDescRandom.
  ///
  /// In en, this message translates to:
  /// **'The stimuli appearance side will be random each cycle.'**
  String get sideDescRandom;

  /// No description provided for @symbolTitle.
  ///
  /// In en, this message translates to:
  /// **'Stimulus type'**
  String get symbolTitle;

  /// No description provided for @symbolLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get symbolLetters;

  /// No description provided for @symbolNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get symbolNumbers;

  /// No description provided for @symbolShapes.
  ///
  /// In en, this message translates to:
  /// **'Shapes'**
  String get symbolShapes;

  /// No description provided for @symbolFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Shape (optional)'**
  String get symbolFormTitle;

  /// No description provided for @symbolFormRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get symbolFormRandom;

  /// No description provided for @formaCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get formaCircle;

  /// No description provided for @formaSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get formaSquare;

  /// No description provided for @formaHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get formaHeart;

  /// No description provided for @formaTriangle.
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get formaTriangle;

  /// No description provided for @formaClover.
  ///
  /// In en, this message translates to:
  /// **'Clover'**
  String get formaClover;

  /// No description provided for @colorTitle.
  ///
  /// In en, this message translates to:
  /// **'Stimulus color'**
  String get colorTitle;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get colorRandom;

  /// No description provided for @speedTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedTitle;

  /// No description provided for @speedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// No description provided for @speedMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get speedMedium;

  /// No description provided for @speedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// No description provided for @movementTitle.
  ///
  /// In en, this message translates to:
  /// **'Stimulus movement'**
  String get movementTitle;

  /// No description provided for @movementFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get movementFixed;

  /// No description provided for @movementHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get movementHorizontal;

  /// No description provided for @movementVertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get movementVertical;

  /// No description provided for @movementRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get movementRandom;

  /// No description provided for @movementDescFixed.
  ///
  /// In en, this message translates to:
  /// **'The stimulus remains static in its position.'**
  String get movementDescFixed;

  /// No description provided for @movementDescHorizontal.
  ///
  /// In en, this message translates to:
  /// **'The stimulus slides from left to right or vice versa.'**
  String get movementDescHorizontal;

  /// No description provided for @movementDescVertical.
  ///
  /// In en, this message translates to:
  /// **'The stimulus slides from top to bottom or vice versa.'**
  String get movementDescVertical;

  /// No description provided for @movementDescRandom.
  ///
  /// In en, this message translates to:
  /// **'The stimulus randomly alternates between horizontal and vertical displacement.'**
  String get movementDescRandom;

  /// No description provided for @distanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Distance to center'**
  String get distanceTitle;

  /// No description provided for @distanceRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get distanceRandom;

  /// No description provided for @distanceRandomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Randomly changes the stimulus distance'**
  String get distanceRandomSubtitle;

  /// No description provided for @distanceFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get distanceFixed;

  /// No description provided for @distanceCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current distance: {pct}%'**
  String distanceCurrent(String pct);

  /// No description provided for @durationTitle.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get durationTitle;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String durationLabel(int value);

  /// No description provided for @sizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Size (%)'**
  String get sizeTitle;

  /// No description provided for @sizeRandomToggle.
  ///
  /// In en, this message translates to:
  /// **'Vary size randomly'**
  String get sizeRandomToggle;

  /// No description provided for @sizeRandomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, each stimulus will adjust its size around the configured value.'**
  String get sizeRandomSubtitle;

  /// No description provided for @fixationTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixation point'**
  String get fixationTitle;

  /// No description provided for @fixationFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get fixationFace;

  /// No description provided for @fixationEye.
  ///
  /// In en, this message translates to:
  /// **'Eye'**
  String get fixationEye;

  /// No description provided for @fixationDot.
  ///
  /// In en, this message translates to:
  /// **'Dot'**
  String get fixationDot;

  /// No description provided for @fixationClover.
  ///
  /// In en, this message translates to:
  /// **'Clover'**
  String get fixationClover;

  /// No description provided for @fixationCross.
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get fixationCross;

  /// No description provided for @backgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Background & distractor'**
  String get backgroundTitle;

  /// No description provided for @backgroundLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get backgroundLight;

  /// No description provided for @backgroundDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get backgroundDark;

  /// No description provided for @backgroundBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get backgroundBlue;

  /// No description provided for @backgroundDistractor.
  ///
  /// In en, this message translates to:
  /// **'Distractor background'**
  String get backgroundDistractor;

  /// No description provided for @backgroundDistractorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds a soft low-intensity pattern.'**
  String get backgroundDistractorSubtitle;

  /// No description provided for @backgroundAnimate.
  ///
  /// In en, this message translates to:
  /// **'Animate distractor'**
  String get backgroundAnimate;

  /// No description provided for @backgroundAnimateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enables subtle pattern movement to increase visual difficulty.'**
  String get backgroundAnimateSubtitle;

  /// No description provided for @locModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Localization mode'**
  String get locModeTitle;

  /// No description provided for @locModeTouchAll.
  ///
  /// In en, this message translates to:
  /// **'Touch all'**
  String get locModeTouchAll;

  /// No description provided for @locModeMatchCenter.
  ///
  /// In en, this message translates to:
  /// **'Match center'**
  String get locModeMatchCenter;

  /// No description provided for @locModeSameColor.
  ///
  /// In en, this message translates to:
  /// **'Same color'**
  String get locModeSameColor;

  /// No description provided for @locModeSameShape.
  ///
  /// In en, this message translates to:
  /// **'Same shape'**
  String get locModeSameShape;

  /// No description provided for @locModeTouchAllDesc.
  ///
  /// In en, this message translates to:
  /// **'Touch all stimuli that appear'**
  String get locModeTouchAllDesc;

  /// No description provided for @locModeMatchCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Only touch those matching the center'**
  String get locModeMatchCenterDesc;

  /// No description provided for @locModeSameColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Only touch those with the same color as the center'**
  String get locModeSameColorDesc;

  /// No description provided for @locModeSameShapeDesc.
  ///
  /// In en, this message translates to:
  /// **'Only touch those with the same shape as the center'**
  String get locModeSameShapeDesc;

  /// No description provided for @locInteractionTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction options'**
  String get locInteractionTitle;

  /// No description provided for @locCenterFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed center'**
  String get locCenterFixed;

  /// No description provided for @locCenterFixedOn.
  ///
  /// In en, this message translates to:
  /// **'The central stimulus does not change during the test'**
  String get locCenterFixedOn;

  /// No description provided for @locCenterFixedOff.
  ///
  /// In en, this message translates to:
  /// **'The central stimulus changes each cycle'**
  String get locCenterFixedOff;

  /// No description provided for @locFeedback.
  ///
  /// In en, this message translates to:
  /// **'Visual feedback'**
  String get locFeedback;

  /// No description provided for @locFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show visual indication on touch (correct/error)'**
  String get locFeedbackSubtitle;

  /// No description provided for @locDisappearTitle.
  ///
  /// In en, this message translates to:
  /// **'Stimulus disappearance'**
  String get locDisappearTitle;

  /// No description provided for @locDisappearByTime.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get locDisappearByTime;

  /// No description provided for @locDisappearWaitTouch.
  ///
  /// In en, this message translates to:
  /// **'Wait for touch'**
  String get locDisappearWaitTouch;

  /// No description provided for @locSimultaneousTitle.
  ///
  /// In en, this message translates to:
  /// **'Simultaneous stimuli'**
  String get locSimultaneousTitle;

  /// No description provided for @testTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {seconds} s'**
  String testTimeRemaining(int seconds);

  /// No description provided for @testTimeAndHits.
  ///
  /// In en, this message translates to:
  /// **'Time: {seconds} s  |  Correct: {hits}'**
  String testTimeAndHits(int seconds, int hits);

  /// No description provided for @testPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get testPause;

  /// No description provided for @testResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get testResume;

  /// No description provided for @testStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get testStop;

  /// No description provided for @testPaused.
  ///
  /// In en, this message translates to:
  /// **'TEST PAUSED'**
  String get testPaused;

  /// No description provided for @countdownReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready!'**
  String get countdownReady;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Test results'**
  String get resultsTitle;

  /// No description provided for @resultsLocTitle.
  ///
  /// In en, this message translates to:
  /// **'Results - Localization'**
  String get resultsLocTitle;

  /// No description provided for @resultsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test completed'**
  String get resultsCompleted;

  /// No description provided for @resultsStopped.
  ///
  /// In en, this message translates to:
  /// **'Test stopped'**
  String get resultsStopped;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsActualDuration.
  ///
  /// In en, this message translates to:
  /// **'Actual duration'**
  String get statsActualDuration;

  /// No description provided for @statsConfigDuration.
  ///
  /// In en, this message translates to:
  /// **'Configured duration'**
  String get statsConfigDuration;

  /// No description provided for @statsStimuliShown.
  ///
  /// In en, this message translates to:
  /// **'Stimuli shown'**
  String get statsStimuliShown;

  /// No description provided for @statsStimuliPerMinute.
  ///
  /// In en, this message translates to:
  /// **'Stimuli/minute'**
  String get statsStimuliPerMinute;

  /// No description provided for @accuracyTitle.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyTitle;

  /// No description provided for @accuracyCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get accuracyCorrect;

  /// No description provided for @accuracyErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get accuracyErrors;

  /// No description provided for @accuracyMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get accuracyMissed;

  /// No description provided for @accuracyPercent.
  ///
  /// In en, this message translates to:
  /// **'Accuracy %'**
  String get accuracyPercent;

  /// No description provided for @reactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reaction time'**
  String get reactionTitle;

  /// No description provided for @reactionAvg.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get reactionAvg;

  /// No description provided for @reactionBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get reactionBest;

  /// No description provided for @reactionWorst.
  ///
  /// In en, this message translates to:
  /// **'Worst'**
  String get reactionWorst;

  /// No description provided for @configUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration used'**
  String get configUsedTitle;

  /// No description provided for @resultsRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat test'**
  String get resultsRepeat;

  /// No description provided for @resultsHome.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get resultsHome;

  /// No description provided for @summaryKeySide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get summaryKeySide;

  /// No description provided for @summaryKeyStimulus.
  ///
  /// In en, this message translates to:
  /// **'Stimulus'**
  String get summaryKeyStimulus;

  /// No description provided for @summaryKeyColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get summaryKeyColor;

  /// No description provided for @summaryKeySpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get summaryKeySpeed;

  /// No description provided for @summaryKeyMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get summaryKeyMovement;

  /// No description provided for @summaryKeyDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get summaryKeyDistance;

  /// No description provided for @summaryKeySize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get summaryKeySize;

  /// No description provided for @summaryKeyDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get summaryKeyDuration;

  /// No description provided for @summaryKeyFixation.
  ///
  /// In en, this message translates to:
  /// **'Fixation'**
  String get summaryKeyFixation;

  /// No description provided for @summaryKeyBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get summaryKeyBackground;

  /// No description provided for @summaryKeyMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get summaryKeyMode;

  /// No description provided for @summaryKeyCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get summaryKeyCenter;

  /// No description provided for @summaryKeyFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get summaryKeyFeedback;

  /// No description provided for @summaryKeyDisappear.
  ///
  /// In en, this message translates to:
  /// **'Disappearance'**
  String get summaryKeyDisappear;

  /// No description provided for @summaryKeySimultaneous.
  ///
  /// In en, this message translates to:
  /// **'Simultaneous stimuli'**
  String get summaryKeySimultaneous;

  /// No description provided for @summaryKeyInteraction.
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get summaryKeyInteraction;

  /// No description provided for @summaryKeyVisualization.
  ///
  /// In en, this message translates to:
  /// **'Visualization'**
  String get summaryKeyVisualization;

  /// No description provided for @summaryKeyDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get summaryKeyDirection;

  /// No description provided for @summaryKeyRings.
  ///
  /// In en, this message translates to:
  /// **'Rings'**
  String get summaryKeyRings;

  /// No description provided for @summaryKeyLettersPerRing.
  ///
  /// In en, this message translates to:
  /// **'Letters/ring'**
  String get summaryKeyLettersPerRing;

  /// No description provided for @summaryKeyRandomLetters.
  ///
  /// In en, this message translates to:
  /// **'Random letters'**
  String get summaryKeyRandomLetters;

  /// No description provided for @summaryDistRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get summaryDistRandom;

  /// No description provided for @summarySizeRandom.
  ///
  /// In en, this message translates to:
  /// **'~{pct}% (random)'**
  String summarySizeRandom(String pct);

  /// No description provided for @summaryDistractorAnimated.
  ///
  /// In en, this message translates to:
  /// **' + Animated distractor'**
  String get summaryDistractorAnimated;

  /// No description provided for @summaryDistractor.
  ///
  /// In en, this message translates to:
  /// **' + Distractor'**
  String get summaryDistractor;

  /// No description provided for @summaryCenterFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get summaryCenterFixed;

  /// No description provided for @summaryCenterChanging.
  ///
  /// In en, this message translates to:
  /// **'Changing'**
  String get summaryCenterChanging;

  /// No description provided for @summaryYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get summaryYes;

  /// No description provided for @summaryNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get summaryNo;

  /// No description provided for @testMacdonaldTitle.
  ///
  /// In en, this message translates to:
  /// **'MacDonald Chart'**
  String get testMacdonaldTitle;

  /// No description provided for @testMacdonaldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train peripheral vision with ring letters.'**
  String get testMacdonaldSubtitle;

  /// No description provided for @configMacdonaldTitle.
  ///
  /// In en, this message translates to:
  /// **'MacDonald Chart Test'**
  String get configMacdonaldTitle;

  /// No description provided for @macInteractionTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction mode'**
  String get macInteractionTitle;

  /// No description provided for @macInteractionTouch.
  ///
  /// In en, this message translates to:
  /// **'Touch letters'**
  String get macInteractionTouch;

  /// No description provided for @macInteractionTouchDesc.
  ///
  /// In en, this message translates to:
  /// **'Touch each letter as you see it'**
  String get macInteractionTouchDesc;

  /// No description provided for @macInteractionTimed.
  ///
  /// In en, this message translates to:
  /// **'Timed reading'**
  String get macInteractionTimed;

  /// No description provided for @macInteractionTimedDesc.
  ///
  /// In en, this message translates to:
  /// **'Read aloud with a timer'**
  String get macInteractionTimedDesc;

  /// No description provided for @macInteractionSequential.
  ///
  /// In en, this message translates to:
  /// **'Sequential reading'**
  String get macInteractionSequential;

  /// No description provided for @macInteractionSequentialDesc.
  ///
  /// In en, this message translates to:
  /// **'The app highlights letters one by one, you read them'**
  String get macInteractionSequentialDesc;

  /// No description provided for @macInteractionFieldDetection.
  ///
  /// In en, this message translates to:
  /// **'Field detection'**
  String get macInteractionFieldDetection;

  /// No description provided for @macInteractionFieldDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Letters appear one at a time at random positions. Touch each letter before it disappears'**
  String get macInteractionFieldDetectionDesc;

  /// No description provided for @macVisualizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Visualization mode'**
  String get macVisualizationTitle;

  /// No description provided for @macVisualizationComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get macVisualizationComplete;

  /// No description provided for @macVisualizationCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'All letters visible from the start'**
  String get macVisualizationCompleteDesc;

  /// No description provided for @macVisualizationProgressive.
  ///
  /// In en, this message translates to:
  /// **'Progressive'**
  String get macVisualizationProgressive;

  /// No description provided for @macVisualizationProgressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Letters appear one by one'**
  String get macVisualizationProgressiveDesc;

  /// No description provided for @macVisualizationByRings.
  ///
  /// In en, this message translates to:
  /// **'By rings'**
  String get macVisualizationByRings;

  /// No description provided for @macVisualizationByRingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Letters appear ring by ring'**
  String get macVisualizationByRingsDesc;

  /// No description provided for @macDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading direction'**
  String get macDirectionTitle;

  /// No description provided for @macDirectionCenterOut.
  ///
  /// In en, this message translates to:
  /// **'Center → Out'**
  String get macDirectionCenterOut;

  /// No description provided for @macDirectionOutCenter.
  ///
  /// In en, this message translates to:
  /// **'Out → Center'**
  String get macDirectionOutCenter;

  /// No description provided for @macDirectionClockwise.
  ///
  /// In en, this message translates to:
  /// **'Clockwise'**
  String get macDirectionClockwise;

  /// No description provided for @macDirectionCounterClockwise.
  ///
  /// In en, this message translates to:
  /// **'Counter-clockwise'**
  String get macDirectionCounterClockwise;

  /// No description provided for @macContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Content type'**
  String get macContentTitle;

  /// No description provided for @macContentLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get macContentLetters;

  /// No description provided for @macContentNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get macContentNumbers;

  /// No description provided for @summaryKeyContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get summaryKeyContent;

  /// No description provided for @macRingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Number of rings'**
  String get macRingsTitle;

  /// No description provided for @macLettersPerRingTitle.
  ///
  /// In en, this message translates to:
  /// **'Letters per ring (first ring)'**
  String get macLettersPerRingTitle;

  /// No description provided for @macRandomLetters.
  ///
  /// In en, this message translates to:
  /// **'Random letters'**
  String get macRandomLetters;

  /// No description provided for @macRandomLettersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If disabled, uses the A-Z sequence'**
  String get macRandomLettersSubtitle;

  /// No description provided for @macRevealSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reveal speed'**
  String get macRevealSpeedTitle;

  /// No description provided for @resultsMacTitle.
  ///
  /// In en, this message translates to:
  /// **'Results - MacDonald Chart'**
  String get resultsMacTitle;

  /// No description provided for @macStatsRingsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Rings completed'**
  String get macStatsRingsCompleted;

  /// No description provided for @macStatsTimePerRing.
  ///
  /// In en, this message translates to:
  /// **'Time per ring'**
  String get macStatsTimePerRing;

  /// No description provided for @macStatsLettersShown.
  ///
  /// In en, this message translates to:
  /// **'Letters shown'**
  String get macStatsLettersShown;

  /// No description provided for @macStatsAvgPerRing.
  ///
  /// In en, this message translates to:
  /// **'Average per ring'**
  String get macStatsAvgPerRing;

  /// No description provided for @presetMacStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'By rings, timed reading'**
  String get presetMacStandardDesc;

  /// No description provided for @presetMacEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'Touch letters, all visible, slow'**
  String get presetMacEasyDesc;

  /// No description provided for @presetMacAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Sequential, progressive, fast'**
  String get presetMacAdvancedDesc;

  /// No description provided for @presetMacFieldDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Visual field detection, touch letters'**
  String get presetMacFieldDetectionDesc;

  /// No description provided for @macHitMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Hits map'**
  String get macHitMapTitle;

  /// No description provided for @macMissMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Misses map'**
  String get macMissMapTitle;

  /// No description provided for @macNextRing.
  ///
  /// In en, this message translates to:
  /// **'Next ring'**
  String get macNextRing;

  /// No description provided for @macRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Ring {number}'**
  String macRingLabel(int number);

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientName;

  /// No description provided for @patientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the patient\'s name'**
  String get patientNameHint;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menuHistory;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Results history'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved results yet.'**
  String get historyEmpty;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get historyClearAll;

  /// No description provided for @historyClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all results'**
  String get historyClearAllTitle;

  /// No description provided for @historyClearAllMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all saved results. This action cannot be undone.'**
  String get historyClearAllMessage;

  /// No description provided for @historyClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get historyClearAllConfirm;

  /// No description provided for @historyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get historyCancel;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete result'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this result?'**
  String get historyDeleteMessage;

  /// No description provided for @historyDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Result details'**
  String get historyDetailTitle;

  /// No description provided for @historyTestPeripheral.
  ///
  /// In en, this message translates to:
  /// **'Peripheral stimulation'**
  String get historyTestPeripheral;

  /// No description provided for @historyTestLocalization.
  ///
  /// In en, this message translates to:
  /// **'Peripheral localization'**
  String get historyTestLocalization;

  /// No description provided for @historyTestMacdonald.
  ///
  /// In en, this message translates to:
  /// **'MacDonald Chart'**
  String get historyTestMacdonald;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by patient or test...'**
  String get historySearchHint;

  /// No description provided for @historyNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for this search.'**
  String get historyNoResults;

  /// No description provided for @historyUnnamedPatient.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get historyUnnamedPatient;

  /// No description provided for @historyResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String historyResultCount(int count);

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsAppName.
  ///
  /// In en, this message translates to:
  /// **'Optoview'**
  String get creditsAppName;

  /// No description provided for @creditsDescription.
  ///
  /// In en, this message translates to:
  /// **'This application has been developed with the help of the licensed optometrist expert in visual therapy\nEstefanía Rodríguez-Bobada Lillo.'**
  String get creditsDescription;

  /// No description provided for @creditsCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get creditsCompany;

  /// No description provided for @creditsYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get creditsYear;

  /// No description provided for @creditsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get creditsVersion;

  /// No description provided for @creditsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get creditsBack;

  /// No description provided for @instructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// No description provided for @instructionsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get instructionsStart;

  /// No description provided for @showInstructions.
  ///
  /// In en, this message translates to:
  /// **'Show instructions'**
  String get showInstructions;

  /// No description provided for @showInstructionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display explanatory text before starting the test'**
  String get showInstructionsSubtitle;

  /// No description provided for @instructFixation.
  ///
  /// In en, this message translates to:
  /// **'Keep your eyes on the central fixation point'**
  String get instructFixation;

  /// No description provided for @instructStimuliSide.
  ///
  /// In en, this message translates to:
  /// **'Stimuli will appear on: {side}'**
  String instructStimuliSide(String side);

  /// No description provided for @instructStimuliType.
  ///
  /// In en, this message translates to:
  /// **'Stimulus type: {type}'**
  String instructStimuliType(String type);

  /// No description provided for @instructSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed}'**
  String instructSpeed(String speed);

  /// No description provided for @instructDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration} seconds'**
  String instructDuration(int duration);

  /// No description provided for @instructLocTouchAll.
  ///
  /// In en, this message translates to:
  /// **'Touch all stimuli that appear'**
  String get instructLocTouchAll;

  /// No description provided for @instructLocMatchCenter.
  ///
  /// In en, this message translates to:
  /// **'Touch only stimuli that match the center'**
  String get instructLocMatchCenter;

  /// No description provided for @instructLocSameColor.
  ///
  /// In en, this message translates to:
  /// **'Touch only stimuli with the same color as the center'**
  String get instructLocSameColor;

  /// No description provided for @instructLocSameShape.
  ///
  /// In en, this message translates to:
  /// **'Touch only stimuli with the same shape as the center'**
  String get instructLocSameShape;

  /// No description provided for @instructLocFeedback.
  ///
  /// In en, this message translates to:
  /// **'You will see visual feedback when you touch (correct/error)'**
  String get instructLocFeedback;

  /// No description provided for @instructLocSimultaneous.
  ///
  /// In en, this message translates to:
  /// **'{count} stimuli will appear at once'**
  String instructLocSimultaneous(int count);

  /// No description provided for @instructMacTouch.
  ///
  /// In en, this message translates to:
  /// **'Touch each letter in the order they appear'**
  String get instructMacTouch;

  /// No description provided for @instructMacTimed.
  ///
  /// In en, this message translates to:
  /// **'Read the letters aloud as fast as you can'**
  String get instructMacTimed;

  /// No description provided for @instructMacSequential.
  ///
  /// In en, this message translates to:
  /// **'Read each letter when it is highlighted on screen'**
  String get instructMacSequential;

  /// No description provided for @instructMacFieldDetection.
  ///
  /// In en, this message translates to:
  /// **'Touch each letter before it disappears. They will appear at random positions'**
  String get instructMacFieldDetection;

  /// No description provided for @instructMacVisComplete.
  ///
  /// In en, this message translates to:
  /// **'All letters will be visible from the start'**
  String get instructMacVisComplete;

  /// No description provided for @instructMacVisProgressive.
  ///
  /// In en, this message translates to:
  /// **'Letters will appear one by one'**
  String get instructMacVisProgressive;

  /// No description provided for @instructMacVisByRings.
  ///
  /// In en, this message translates to:
  /// **'Letters will appear ring by ring'**
  String get instructMacVisByRings;

  /// No description provided for @instructMacContent.
  ///
  /// In en, this message translates to:
  /// **'Content: {content}'**
  String instructMacContent(String content);

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get exportPdf;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get exportExcel;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsv;

  /// No description provided for @exportPatientSummary.
  ///
  /// In en, this message translates to:
  /// **'Export summary'**
  String get exportPatientSummary;

  /// No description provided for @exportSelectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select a patient'**
  String get exportSelectPatient;

  /// No description provided for @exportReportTitle.
  ///
  /// In en, this message translates to:
  /// **'OptoView Report'**
  String get exportReportTitle;

  /// No description provided for @exportReportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated on {date}'**
  String exportReportGenerated(String date);

  /// No description provided for @exportNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results to export'**
  String get exportNoResults;

  /// No description provided for @exportPatientReport.
  ///
  /// In en, this message translates to:
  /// **'Patient summary: {name}'**
  String exportPatientReport(String name);

  /// No description provided for @exportTestDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get exportTestDate;

  /// No description provided for @exportTestType.
  ///
  /// In en, this message translates to:
  /// **'Test type'**
  String get exportTestType;

  /// No description provided for @exportAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get exportAccuracy;

  /// No description provided for @exportDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get exportDuration;

  /// No description provided for @exportReactionTime.
  ///
  /// In en, this message translates to:
  /// **'Reaction time'**
  String get exportReactionTime;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExport;

  /// No description provided for @backupExportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export all results as JSON'**
  String get backupExportTooltip;

  /// No description provided for @backupImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImport;

  /// No description provided for @backupImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import results from JSON file'**
  String get backupImportTooltip;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup exported with {count} results'**
  String backupExportSuccess(int count);

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} new results imported'**
  String backupImportSuccess(int count);

  /// No description provided for @backupImportNone.
  ///
  /// In en, this message translates to:
  /// **'No new results found to import'**
  String get backupImportNone;

  /// No description provided for @backupImportError.
  ///
  /// In en, this message translates to:
  /// **'Error reading backup file'**
  String get backupImportError;

  /// No description provided for @backupNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results to export'**
  String get backupNoResults;

  /// No description provided for @renameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename patient'**
  String get renameTitle;

  /// No description provided for @renameHint.
  ///
  /// In en, this message translates to:
  /// **'New patient name'**
  String get renameHint;

  /// No description provided for @renameSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get renameSave;

  /// No description provided for @renameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get renameSuccess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
