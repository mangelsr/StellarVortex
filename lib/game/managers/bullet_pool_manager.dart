import 'package:flame/game.dart';
import '../components/entities/bullet.dart';
import '../game_constants.dart';

mixin BulletPoolManager on FlameGame {
  final List<Bullet> _playerBulletPool = [];
  final List<Bullet> _enemyBulletPool = [];

  static const int _playerPoolSize = 250;
  static const int _enemyPoolSize = 500;

  Future<void> initBulletPool() async {
    _playerBulletPool.clear();
    _enemyBulletPool.clear();

    for (int i = 0; i < _playerPoolSize; i++) {
      final bullet = Bullet(
        position: Vector2(-1000, -1000),
        velocity: Vector2.zero(),
        isPlayerBullet: true,
        isActive: false,
      );
      _playerBulletPool.add(bullet);
      await add(bullet);
    }

    for (int i = 0; i < _enemyPoolSize; i++) {
      final bullet = Bullet(
        position: Vector2(-1000, -1000),
        velocity: Vector2.zero(),
        isPlayerBullet: false,
        isActive: false,
      );
      _enemyBulletPool.add(bullet);
      await add(bullet);
    }
  }

  void spawnBullet({
    required Vector2 position,
    required Vector2 velocity,
    required bool isPlayerBullet,
    double damage = BulletConstants.defaultDamage,
  }) {
    final pool = isPlayerBullet ? _playerBulletPool : _enemyBulletPool;
    Bullet? recycled;

    for (final bullet in pool) {
      if (!bullet.isActive) {
        recycled = bullet;
        break;
      }
    }

    if (recycled == null) {
      // Dynamic allocation fallback if pools are exhausted
      recycled = Bullet(
        position: position,
        velocity: velocity,
        isPlayerBullet: isPlayerBullet,
        damage: damage,
        isActive: true,
      );
      pool.add(recycled);
      add(recycled);
      return;
    }

    recycled.reset(position: position, velocity: velocity, damage: damage);
  }

  void clearBulletPools() {
    for (final bullet in _playerBulletPool) {
      bullet.deactivate();
    }
    for (final bullet in _enemyBulletPool) {
      bullet.deactivate();
    }
  }
}
