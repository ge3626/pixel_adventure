import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/HUD/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/floor.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  //sets default background color
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  Player player = Player(character: 'Hood');
  int health = 5; //player health
  int itemsCollected = 0;
  int totalItemsNum = 0;
  bool isOkToNextFloor = false;

  late JoystickComponent joystick;
  bool showControls = false;
  bool playSounds = true; //turns on game audios
  double soundVolume = 1.0;
  double musicVolume = 1.0;
  List<String> floorNames = [
    'Floor-01',
    'Floor-02',
    'Floor-03',
    'Floor-04',
    'Floor-05',
    'Floor-06',
    'Floor-07',
    'Floor-08',
    'BossFight',
  ];
  int currentFloorIndex = 8; //Should initially set to be 0.

  bool _isAlreadyLoaded = false;

  @override
  FutureOr<void> onLoad() async {
    if (!_isAlreadyLoaded) {
      await images.loadAllImages();

      _loadFloor();

      if (showControls) {
        addJoystick();
        add(JumpButton());
      }
      _isAlreadyLoaded = true;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      knobRadius: 64,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextFloor() {
    removeWhere((component) => component is Floor);

    if (currentFloorIndex < floorNames.length - 1) {
      currentFloorIndex++;
      _loadFloor();
    } else {
      //if there is no more floors
      currentFloorIndex = 0;
      _loadFloor();
    }
  }

  void _loadFloor() {
    Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        Floor world = Floor(
          player: player,
          floorName: floorNames[currentFloorIndex],
        );

        cam = CameraComponent.withFixedResolution(
          world: world,
          width: 640,
          height: 340,
        );
        cam.viewfinder.anchor = Anchor.topLeft;

        addAll([cam, world]);
      },
    );
  }

  void reset() {
    currentFloorIndex = 0;
    health = 5;
  }
}
