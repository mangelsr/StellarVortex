// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameTitle => 'STELLAR\nVORTEX';

  @override
  String get gameSubtitle => 'A DUAL-STICK SCI-FI SHOOTER';

  @override
  String get launchMission => 'LAUNCH MISSION';

  @override
  String get tacticalGuide => 'TACTICAL GUIDE';

  @override
  String get credits => 'CREDITS';

  @override
  String get settings => 'SETTINGS';

  @override
  String get tacticalProtocol => 'TACTICAL PROTOCOL';

  @override
  String get steerShipTitle => 'STEER SHIP';

  @override
  String get steerShipBody =>
      'Use left screen joystick or keyboard [W, A, S, D] keys.';

  @override
  String get weaponSystemsTitle => 'WEAPON SYSTEMS';

  @override
  String get weaponSystemsBody =>
      'Drag right screen joystick to rotate and auto-shoot. Alternatively, point with mouse cursor and hold left-click, or use [Arrow Keys].';

  @override
  String get fieldCoresTitle => 'FIELD CORES';

  @override
  String get fieldCoresBody =>
      'Destroy meteors and elite ships to harvest upgrades:\n• Shield Packs (Batteries) restores hull shields.\n• Power Cores upgrades laser layout (up to Spread Shot).\n• Fire Rate Cores (Cogs) increases thrusters & laser speeds.';

  @override
  String get understood => 'UNDERSTOOD';

  @override
  String get transmissionCredits => 'TRANSMISSION: CREDITS';

  @override
  String get assetCreatorTitle => 'ASSET CREATOR';

  @override
  String get assetCreatorBody =>
      'All graphical game assets (spaceships, lasers, meteors, tilesets, & UI assets) and audio effects are created by Kenney.';

  @override
  String get kenneyAssetsTitle => 'KENNEY ASSETS';

  @override
  String get kenneyAssetsBody =>
      'Kenney creates thousands of completely free, high-quality game assets (CC0 / Public Domain) to support the game development community. Discover more at www.kenney.nl.';

  @override
  String get transmissionTerminated => 'TRANSMISSION TERMINATED';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsSubtitle => 'SYSTEM SPECIFICATIONS & CONFIGURATION';

  @override
  String get languageSelect => 'GAME LANGUAGE';

  @override
  String get languageEnglish => 'ENGLISH';

  @override
  String get languageSpanish => 'SPANISH';

  @override
  String get saveAndClose => 'SAVE & CLOSE';

  @override
  String get back => 'BACK';

  @override
  String get shipSelectionTitle => 'SHIP SELECTION';

  @override
  String get engageHyperdrive => 'ENGAGE HYPERDRIVE';

  @override
  String get velocity => 'VELOCITY';

  @override
  String get armorHull => 'ARMOR HULL';

  @override
  String get firePower => 'FIRE POWER';

  @override
  String get shd => 'SHD';

  @override
  String get hull => 'HULL';

  @override
  String get sector => 'SECTOR';

  @override
  String get lives => 'LIVES';

  @override
  String get score => 'SCORE';

  @override
  String get high => 'HIGH';

  @override
  String get keyboardControlsGuide =>
      'CONTROLS: WASD to Move  |  Mouse Pointer to Aim + Hold Click to Shoot  |  Arrow Keys for Twin-Stick Shooting';

  @override
  String get transmissionPaused => 'TRANSMISSION\nPAUSED';

  @override
  String get tacticalAnalysisInProgress => 'TACTICAL ANALYSIS IN PROGRESS';

  @override
  String get resumeFlight => 'RESUME FLIGHT';

  @override
  String get restartMission => 'RESTART MISSION';

  @override
  String get abortMission => 'ABORT MISSION';

  @override
  String get shipDestroyed => 'SHIP DESTROYED';

  @override
  String get telemetrySynchronizationTerminated =>
      'TELEMETRY SYNCHRONIZATION TERMINATED';

  @override
  String get finalScore => 'FINAL SCORE';

  @override
  String sectorsCleared(int count) {
    return 'SECTORS CLEARED: $count';
  }

  @override
  String get newSectorRecord => 'NEW SECTOR RECORD!';

  @override
  String recordHolder(String highScoreStr) {
    return 'RECORD HOLDER: $highScoreStr';
  }

  @override
  String get redeployShip => 'REDEPLOY SHIP';

  @override
  String get returnToHangar => 'RETURN TO HANGAR';

  @override
  String get exitToStation => 'EXIT TO STATION';

  @override
  String get vanguardName => 'Vanguard';

  @override
  String get reaperName => 'Reaper';

  @override
  String get leviathanName => 'Leviathan';

  @override
  String get vanguardDescription =>
      'Balanced interstellar fighter. Equipped with standard high-velocity plasma lasers.';

  @override
  String get reaperDescription =>
      'Fast interceptor. Rapid fire rate but lower structural integrity. Dual pulse canons.';

  @override
  String get leviathanDescription =>
      'Heavy gunship. Extremely durable, fires high-damage heavy spread projectiles.';

  @override
  String get customGameConfig => 'CUSTOM CONFIGURATION';

  @override
  String get customGameConfigSubtitle =>
      'FINE-TUNE SHIP SYSTEMS & THREAT LEVELS';

  @override
  String get customConfigButton => 'CUSTOM GAME SETTINGS';

  @override
  String get playerDamage => 'Player Weapon Damage';

  @override
  String get playerFireSpeed => 'Player Laser Speed';

  @override
  String get enemyHealth => 'Enemy & Meteor Durability';

  @override
  String get enemySpeed => 'Enemy Fleet Speed';

  @override
  String get enemySpawnRate => 'Enemy Spawn Density';

  @override
  String get meteorSpawnRate => 'Meteor Spawn Density';

  @override
  String get enemyFireRate => 'Enemy Weapon Fire Rate';

  @override
  String get controlsSize => 'On-Screen Controls Size';

  @override
  String get fontSize => 'Game Font Size';

  @override
  String get resetToDefault => 'RESET ALL TO DEFAULT';
}
