import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/floor.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  //sets default background color
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  int health = 5; //player health

  late JoystickComponent joystick;
  bool showJoystick = false;
  bool playSounds = false; //turns on game audios
  double soundVolume = 1.0;
  List<String> floorNames = ['Floor-01', 'Floor-02'];
  int currentFloorIndex = 0; //Should initially set to be 0.

  @override
  FutureOr<void> onLoad() async {
    //loads all images into cache.
    await images.loadAllImages();
    //loads floor
    _loadFloor();
    //loads joystick
    if (showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
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
      //if there is no more levels
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
}
