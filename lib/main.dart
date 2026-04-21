import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
// add dart:math for random number generation
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setPortrait();
  final shapeGame = GameTemplate();
  runApp(GameWidget(game: shapeGame));
}

class GameTemplate extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Ship shipPlayer;
  // Add 3 squares to the game
  late List<Square> squareEnemies;
  // add a initial score variable
  int score = 100;
  // add a global attempts counter (3 squares * 10)
  int totalAttempts = 30;
  // count total hits received by the triangle
  int hitCount = 0;
  // control game over status
  bool isGameOver = false;
  // show the score component on the screen
  late TextComponent scoreText;
  // show the attempts component on the screen
  late TextComponent attemptsText;

  void checkGameOver() {
    if (isGameOver) {
      return;
    }

    if (hitCount > 5 || totalAttempts <= 0) {
      isGameOver = true;

      // Determine status based on remaining points
      String status;
      if (score >= 80) {
        status = 'Excellent!';
      } else if (score >= 60) {
        status = 'Good';
      } else if (score >= 40) {
        status = 'Regular';
      } else {
        status = 'Bad';
      }

      final double centerX = size.x / 2;
      final double centerY = size.y / 2;

      final statsStyle = TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 22.0),
      );

      // Draw background box for the stats popup
      add(
        RectangleComponent(
          position: Vector2(centerX - 130, centerY - 100),
          size: Vector2(300, 200),
          paint: Paint()..color = const Color(0xDD1A1A2E),
        ),
      );

      // Show game over title
      add(
        TextComponent(
          text: 'GAME OVER',
          position: Vector2(centerX - 100, centerY - 80),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.red,
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Show hits received
      add(
        TextComponent(
          text: 'Hits received: $hitCount',
          position: Vector2(centerX - 100, centerY - 20),
          textRenderer: statsStyle,
        ),
      );

      // Show remaining points
      add(
        TextComponent(
          text: 'Remaining points: $score',
          position: Vector2(centerX - 100, centerY + 15),
          textRenderer: statsStyle,
        ),
      );

      // Show status based on remaining points
      add(
        TextComponent(
          text: 'Status: $status',
          position: Vector2(centerX - 100, centerY + 50),
          textRenderer: statsStyle,
        ),
      );

      // Wait one frame so the text renders before pausing
      Future.delayed(const Duration(milliseconds: 100), () => pauseEngine());
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(HeaderTitle());
    // add the score text and initialize it with the initial score, position, style, color and font size
    scoreText = TextComponent(
      text: 'Score: $score',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 50.0),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 22.0),
      ),
    );
    add(scoreText);
    // show the attempts text on the screen, initialize it with the total attempts, position, style, color and font size
    attemptsText = TextComponent(
      text: 'Attempts: $totalAttempts',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 80.0),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 22.0),
      ),
    );
    add(attemptsText);
    add(shipPlayer = Ship(await loadSprite('triangle.png')));

    // Add 3 squares at different X positions
    final squareSprite = await loadSprite('square.png');
    squareEnemies = [
      Square(squareSprite, 100.0),
      Square(squareSprite, 300.0),
      Square(squareSprite, 500.0),
    ];
    for (final square in squareEnemies) {
      add(square);
    }

    // Load and cache the audio
    await FlameAudio.audioCache.load('ball.wav');
    await FlameAudio.audioCache.load('explosion.wav');
  }
}

// Add a ship to the game, using triangle.png
class Ship extends SpriteComponent
    with HasGameReference<GameTemplate>, CollisionCallbacks {
  final spriteVelocity = 500;
  double screenPosition = 0.0;
  bool leftPressed = false;
  bool rightPressed = false;
  bool upPressed = false;
  bool downPressed = false;
  bool isCollision = false;

  Ship(Sprite sprite) {
    debugMode = true;
    this.sprite = sprite;
    size = Vector2(50.0, 50.0);
    anchor = Anchor.center;
    position = Vector2(200.0, 0.0);
    add(RectangleHitbox());
    add(
      KeyboardListenerComponent(
        keyUp: {},
        keyDown: {
          LogicalKeyboardKey.keyA: (keysPressed) {
            return leftPressed = true;
          },
          LogicalKeyboardKey.keyD: (keysPressed) {
            return rightPressed = true;
          },
          // Add up and down movement
          LogicalKeyboardKey.keyW: (keysPressed) {
            return upPressed = true;
          },
          LogicalKeyboardKey.keyS: (keysPressed) {
            return downPressed = true;
          },
        },
      ),
    );
  }

  // center the ship vertically on the screen
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.x = size.x / 2;
    position.y = size.y / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (leftPressed == true) {
      screenPosition = position.x - spriteVelocity * dt;
      if (screenPosition > 0 + width / 2) {
        position.x = screenPosition;
        FlameAudio.play('ball.wav');
      }
      leftPressed = false;
    }
    if (rightPressed == true) {
      screenPosition = position.x + spriteVelocity * dt;
      if (screenPosition < game.size.x - width / 2) {
        position.x = screenPosition;
        FlameAudio.play('ball.wav');
      }
      rightPressed = false;
    }
    if (upPressed == true) {
      screenPosition = position.y - spriteVelocity * dt;
      if (screenPosition > 0 + height / 2) {
        position.y = screenPosition;
        FlameAudio.play('ball.wav');
      }
      upPressed = false;
    }
    if (downPressed == true) {
      screenPosition = position.y + spriteVelocity * dt;
      if (screenPosition < game.size.y - height / 2) {
        position.y = screenPosition;
        FlameAudio.play('ball.wav');
      }
      downPressed = false;
    }
  }
}

class Square extends SpriteComponent
    with HasGameReference<GameTemplate>, CollisionCallbacks {
  // Set a random velocity for each square
  late int spriteVelocity;
  double screenPosition = 0.0;
  bool isCollision = false;

  Square(Sprite sprite, double xPosition) {
    debugMode = true;
    this.sprite = sprite;
    size = Vector2(50.0, 50.0);
    anchor = Anchor.center;
    // Set a random velocity between 50 and 250
    spriteVelocity = Random().nextInt(200) + 50;
    position = Vector2(xPosition, 110.0);
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isCollision == true || game.isGameOver == true) {
      return;
    }

    isCollision = true;
    // Reset the square position to the top with a random X on collision
    position.x = Random().nextDouble() * (game.size.x - width);
    position.y = 110.0;
    spriteVelocity = Random().nextInt(200) + 50;
    // Decrease the score by 20 points on collision
    game.score -= 20;
    // Increase hit count by 1 on collision
    game.hitCount += 1;
    // Update the score text
    game.scoreText.text = 'Score: ${game.score}';
    game.checkGameOver();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Fall down the screen
    screenPosition = position.y + spriteVelocity * dt;
    if (screenPosition < game.size.y - height / 2) {
      position.y = screenPosition;
    } else {
      // Reset position to the top with a random X
      position.x = Random().nextDouble() * (game.size.x - width);
      position.y = 110.0;
      // Set a new random velocity when the square resets to the top
      spriteVelocity = Random().nextInt(200) + 50;

      // Decrease the total attempts by 1 when the square resets to the top
      if (game.totalAttempts > 0) {
        game.totalAttempts -= 1;
      }
      game.attemptsText.text = 'Attempts: ${game.totalAttempts}';
      game.checkGameOver();
    }

    if (isCollision) {
      //print('Collision!');
      FlameAudio.play('explosion.wav');
      isCollision = false;
    }
  }
}

class HeaderTitle extends TextBoxComponent {
  final double xHeaderPosition = 100.0;
  final double yHeaderPosition = 20.0;

  final textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 22.0,
      fontFamily: 'Awesome Font',
    ),
  );

  HeaderTitle() {
    position = Vector2(xHeaderPosition, yHeaderPosition);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.x = size.x / 2;
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(canvas, "Super Square Attack", position);
  }
}
