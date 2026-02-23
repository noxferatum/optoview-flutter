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
