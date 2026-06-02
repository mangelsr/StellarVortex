import '../models/player_ship_type.dart';

enum GameLanguage {
  en,
  es,
}

class GameLocalizations {
  final GameLanguage language;

  GameLocalizations(this.language);

  // Helper getters for all the strings in the game
  String get gameTitle => language == GameLanguage.es ? 'VÓRTICE\nESTELAR' : 'STELLAR\nVORTEX';
  String get gameSubtitle => language == GameLanguage.es
      ? 'UN DISPARADOR DE CIENCIA FICCIÓN DE DOBLE PALANCA'
      : 'A DUAL-STICK SCI-FI SHOOTER';

  // Start Menu
  String get launchMission => language == GameLanguage.es ? 'INICIAR MISIÓN' : 'LAUNCH MISSION';
  String get tacticalGuide => language == GameLanguage.es ? 'GUÍA TÁCTICA' : 'TACTICAL GUIDE';
  String get credits => language == GameLanguage.es ? 'CRÉDITOS' : 'CREDITS';
  String get settings => language == GameLanguage.es ? 'CONFIGURACIÓN' : 'SETTINGS';

  // Tactical Guide (Instructions)
  String get tacticalProtocol => language == GameLanguage.es ? 'PROTOCOLO TÁCTICO' : 'TACTICAL PROTOCOL';
  String get steerShipTitle => language == GameLanguage.es ? 'PILOTAR NAVE' : 'STEER SHIP';
  String get steerShipBody => language == GameLanguage.es
      ? 'Usa la palanca izquierda de la pantalla o las teclas [W, A, S, D].'
      : 'Use left screen joystick or keyboard [W, A, S, D] keys.';
  String get weaponSystemsTitle => language == GameLanguage.es ? 'SISTEMAS DE ARMAS' : 'WEAPON SYSTEMS';
  String get weaponSystemsBody => language == GameLanguage.es
      ? 'Arrastra la palanca derecha para rotar y disparar. También puedes apuntar con el cursor del ratón y mantener pulsado el clic izquierdo, o usar las [Teclas de Flechas].'
      : 'Drag right screen joystick to rotate and auto-shoot. Alternatively, point with mouse cursor and hold left-click, or use [Arrow Keys].';
  String get fieldCoresTitle => language == GameLanguage.es ? 'NÚCLEOS DE CAMPO' : 'FIELD CORES';
  String get fieldCoresBody => language == GameLanguage.es
      ? 'Destruye meteoros y naves de élite para recolectar mejoras:\n• Escudos (Baterías) restauran los escudos del casco.\n• Núcleos de Energía mejoran el láser (hasta Disparo Extendido).\n• Núcleos de Cadencia (Engranajes) aumentan la velocidad de propulsores y láseres.'
      : 'Destroy meteors and elite ships to harvest upgrades:\n• Shield Packs (Batteries) restores hull shields.\n• Power Cores upgrades laser layout (up to Spread Shot).\n• Fire Rate Cores (Cogs) increases thrusters & laser speeds.';
  String get understood => language == GameLanguage.es ? 'ENTENDIDO' : 'UNDERSTOOD';

  // Credits
  String get transmissionCredits => language == GameLanguage.es ? 'TRANSMISIÓN: CRÉDITOS' : 'TRANSMISSION: CREDITS';
  String get assetCreatorTitle => language == GameLanguage.es ? 'CREADOR DE ACTIVOS' : 'ASSET CREATOR';
  String get assetCreatorBody => language == GameLanguage.es
      ? 'Todos los activos gráficos del juego (naves, láseres, meteoros, fondos y menús) y efectos de sonido fueron creados por Kenney.'
      : 'All graphical game assets (spaceships, lasers, meteors, tilesets, & UI assets) and audio effects are created by Kenney.';
  String get kenneyAssetsTitle => language == GameLanguage.es ? 'ACTIVOS DE KENNEY' : 'KENNEY ASSETS';
  String get kenneyAssetsBody => language == GameLanguage.es
      ? 'Kenney crea miles de activos de juego completamente gratuitos y de alta calidad (CC0 / Dominio Público) para apoyar a la comunidad de desarrollo de videojuegos. Descubre más en www.kenney.nl.'
      : 'Kenney creates thousands of completely free, high-quality game assets (CC0 / Public Domain) to support the game development community. Discover more at www.kenney.nl.';
  String get transmissionTerminated => language == GameLanguage.es ? 'TRANSMISIÓN TERMINADA' : 'TRANSMISSION TERMINATED';

  // Settings Menu
  String get settingsTitle => language == GameLanguage.es ? 'CONFIGURACIÓN' : 'SETTINGS';
  String get settingsSubtitle => language == GameLanguage.es ? 'ESPECIFICACIONES DEL SISTEMA Y PARÁMETROS' : 'SYSTEM SPECIFICATIONS & CONFIGURATION';
  String get languageSelect => language == GameLanguage.es ? 'IDIOMA DEL JUEGO' : 'GAME LANGUAGE';
  String get languageEnglish => language == GameLanguage.es ? 'ENGLISH (INGLÉS)' : 'ENGLISH';
  String get languageSpanish => language == GameLanguage.es ? 'ESPAÑOL (SPANISH)' : 'SPANISH';
  String get saveAndClose => language == GameLanguage.es ? 'GUARDAR Y CERRAR' : 'SAVE & CLOSE';

  // Ship Selection Hangar
  String get back => language == GameLanguage.es ? 'ATRÁS' : 'BACK';
  String get shipSelectionTitle => language == GameLanguage.es ? 'SELECCIÓN DE NAVE' : 'SHIP SELECTION';
  String get engageHyperdrive => language == GameLanguage.es ? 'ACTIVAR HIPERIMPULSO' : 'ENGAGE HYPERDRIVE';
  String get velocity => language == GameLanguage.es ? 'VELOCIDAD' : 'VELOCITY';
  String get armorHull => language == GameLanguage.es ? 'BLINDAJE' : 'ARMOR HULL';
  String get firePower => language == GameLanguage.es ? 'POTENCIA DE FUEGO' : 'FIRE POWER';

  // HUD
  String get shd => language == GameLanguage.es ? 'ESC' : 'SHD';
  String get hull => language == GameLanguage.es ? 'CASCO' : 'HULL';
  String get sector => language == GameLanguage.es ? 'SECTOR' : 'SECTOR';
  String get lives => language == GameLanguage.es ? 'VIDAS' : 'LIVES';
  String get score => language == GameLanguage.es ? 'PUNTOS' : 'SCORE';
  String get high => language == GameLanguage.es ? 'RÉCORD' : 'HIGH';
  String get keyboardControlsGuide => language == GameLanguage.es
      ? 'CONTROLES: WASD para Moverse  |  Ratón para Apuntar + Clic para Disparar  |  Teclas de Dirección para Disparo Doble'
      : 'CONTROLS: WASD to Move  |  Mouse Pointer to Aim + Hold Click to Shoot  |  Arrow Keys for Twin-Stick Shooting';

  // Pause Menu
  String get transmissionPaused => language == GameLanguage.es ? 'TRANSMISIÓN\nPAUSADA' : 'TRANSMISSION\nPAUSED';
  String get tacticalAnalysisInProgress => language == GameLanguage.es
      ? 'ANÁLISIS TÁCTICO EN CURSO'
      : 'TACTICAL ANALYSIS IN PROGRESS';
  String get resumeFlight => language == GameLanguage.es ? 'REANUDAR VUELO' : 'RESUME FLIGHT';
  String get restartMission => language == GameLanguage.es ? 'REINICIAR MISIÓN' : 'RESTART MISSION';
  String get abortMission => language == GameLanguage.es ? 'ABORTAR MISIÓN' : 'ABORT MISSION';

  // Game Over Menu
  String get shipDestroyed => language == GameLanguage.es ? 'NAVE DESTRUIDA' : 'SHIP DESTROYED';
  String get telemetrySynchronizationTerminated => language == GameLanguage.es
      ? 'SINCRONIZACIÓN DE TELEMETRÍA TERMINADA'
      : 'TELEMETRY SYNCHRONIZATION TERMINATED';
  String get finalScore => language == GameLanguage.es ? 'PUNTUACIÓN FINAL' : 'FINAL SCORE';
  String sectorsCleared(int count) => language == GameLanguage.es
      ? 'SECTORES COMPLETADOS: $count'
      : 'SECTORS CLEARED: $count';
  String get newSectorRecord => language == GameLanguage.es ? '¡NUEVO RÉCORD DE SECTOR!' : 'NEW SECTOR RECORD!';
  String recordHolder(String highScoreStr) => language == GameLanguage.es
      ? 'RECORD ACTUAL: $highScoreStr'
      : 'RECORD HOLDER: $highScoreStr';
  String get redeployShip => language == GameLanguage.es ? 'REDESPLEGAR NAVE' : 'REDEPLOY SHIP';
  String get returnToHangar => language == GameLanguage.es ? 'VOLVER AL HANGAR' : 'RETURN TO HANGAR';
  String get exitToStation => language == GameLanguage.es ? 'SALIR A LA ESTACIÓN' : 'EXIT TO STATION';

  // Ship names & descriptions helper
  String getShipName(PlayerShipType type) {
    switch (type) {
      case PlayerShipType.vanguard:
        return language == GameLanguage.es ? 'Vanguardia' : 'Vanguard';
      case PlayerShipType.reaper:
        return language == GameLanguage.es ? 'Segador' : 'Reaper';
      case PlayerShipType.leviathan:
        return language == GameLanguage.es ? 'Leviatán' : 'Leviathan';
    }
  }

  String getShipDescription(PlayerShipType type) {
    switch (type) {
      case PlayerShipType.vanguard:
        return language == GameLanguage.es
            ? 'Caza interestelar equilibrado. Equipado con láseres de plasma estándar de alta velocidad.'
            : 'Balanced interstellar fighter. Equipped with standard high-velocity plasma lasers.';
      case PlayerShipType.reaper:
        return language == GameLanguage.es
            ? 'Interceptor veloz. Alta cadencia de fuego pero menor integridad estructural. Cañones de pulso duales.'
            : 'Fast interceptor. Rapid fire rate but lower structural integrity. Dual pulse canons.';
      case PlayerShipType.leviathan:
        return language == GameLanguage.es
            ? 'Cañonera pesada. Extremadamente resistente, dispara proyectiles pesados de gran dispersión y daño.'
            : 'Heavy gunship. Extremely durable, fires high-damage heavy spread projectiles.';
    }
  }
}
