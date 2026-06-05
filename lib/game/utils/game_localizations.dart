import 'package:stellar_vortex/l10n/app_localizations.dart';
import '../models/player_ship_type.dart';

enum GameLanguage {
  en,
  es,
}

extension ShipLocalizations on AppLocalizations {
  String getShipName(PlayerShipType type) {
    switch (type) {
      case PlayerShipType.vanguard:
        return vanguardName;
      case PlayerShipType.reaper:
        return reaperName;
      case PlayerShipType.leviathan:
        return leviathanName;
    }
  }

  String getShipDescription(PlayerShipType type) {
    switch (type) {
      case PlayerShipType.vanguard:
        return vanguardDescription;
      case PlayerShipType.reaper:
        return reaperDescription;
      case PlayerShipType.leviathan:
        return leviathanDescription;
    }
  }
}
