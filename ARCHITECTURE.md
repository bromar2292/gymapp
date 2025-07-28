# Workout Tracker - Architecture Documentation

## Overview

This workout tracking application follows a clean architecture pattern with Riverpod for state management and go_router for navigation, aligning with company standards.

## Architecture Layers

### 1. Presentation Layer
- **Screens**: Top-level UI containers (MainScreen)
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state management

### 2. Business Layer
- **Notifiers**: Business logic and state management
- **Models**: Domain entities (Workout, WorkoutSet, Exercise)

### 3. Data Layer
- **Repository**: Abstract data interface
- **Implementation**: SQLite database operations
- **Database Helper**: Database initialization and management

## Key Design Decisions

### State Management (Riverpod)
- **Why**: Type-safe, testable, no BuildContext required
- **Pattern**: StateNotifier for complex state, FutureProvider for async data
- **Benefits**: Compile-time safety, excellent DevTools support

### Data Models (Freezed)
- **Why**: Immutable models, automatic copyWith, JSON serialization
- **Pattern**: All models use Freezed for consistency
- **Benefits**: Reduces boilerplate, prevents mutations, value equality

### Navigation (go_router)
- **Why**: Declarative routing, deep linking support
- **Pattern**: Single route for now, ready for expansion
- **Benefits**: Type-safe navigation, URL-based routing

### Persistence (SQLite)
- **Why**: Reliable local storage, complex queries, ACID compliance
- **Pattern**: Repository pattern for abstraction
- **Benefits**: Offline-first, performant, SQL queries

## Data Flow

1. **User Action** → Widget
2. **Widget** → Riverpod Notifier
3. **Notifier** → Repository
4. **Repository** → Database
5. **Database** → Repository (data)
6. **Repository** → Notifier (processed)
7. **Notifier** → Widget (state update)

## File Structure

```
lib/
├── models/          # Domain models
├── data/            # Data layer (repository, database)
├── providers/       # Riverpod providers and notifiers
├── routing/         # go_router configuration
├── screens/         # Top-level screens
├── widgets/         # Reusable UI components
├── utils/           # Utilities and helpers
└── main.dart        # App entry point
```

## Testing Strategy

### Unit Tests
- Models: Serialization, business logic
- Repository: Database operations with mocks
- Notifiers: State management logic

### Widget Tests
- Individual widgets with mocked providers
- User interactions and state changes

### Integration Tests
- Complete user flows
- Database persistence
- Golden tests for UI verification

## Performance Considerations

1. **Immutable State**: Prevents unnecessary rebuilds
2. **Lazy Loading**: Load data on demand
3. **Indexed Database**: Fast queries on large datasets
4. **Const Constructors**: Reduce widget rebuilds

## Security Considerations

1. **Input Validation**: Weight and rep limits
2. **SQL Injection**: Parameterized queries
3. **Data Privacy**: Local storage only

## Future Extensibility

The architecture supports:
- Cloud sync (add RemoteDataSource)
- Analytics (add AnalyticsRepository)
- Multiple themes (extend ThemeProvider)
- Exercise library (new feature module)
- Social features (add NetworkLayer)

## Dependencies

### Core
- `flutter_riverpod`: State management
- `go_router`: Navigation
- `freezed`: Immutable models
- `sqflite`: Local database

### Development
- `build_runner`: Code generation
- `mocktail`: Testing mocks
- `golden_toolkit`: UI testing

## Best Practices

1. **Single Responsibility**: Each class has one purpose
2. **Dependency Injection**: Via Riverpod providers
3. **Immutability**: All models are immutable
4. **Type Safety**: Strong typing throughout
5. **Error Handling**: Explicit error states
6. **Testing**: Comprehensive test coverage