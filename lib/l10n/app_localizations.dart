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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @gameTitle.
  ///
  /// In en, this message translates to:
  /// **'STELLAR\nVORTEX'**
  String get gameTitle;

  /// No description provided for @gameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A DUAL-STICK SCI-FI SHOOTER'**
  String get gameSubtitle;

  /// No description provided for @launchMission.
  ///
  /// In en, this message translates to:
  /// **'LAUNCH MISSION'**
  String get launchMission;

  /// No description provided for @tacticalGuide.
  ///
  /// In en, this message translates to:
  /// **'TACTICAL GUIDE'**
  String get tacticalGuide;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'CREDITS'**
  String get credits;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @tacticalProtocol.
  ///
  /// In en, this message translates to:
  /// **'TACTICAL PROTOCOL'**
  String get tacticalProtocol;

  /// No description provided for @steerShipTitle.
  ///
  /// In en, this message translates to:
  /// **'STEER SHIP'**
  String get steerShipTitle;

  /// No description provided for @steerShipBody.
  ///
  /// In en, this message translates to:
  /// **'Use left screen joystick or keyboard [W, A, S, D] keys.'**
  String get steerShipBody;

  /// No description provided for @weaponSystemsTitle.
  ///
  /// In en, this message translates to:
  /// **'WEAPON SYSTEMS'**
  String get weaponSystemsTitle;

  /// No description provided for @weaponSystemsBody.
  ///
  /// In en, this message translates to:
  /// **'Drag right screen joystick to rotate and auto-shoot. Alternatively, point with mouse cursor and hold left-click, or use [Arrow Keys].'**
  String get weaponSystemsBody;

  /// No description provided for @fieldCoresTitle.
  ///
  /// In en, this message translates to:
  /// **'FIELD CORES'**
  String get fieldCoresTitle;

  /// No description provided for @fieldCoresBody.
  ///
  /// In en, this message translates to:
  /// **'Destroy meteors and elite ships to harvest upgrades:\n• Shield Packs (Batteries) restores hull shields.\n• Power Cores upgrades laser layout (up to Spread Shot).\n• Fire Rate Cores (Cogs) increases thrusters & laser speeds.'**
  String get fieldCoresBody;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'UNDERSTOOD'**
  String get understood;

  /// No description provided for @transmissionCredits.
  ///
  /// In en, this message translates to:
  /// **'TRANSMISSION: CREDITS'**
  String get transmissionCredits;

  /// No description provided for @assetCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'ASSET CREATOR'**
  String get assetCreatorTitle;

  /// No description provided for @assetCreatorBody.
  ///
  /// In en, this message translates to:
  /// **'All graphical game assets (spaceships, lasers, meteors, tilesets, & UI assets) and audio effects are created by Kenney.'**
  String get assetCreatorBody;

  /// No description provided for @kenneyAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'KENNEY ASSETS'**
  String get kenneyAssetsTitle;

  /// No description provided for @kenneyAssetsBody.
  ///
  /// In en, this message translates to:
  /// **'Kenney creates thousands of completely free, high-quality game assets (CC0 / Public Domain) to support the game development community. Discover more at www.kenney.nl.'**
  String get kenneyAssetsBody;

  /// No description provided for @transmissionTerminated.
  ///
  /// In en, this message translates to:
  /// **'TRANSMISSION TERMINATED'**
  String get transmissionTerminated;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM SPECIFICATIONS & CONFIGURATION'**
  String get settingsSubtitle;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'GAME LANGUAGE'**
  String get languageSelect;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'ENGLISH'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'SPANISH'**
  String get languageSpanish;

  /// No description provided for @saveAndClose.
  ///
  /// In en, this message translates to:
  /// **'SAVE & CLOSE'**
  String get saveAndClose;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get back;

  /// No description provided for @shipSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'SHIP SELECTION'**
  String get shipSelectionTitle;

  /// No description provided for @engageHyperdrive.
  ///
  /// In en, this message translates to:
  /// **'ENGAGE HYPERDRIVE'**
  String get engageHyperdrive;

  /// No description provided for @velocity.
  ///
  /// In en, this message translates to:
  /// **'VELOCITY'**
  String get velocity;

  /// No description provided for @armorHull.
  ///
  /// In en, this message translates to:
  /// **'ARMOR HULL'**
  String get armorHull;

  /// No description provided for @firePower.
  ///
  /// In en, this message translates to:
  /// **'FIRE POWER'**
  String get firePower;

  /// No description provided for @shd.
  ///
  /// In en, this message translates to:
  /// **'SHD'**
  String get shd;

  /// No description provided for @hull.
  ///
  /// In en, this message translates to:
  /// **'HULL'**
  String get hull;

  /// No description provided for @sector.
  ///
  /// In en, this message translates to:
  /// **'SECTOR'**
  String get sector;

  /// No description provided for @lives.
  ///
  /// In en, this message translates to:
  /// **'LIVES'**
  String get lives;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get score;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get high;

  /// No description provided for @keyboardControlsGuide.
  ///
  /// In en, this message translates to:
  /// **'CONTROLS: WASD to Move  |  Mouse Pointer to Aim + Hold Click to Shoot  |  Arrow Keys for Twin-Stick Shooting'**
  String get keyboardControlsGuide;

  /// No description provided for @transmissionPaused.
  ///
  /// In en, this message translates to:
  /// **'TRANSMISSION\nPAUSED'**
  String get transmissionPaused;

  /// No description provided for @tacticalAnalysisInProgress.
  ///
  /// In en, this message translates to:
  /// **'TACTICAL ANALYSIS IN PROGRESS'**
  String get tacticalAnalysisInProgress;

  /// No description provided for @resumeFlight.
  ///
  /// In en, this message translates to:
  /// **'RESUME FLIGHT'**
  String get resumeFlight;

  /// No description provided for @restartMission.
  ///
  /// In en, this message translates to:
  /// **'RESTART MISSION'**
  String get restartMission;

  /// No description provided for @abortMission.
  ///
  /// In en, this message translates to:
  /// **'ABORT MISSION'**
  String get abortMission;

  /// No description provided for @shipDestroyed.
  ///
  /// In en, this message translates to:
  /// **'SHIP DESTROYED'**
  String get shipDestroyed;

  /// No description provided for @telemetrySynchronizationTerminated.
  ///
  /// In en, this message translates to:
  /// **'TELEMETRY SYNCHRONIZATION TERMINATED'**
  String get telemetrySynchronizationTerminated;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'FINAL SCORE'**
  String get finalScore;

  /// No description provided for @sectorsCleared.
  ///
  /// In en, this message translates to:
  /// **'SECTORS CLEARED: {count}'**
  String sectorsCleared(int count);

  /// No description provided for @newSectorRecord.
  ///
  /// In en, this message translates to:
  /// **'NEW SECTOR RECORD!'**
  String get newSectorRecord;

  /// No description provided for @recordHolder.
  ///
  /// In en, this message translates to:
  /// **'RECORD HOLDER: {highScoreStr}'**
  String recordHolder(String highScoreStr);

  /// No description provided for @redeployShip.
  ///
  /// In en, this message translates to:
  /// **'REDEPLOY SHIP'**
  String get redeployShip;

  /// No description provided for @returnToHangar.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO HANGAR'**
  String get returnToHangar;

  /// No description provided for @exitToStation.
  ///
  /// In en, this message translates to:
  /// **'EXIT TO STATION'**
  String get exitToStation;

  /// No description provided for @vanguardName.
  ///
  /// In en, this message translates to:
  /// **'Vanguard'**
  String get vanguardName;

  /// No description provided for @reaperName.
  ///
  /// In en, this message translates to:
  /// **'Reaper'**
  String get reaperName;

  /// No description provided for @leviathanName.
  ///
  /// In en, this message translates to:
  /// **'Leviathan'**
  String get leviathanName;

  /// No description provided for @vanguardDescription.
  ///
  /// In en, this message translates to:
  /// **'Balanced interstellar fighter. Equipped with standard high-velocity plasma lasers.'**
  String get vanguardDescription;

  /// No description provided for @reaperDescription.
  ///
  /// In en, this message translates to:
  /// **'Fast interceptor. Rapid fire rate but lower structural integrity. Dual pulse canons.'**
  String get reaperDescription;

  /// No description provided for @leviathanDescription.
  ///
  /// In en, this message translates to:
  /// **'Heavy gunship. Extremely durable, fires high-damage heavy spread projectiles.'**
  String get leviathanDescription;

  /// No description provided for @customGameConfig.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM CONFIGURATION'**
  String get customGameConfig;

  /// No description provided for @customGameConfigSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FINE-TUNE SHIP SYSTEMS & THREAT LEVELS'**
  String get customGameConfigSubtitle;

  /// No description provided for @customConfigButton.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM GAME SETTINGS'**
  String get customConfigButton;

  /// No description provided for @playerDamage.
  ///
  /// In en, this message translates to:
  /// **'Player Weapon Damage'**
  String get playerDamage;

  /// No description provided for @playerFireSpeed.
  ///
  /// In en, this message translates to:
  /// **'Player Laser Speed'**
  String get playerFireSpeed;

  /// No description provided for @enemyHealth.
  ///
  /// In en, this message translates to:
  /// **'Enemy & Meteor Durability'**
  String get enemyHealth;

  /// No description provided for @enemySpeed.
  ///
  /// In en, this message translates to:
  /// **'Enemy Fleet Speed'**
  String get enemySpeed;

  /// No description provided for @enemySpawnRate.
  ///
  /// In en, this message translates to:
  /// **'Enemy Spawn Density'**
  String get enemySpawnRate;

  /// No description provided for @meteorSpawnRate.
  ///
  /// In en, this message translates to:
  /// **'Meteor Spawn Density'**
  String get meteorSpawnRate;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'RESET ALL TO DEFAULT'**
  String get resetToDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
