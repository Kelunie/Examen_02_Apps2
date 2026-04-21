# examen_02

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Super Square Attack

This project now includes a small arcade game built with Flutter + Flame.

### Game Objective

- Control the triangle player.
- Avoid colliding with falling squares.
- Keep the highest score possible.

### Rules

- Initial score: `100`
- Each hit: `-20` points
- Max hits allowed: `5`
- Total attempts available for falling squares: `30`
- Game over when:
  - You receive 5 hits, or
  - Attempts reach 0

### Controls

- `W`: move up
- `S`: move down
- `A`: move left
- `D`: move right

### Assets and Audio

- Player sprite: `assets/images/triangle.png`
- Enemy sprite: `assets/images/square.png`
- Move sound: `assets/audio/ball.wav`
- Collision sound: `assets/audio/explosion.wav`

## Commands to Run the Project

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Run on Windows

```bash
flutter run -d windows
```

### 3) Run on default connected device

```bash
flutter run
```

### Optional useful commands

```bash
flutter devices
flutter analyze
```
