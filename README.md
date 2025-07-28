# Workout Tracker

A Flutter workout tracking app, following clean architecture and SOLID principles.

## Architecture & Tech Stack

So I built this app using Claude Code, following clean architecture and SOLID principles. I used the Freezed package for better classes and then went with Riverpod and go_router because it's something I think you guys might be using and I always wanted to give them a try. I think I actually prefer Riverpod to BLoC now - the compile-time safety and lack of boilerplate is pretty nice.

### State Management - Riverpod
- **flutter_riverpod**: Chose this over BLoC for compile-time safety and cleaner syntax
- **riverpod_annotation**: Code generation makes providers much cleaner
- Really like how it handles async states without all the event/state boilerplate

### Data Models - Freezed
- **freezed**: Immutable data classes with copyWith, equality, and toString for free
- **json_annotation**: Clean JSON serialization without manual toJson/fromJson
- Makes the models bulletproof and way less verbose than vanilla Dart classes

### Navigation - go_router
- **go_router**: Type-safe, declarative routing that's becoming the standard
- Much cleaner than Navigator 1.0 and handles deep linking nicely

### Database - SQLite
- **sqflite**: Went with SQLite because it's reliable, fast, and doesn't need network
- **path**: For proper database file path handling across platforms
- Perfect for a local-first app like this where you want workouts available offline
- Simple relational model with workouts and workout_sets tables

### Utilities
- **uuid**: Generates unique IDs for workouts and sets (better than auto-increment for future-proofing)
- **intl**: Date/time formatting for user-friendly display (relative times, formatted dates)

### Testing & Quality
- **mocktail**: Modern mocking that's cleaner than mockito
- **golden_toolkit**: For pixel-perfect UI testing

## Project Structure

```
lib/
├── models/          # Freezed data models (Workout, WorkoutSet, Exercise)
├── data/            # Repository pattern for data access
├── providers/       # Riverpod providers for state management
├── routing/         # go_router configuration
├── screens/         # Main UI screens
├── widgets/         # Reusable UI components
├── utils/           # Helpers, extensions, theme
└── main.dart
```


