import 'package:gymapp/utils/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = join(databasesPath, AppConstants.databaseName);

    return openDatabase(
      databasePath,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabaseSchema,
    );
  }

  Future<void> _createDatabaseSchema(Database database, int version) async {
    await _createWorkoutsTable(database);
    await _createWorkoutSetsTable(database);
    await _createDatabaseIndexes(database);
  }

  Future<void> _createWorkoutsTable(Database database) async {
    await database.execute('''
      CREATE TABLE ${AppConstants.workoutsTable} (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<void> _createWorkoutSetsTable(Database database) async {
    await database.execute('''
      CREATE TABLE ${AppConstants.workoutSetsTable} (
        id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        exercise TEXT NOT NULL,
        weight_kg REAL NOT NULL,
        reps INTEGER NOT NULL,
        set_order INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES ${AppConstants.workoutsTable} (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createDatabaseIndexes(Database database) async {
    await database.execute('''
      CREATE INDEX idx_workout_sets_workout_id 
      ON ${AppConstants.workoutSetsTable}(workout_id)
    ''');
    
    await database.execute('''
      CREATE INDEX idx_workouts_created_at 
      ON ${AppConstants.workoutsTable}(created_at)
    ''');
  }
}
