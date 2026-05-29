enum PlayerShipType {
  vanguard(
    name: 'Vanguard',
    spriteName: 'spaceShips_001.png',
    maxHealth: 100,
    speed: 350.0,
    fireInterval: 0.22,
    description:
        'Balanced interstellar fighter. Equipped with standard high-velocity plasma lasers.',
  ),
  reaper(
    name: 'Reaper',
    spriteName: 'spaceShips_006.png',
    maxHealth: 80,
    speed: 450.0,
    fireInterval: 0.14,
    description:
        'Fast interceptor. Rapid fire rate but lower structural integrity. Dual pulse canons.',
  ),
  leviathan(
    name: 'Leviathan',
    spriteName: 'spaceShips_008.png',
    maxHealth: 160,
    speed: 240.0,
    fireInterval: 0.35,
    description:
        'Heavy gunship. Extremely durable, fires high-damage heavy spread projectiles.',
  );

  final String name;
  final String spriteName;
  final double maxHealth;
  final double speed;
  final double fireInterval;
  final String description;

  const PlayerShipType({
    required this.name,
    required this.spriteName,
    required this.maxHealth,
    required this.speed,
    required this.fireInterval,
    required this.description,
  });
}
