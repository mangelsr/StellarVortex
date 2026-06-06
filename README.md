# Stellar Vortex 🚀

A premium, modern, and highly-immersive **Dual-Stick Arcade Space Shooter** game built with **Flutter** and powered by the **Flame Game Engine**. Playable on Web, Desktop, and Mobile, it blends retro arcade mechanics with a sleek sci-fi visual style.

---

## 🎮 Game Overview & Features

### 🌌 Immersive Visuals & Environment

* **Parallax Starfield Background**: Multi-layered starfield rendering at variable speed ratios, creating realistic depth-of-field and forward velocity effects.
* **Procedurally Generated Planets**: Dynamic planet rendering combining random base sphere textures, noise overlays, lighting masks, and color tinting using customized HSL palettes.
* **Advanced Particle FX Engine**: High-performance, customizable particle generators for ship thruster exhaust fire, projectile impacts, shield deflection impacts, and massive ship/boss explosions.
* **Glassmorphic UI Overlay Hangar**: Transparent overlays, real-time backdrop blur filters, glowing neon vector borders, and responsive design systems across menus.

### 🕹️ Multi-Platform Input Systems

* **Desktop Controls**: Smooth movement using **WASD or Arrow keys**, cursor aiming via **Mouse Pointer**, and firing via **Left Click or Spacebar**. Pressing arrow keys also enables twin-stick vector firing.
* **Mobile & Touch Controls**: Twin translucent **Virtual Joysticks** overlay (left for vector movement, right for 360-degree aiming and auto-firing) alongside an optional tactile HUD fire button.

### 🚀 Playable Ship Classes

Choose from three unique space vessels, each presenting distinct gameplay dynamics:

1. **Vanguard (Balanced Class)**
    * *Sprite*: `spaceShips_001.png`
    * *Weapon*: Standard High-Velocity Plasma Lasers
    * *Max Health*: 100 | *Speed*: 350.0 | *Fire Rate*: 0.22s interval
    * *Role*: Ideal for all-around combat, combining good speed with moderate defense.
2. **Reaper (Interceptor Class)**
    * *Sprite*: `spaceShips_006.png`
    * *Weapon*: Rapid-Fire Dual Pulse Cannons
    * *Max Health*: 80 | *Speed*: 450.0 | *Fire Rate*: 0.14s interval
    * *Role*: Extremely fast with high DPS, but vulnerable to hull damage.
3. **Leviathan (Heavy Gunship Class)**
    * *Sprite*: `spaceShips_008.png`
    * *Weapon*: High-Damage Heavy Spread Projectiles
    * *Max Health*: 160 | *Speed*: 240.0 | *Fire Rate*: 0.35s interval
    * *Role*: A slow but indestructible tank firing a wide arc of destructive energy.

### 👾 Enemy AI & Wave Progression

Engage dynamic threats whose patterns and spawn frequencies scale as you advance through waves:

* **Scout**: Highly agile ships that fly in sweeping paths across the screen.
* **Kamikaze**: Fast, suicidal drones that lock onto your current position and charge at high velocities.
* **Elite**: Heavy tactical ships that hold positions, dodge incoming fire, and return direct shots.
* **Flagship Boss**: Spawns every 5 waves, sporting immense health pools and bullet-hell projectile configurations.

### ☄️ Hazards & Power-Ups

* **Breakable Meteors**: Large drifting space rocks. Shooting them cracks them open into smaller, faster-drifting fragments.
* **Shield Core Battery**: Grants a protective bubble and restores shield points to absorb collision and weapon damage.
* **Power Weapon Upgrade**: Elevates weapon fire pattern temporarily from Single Lasers to Double Parallel Lasers, and up to a Triple Spread Shot.
* **Fire Rate Core**: Speeds up weapon firing interval and thruster velocity.

---

## 🛠️ Technology Stack

* **SDK**: [Flutter](https://flutter.dev) (Dart language)
* **Engine**: [Flame Engine 1.37.0](https://flame-engine.org/)
* **Data Persistence**: Uses `shared_preferences` to persist high scores, language preferences, and audio/sound settings across game sessions.
* **Localization**: Bilingual interface supporting English and Spanish text via a customized localization manager.
* **Graphics, UI & Audio Components**:
  * Art Assets: Kenney's Space Shooter Redux (Creative Commons Zero)
  * Virtual Controls: Kenney's Mobile Elements (Creative Commons Zero)
  * Audio Effects: Kenney's Space Audio (Creative Commons Zero)
  * Custom Sprite Atlas XML Parser: Reads native XML spreadsheets for efficient rendering.
* **Platform Features**: Native fullscreen toggle, locked landscape orientation, and keyboard/mouse pointer event interception.

---

## 📂 Project Structure

The project code is cleanly organized into functional layers under `lib/`:

* **`lib/main.dart`**: Game bootstrapper. Configures device orientation, setups fullscreen options, applies dark sci-fi themes, and mounts the interactive menus using the `GameWidget` overlay map.
* **`lib/game/`**
  * `space_shooter_game.dart`: The core game manager. Orchestrates the game loop, waves, scores, high-scores, entity spawns, and overlays.
  * `game_constants.dart`: Centralized game balance registry containing all player, enemy, meteor, thruster, and particle constants.
* **`lib/game/components/`**
  * `components.dart`: Public exports exposing all game components.
  * `background/`
    * `background_planet.dart`: Procedural background planets with independent texture rotation and parallax motion.
    * `starfield_background.dart`: Parallax deep-space starry layers.
  * `entities/`
    * `player_ship.dart`: Handles keyboard/joystick movement, weapon fire states, thruster animations, shield bubble overlays, and health/shield values.
    * `enemy_ship.dart`: Implements behavior states and pathfinding for Scout, Kamikaze, Elite, and Boss enemies.
    * `bullet.dart`: High-speed lasers with tag-based collision damage (friendly vs. enemy).
    * `meteor.dart`: Drifting rock math, rotating sprites, and split-into-children logic.
    * `power_up.dart`: Floating buff boxes (Shield, Weapon Upgrade, Fire Rate) checking collision with the player.
  * `fx/`
    * `engine_thruster.dart`: Particle thruster system following ship rotation and movement states.
    * `explosion_particle.dart`: Particle-based animations for hits, sparks, and ship deaths.
  * `managers/`
    * `spawn_manager.dart`: Handles wave-based spawning of enemies and obstacles.
* **`lib/game/managers/`**
  * `game_controls_manager.dart`: Manages virtual joysticks and button HUD overlays for mobile configurations.
  * `game_session_manager.dart`: Tracks scores, current wave progress, and lives during an active session.
* **`lib/game/models/`**
  * `game_state.dart`: Enums representing the active game state machine (playing, paused, over).
  * `player_ship_type.dart`: Configurations defining the three playable ship hulls.
* **`lib/game/utils/`**
  * `game_asset_loader.dart`: Pre-loads sprite sheets and audio clips.
  * `game_localizations.dart`: Standard localizations manager supporting dynamic English and Spanish translation strings.
  * `xml_spritesheet_parser.dart`: Custom XML parser to read subtextures from spritesheet image atlases.
* **`lib/ui/`**
  * `start_menu.dart`: Start screen with instructions and a credits section thanking Kenney.
  * `settings_menu.dart`: Interacts with `shared_preferences` to toggle language, sound fx, and music.
  * `ship_selection.dart`: Carousel grid drawing the player vessels alongside custom stat bar metrics.
  * `hud.dart`: Neon heads-up-display with digital bars for shields/health, lives tracker, scores, and a pause trigger.
  * `pause_menu.dart`: Overlays during paused gameplay.
  * `game_over_menu.dart`: Score dashboard, high score checking, and a quick retry button.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Running Locally

1. **Clone the repository**:

    ```bash
    git clone https://github.com/mangelsr/StellarVortex.git
    cd StellarVortex
    ```

2. **Fetch Dependencies**:

    ```bash
    flutter pub get
    ```

3. **Run the Game**:
    You can target your browser, a desktop window, or a connected mobile emulator:

    ```bash
    flutter run
    ```

---

## 🏆 Credits

All graphics and audio assets are courtesy of **Kenney** (<https://kenney.nl>):

* Space Shooter Sprites: *Space Shooter Redux* pack.
* Virtual Controls & Icons: *Mobile Elements* pack.
* Planet Parts: *Planet Parts* pack.
* Audio Effects: *Space Audio* pack.

---

## 📄 License

This project is proprietary. All rights reserved to the copyright owner. See the [LICENSE](LICENSE) file for more details.
