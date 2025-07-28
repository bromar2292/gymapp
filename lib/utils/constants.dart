class AppConstants {
  AppConstants._();

  static const String databaseName = 'workout_tracker.db';
  static const int databaseVersion = 1;
  
  static const String workoutsTable = 'workouts';
  static const String workoutSetsTable = 'workout_sets';
  
  static const double minWeight = 0;
  static const double maxWeight = 500;
  static const int minReps = 1;
  static const int maxReps = 100;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDuration = Duration(milliseconds: 500);
}
