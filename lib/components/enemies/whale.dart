import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/bullet.dart';
import 'package:pixel_adventure/components/enemy.dart';
import 'package:pixel_adventure/components/player.dart';

enum State {
  idle,
  run,
  hit,
  jump,
  fall,
  ground,
  attack,
  deadGround,
  deadHit,
  swallow,
}

class Whale extends Enemy {
  Whale({
    super.position,
    super.size,
    super.offsetPositive,
    super.offsetNegative,
    super.lives,
  });

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final SpriteAnimation _fallAnimation;
  late final SpriteAnimation _groundAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _deadGroundAnimation;
  late final SpriteAnimation _deadHitAnimation;
  late final SpriteAnimation _swallowAnimation;

  final int deadGroundLives = 4;

  bool hitboxActive = true;
  RectangleHitbox? hitbox;
  bool deadGround = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    priority = -1;

    _loadAnimations();
    calculateRange();

    if (hitboxActive) {
      hitbox = RectangleHitbox(
        position: Vector2(4, 5),
        size: Vector2(35, 28),
      );
    }
    add(hitbox!);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    checkLives();
    if (!deadGround) {
      _updateState();
      movement(dt);
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollisionStart(intersectionPoints, other);
    if (deadGround) {
      if (game.playSounds) {
        FlameAudio.play('enemyKilled.wav', volume: game.soundVolume);
      }
      current = State.deadHit;
      await animationTicker?.completed;
      current = State.deadGround;
    } else {
      current = State.hit;
    }

    if (other is Bullet) {
      lives--;
      other.removeFromParent();
    }
    if (other is Player) other.collidedWithEnemy();
  }

  void _loadAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 44);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    _jumpAnimation = _spriteAnimation('Jump', 4);
    _fallAnimation = _spriteAnimation('Fall', 2);
    _groundAnimation = _spriteAnimation('Ground', 3)..loop = false;
    _attackAnimation = _spriteAnimation('Attack', 11);
    _deadGroundAnimation = _spriteAnimation('Dead Ground', 4);
    _deadHitAnimation = _spriteAnimation('Dead Hit', 6)..loop = false;
    _swallowAnimation = _spriteAnimation('Swallow', 10)..loop = false;

    animations = {
      State.idle: _idleAnimation,
      State.run: _runAnimation,
      State.hit: _hitAnimation,
      State.jump: _jumpAnimation,
      State.fall: _fallAnimation,
      State.ground: _groundAnimation,
      State.attack: _attackAnimation,
      State.deadGround: _deadGroundAnimation,
      State.deadHit: _deadHitAnimation,
      State.swallow: _swallowAnimation,
    };

    current = State.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Whale/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(68, 68),
      ),
    );
  }

  void _updateState() {
    current = (velocity.x != 0) ? State.run : State.idle;

    if ((moveDirection.x > 0 && scale.x > 0) ||
        (moveDirection.x < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

//TODO
  void collidedWithPlayer() {
    player.collidedWithEnemy();
  }

  void checkLives() {
    if (lives <= deadGroundLives) {
      deadGround = true;
      current = State.deadHit;
    }
    if (lives <= 0) {
      removeFromParent();
    }
  }
}
