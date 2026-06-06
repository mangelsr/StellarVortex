// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameTitle => 'VÓRTICE\nESTELAR';

  @override
  String get gameSubtitle =>
      'UN DISPARADOR DE CIENCIA FICCIÓN DE DOBLE PALANCA';

  @override
  String get launchMission => 'INICIAR MISIÓN';

  @override
  String get tacticalGuide => 'GUÍA TÁCTICA';

  @override
  String get credits => 'CRÉDITOS';

  @override
  String get settings => 'CONFIGURACIÓN';

  @override
  String get tacticalProtocol => 'PROTOCOLO TÁCTICO';

  @override
  String get steerShipTitle => 'PILOTAR NAVE';

  @override
  String get steerShipBody =>
      'Usa la palanca izquierda de la pantalla o las teclas [W, A, S, D].';

  @override
  String get weaponSystemsTitle => 'SISTEMAS DE ARMAS';

  @override
  String get weaponSystemsBody =>
      'Arrastra la palanca derecha para rotar y disparar. También puedes apuntar con el cursor del ratón y mantener pulsado el clic izquierdo, o usar las [Teclas de Flechas].';

  @override
  String get fieldCoresTitle => 'NÚCLEOS DE CAMPO';

  @override
  String get fieldCoresBody =>
      'Destruye meteoros y naves de élite para recolectar mejoras:\n• Escudos (Baterías) restauran los escudos del casco.\n• Núcleos de Energía mejoran el láser (hasta Disparo Extendido).\n• Núcleos de Cadencia (Engranajes) aumentan la velocidad de propulsores y láseres.';

  @override
  String get understood => 'ENTENDIDO';

  @override
  String get transmissionCredits => 'TRANSMISIÓN: CRÉDITOS';

  @override
  String get assetCreatorTitle => 'CREADOR DE ACTIVOS';

  @override
  String get assetCreatorBody =>
      'Todos los activos gráficos del juego (naves, láseres, meteoros, fondos y menús) y efectos de sonido fueron creados por Kenney.';

  @override
  String get kenneyAssetsTitle => 'ACTIVOS DE KENNEY';

  @override
  String get kenneyAssetsBody =>
      'Kenney crea miles de activos de juego completamente gratuitos y de alta calidad (CC0 / Dominio Público) para apoyar a la comunidad de desarrollo de videojuegos. Descubre más en www.kenney.nl.';

  @override
  String get transmissionTerminated => 'TRANSMISIÓN TERMINADA';

  @override
  String get settingsTitle => 'CONFIGURACIÓN';

  @override
  String get settingsSubtitle => 'ESPECIFICACIONES DEL SISTEMA Y PARÁMETROS';

  @override
  String get languageSelect => 'IDIOMA DEL JUEGO';

  @override
  String get languageEnglish => 'ENGLISH (INGLÉS)';

  @override
  String get languageSpanish => 'ESPAÑOL (SPANISH)';

  @override
  String get saveAndClose => 'GUARDAR Y CERRAR';

  @override
  String get back => 'ATRÁS';

  @override
  String get shipSelectionTitle => 'SELECCIÓN DE NAVE';

  @override
  String get engageHyperdrive => 'ACTIVAR HIPERIMPULSO';

  @override
  String get velocity => 'VELOCIDAD';

  @override
  String get armorHull => 'BLINDAJE';

  @override
  String get firePower => 'POTENCIA DE FUEGO';

  @override
  String get shd => 'ESC';

  @override
  String get hull => 'CASCO';

  @override
  String get sector => 'SECTOR';

  @override
  String get lives => 'VIDAS';

  @override
  String get score => 'PUNTOS';

  @override
  String get high => 'RÉCORD';

  @override
  String get keyboardControlsGuide =>
      'CONTROLES: WASD para Moverse  |  Ratón para Apuntar + Clic para Disparar  |  Teclas de Dirección para Disparo Doble';

  @override
  String get transmissionPaused => 'TRANSMISIÓN\nPAUSADA';

  @override
  String get tacticalAnalysisInProgress => 'ANÁLISIS TÁCTICO EN CURSO';

  @override
  String get resumeFlight => 'REANUDAR VUELO';

  @override
  String get restartMission => 'REINICIAR MISIÓN';

  @override
  String get abortMission => 'ABORTAR MISIÓN';

  @override
  String get shipDestroyed => 'NAVE DESTRUIDA';

  @override
  String get telemetrySynchronizationTerminated =>
      'SINCRONIZACIÓN DE TELEMETRÍA TERMINADA';

  @override
  String get finalScore => 'PUNTUACIÓN FINAL';

  @override
  String sectorsCleared(int count) {
    return 'SECTORES COMPLETADOS: $count';
  }

  @override
  String get newSectorRecord => '¡NUEVO RÉCORD DE SECTOR!';

  @override
  String recordHolder(String highScoreStr) {
    return 'RECORD ACTUAL: $highScoreStr';
  }

  @override
  String get redeployShip => 'REDESPLEGAR NAVE';

  @override
  String get returnToHangar => 'VOLVER AL HANGAR';

  @override
  String get exitToStation => 'SALIR A LA ESTACIÓN';

  @override
  String get vanguardName => 'Vanguardia';

  @override
  String get reaperName => 'Segador';

  @override
  String get leviathanName => 'Leviatán';

  @override
  String get vanguardDescription =>
      'Caza interestelar equilibrado. Equipado con láseres de plasma estándar de alta velocidad.';

  @override
  String get reaperDescription =>
      'Interceptor veloz. Alta cadencia de fuego pero menor integridad estructural. Cañones de pulso duales.';

  @override
  String get leviathanDescription =>
      'Cañonera pesada. Extremadamente resistente, dispara proyectiles pesados de gran dispersión y daño.';

  @override
  String get customGameConfig => 'CONFIGURACIÓN PERSONALIZADA';

  @override
  String get customGameConfigSubtitle =>
      'AJUSTA LOS SISTEMAS Y NIVELES DE AMENAZA';

  @override
  String get customConfigButton => 'AJUSTES DE JUEGO PERSONALIZADOS';

  @override
  String get playerDamage => 'Daño del Arma del Jugador';

  @override
  String get playerFireSpeed => 'Velocidad de Láser del Jugador';

  @override
  String get enemyHealth => 'Resistencia de Enemigos y Meteoros';

  @override
  String get enemySpeed => 'Velocidad de Flota Enemiga';

  @override
  String get enemySpawnRate => 'Densidad de Aparición de Enemigos';

  @override
  String get meteorSpawnRate => 'Densidad de Aparición de Meteoros';

  @override
  String get resetToDefault => 'REESTABLECER VALORES HANGAR';
}
