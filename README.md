# Stellar Vortex 🚀

A premium, modern, and highly-immersive **Dual-Stick Arcade Space Shooter** game built with **Flutter** and powered by the **Flame Game Engine**. Playable on Web, Desktop, and Mobile, it blends retro arcade mechanics with a sleek sci-fi visual style.

---

## 🎮 Game Overview & Features

### 🌌 Immersive Visuals & Environment
*   **Parallax Starfield Background**: Multi-layered starfields scrolling at varying speeds create a convincing sense of depth and deep-space velocity.
*   **Dynamic Background Planets**: Procedural, rotating, and parallax-drifting planets generated dynamically using various base spheres, noise layers, and shadow maps tinted with custom vibrant HSL colors.
*   **Fluid Particle Explosions**: High-performance custom particle engines render cinematic explosions and projectile impact debris.
*   **Glassmorphic UI Design**: Start menus, ship selection grids, pause menus, and end-screen leaderboards built with modern glassmorphism (real-time backdrop filters, neon border glows, and responsive styling).

### 🕹️ Multi-Platform Input Systems
*   **Desktop Controls**: Command your ship using **WASD or Arrow keys** for vector movement, and use the **Mouse Pointer** to aim your ship dynamically. Press/Hold **Left Click or Spacebar** to fire.
*   **Mobile & Touch Controls**: Twin translucent **Virtual Joysticks** overlay on touch interfaces—the left joystick controls linear movement, and the right joystick controls 360-degree aiming and auto-firing.

### 🚀 Playable Ship Classes
Choose from three unique space vessels, each presenting distinct gameplay dynamics:
1.  **Vanguard (Balanced Class)**
    *   *Sprite*: `spaceShips_001.png`
    *   *Weapon*: Standard High-Velocity Plasma Lasers
    *   *Max Health*: 100 | *Speed*: 350.0 | *Fire Rate*: 0.22s interval
    *   *Role*: Ideal for all-around combat, combining good speed with moderate defense.
2.  **Reaper (Interceptor Class)**
    *   *Sprite*: `spaceShips_006.png`
    *   *Weapon*: Rapid-Fire Dual Pulse Cannons
    *   *Max Health*: 80 | *Speed*: 450.0 | *Fire Rate*: 0.14s interval
    *   *Role*: Extremely fast with high DPS, but vulnerable to hull damage.
3.  **Leviathan (Heavy Gunship Class)**
    *   *Sprite*: `spaceShips_008.png`
    *   *Weapon*: High-Damage Heavy Spread Projectiles
    *   *Max Health*: 160 | *Speed*: 240.0 | *Fire Rate*: 0.35s interval
    *   *Role*: A slow but indestructible tank firing a wide arc of destructive energy.

### 👾 Enemy AI & Wave Progression
Engage dynamic threats whose patterns and spawn frequencies scale as you advance through waves:
*   **Scout**: Highly agile ships that fly in sweeping paths across the screen.
*   **Kamikaze**: Fast, suicidal drones that lock onto your current position and charge at high velocities.
*   **Elite**: Heavy tactical ships that hold positions, dodge incoming fire, and return direct shots.
*   **Flagship Boss**: Spawns every 5 waves, sporting immense health pools and bullet-hell projectile configurations.

### ☄️ Hazards & Power-Ups
*   **Breakable Meteors**: Large drifting space rocks. Shooting them cracks them open into smaller, faster-drifting fragments.
*   **Energy Shield Buffs**: Grants a temporary protective bubble that absorbs collision and weapon damage.
*   **Weapon Upgrades**: Elevates your weapon fire pattern temporarily—from Single Lasers to Double Parallel Lasers, and eventually to a Triple Spread Shot.
*   **Hull Repairs**: Restoration packs that repair structural damage to your ship.

---

## 🛠️ Technology Stack

*   **SDK**: [Flutter](https://flutter.dev) (Dart language)
*   **Engine**: [Flame Engine 1.37.0](https://flame-engine.org/)
*   **Graphics & UI Components**:
    *   Art Assets: Kenney's Space Shooter Redux (Creative Commons Zero)
    *   Virtual Controls: Kenney's Mobile Elements (Creative Commons Zero)
    *   Custom Sprite Atlas XML Parser: Reads native XML spreadsheets for efficient rendering.
*   **Platform Features**: Native fullscreen toggle, locked landscape orientation, and keyboard/mouse pointer event interception.

---

## 📂 Project Structure

The project code is cleanly organized into functional layers under `lib/`:

*   **`lib/main.dart`**: Game bootstrapper. Configures device orientation, setups fullscreen options, applies dark sci-fi themes, and mounts the interactive menus using the `GameWidget` overlay map.
*   **`lib/game/`**
    *   `space_shooter_game.dart`: The core game manager. Orchestrates the game loop, waves, scores, high-scores, entity spawns, and overlays.
    *   `xml_spritesheet_parser.dart`: Custom XML parser to read subtextures from spritesheet image atlases.
*   **`lib/game/components/`**
    *   `player_ship.dart`: Handles keyboard/joystick movement, weapon fire states, thruster animations, shield bubble overlays, and health/shield values.
    *   `enemy_ship.dart`: Implements behavior states and pathfinding for Scout, Kamikaze, Elite, and Boss enemies.
    *   `bullet.dart`: High-speed lasers with tag-based collision damage (friendly vs. enemy).
    *   `meteor.dart`: Drifting rock math, rotating sprites, and split-into-children logic.
    *   `power_up.dart`: Floating buff boxes that check collision with the player.
    *   `starfield_background.dart`: Parallax deep-space starry layers.
    *   `background_planet.dart`: Procedural 3D-shaded background planets with independent texture rotation and parallax motion.
    *   `explosion_particle.dart`: Particle-based animations for hits and deaths.
*   **`lib/ui/`**
    *   `start_menu.dart`: Start screen with instructions and a credits section thanking Kenney.
    *   `ship_selection.dart`: Carousel grid drawing the player vessels alongside custom stat bar metrics.
    *   `hud.dart`: Neon heads-up-display with digital bars for shields/health, lives tracker, scores, and a pause trigger.
    *   `pause_menu.dart`: Overlays during paused gameplay.
    *   `game_over_menu.dart`: Score dashboard, high score checking, and a quick retry button.

---

## 🚀 Getting Started

### Prerequisites
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Running Locally

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/mangelsr/space_shooter.git
    cd space_shooter
    ```

2.  **Fetch Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the Game**:
    You can target your browser, a desktop window, or a connected mobile emulator:
    ```bash
    flutter run
    ```

---

## 🏆 Credits

All graphics and UI design assets are courtesy of **Kenney** (https://kenney.nl):
*   Space Shooter Sprites: *Space Shooter Redux* pack.
*   Virtual Controls & Icons: *Mobile Elements* pack.
*   Planet Parts: *Planet Parts* pack.
