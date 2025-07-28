enum Exercise {
  barbellRow('Barbell Row'),
  benchPress('Bench Press'),
  shoulerPress('Shoudler Press'),
  deadlift('Deadlift'),
  squat('Squat');

  const Exercise(this.displayName);

  final String displayName;

  static Exercise fromString(String value) {
    return Exercise.values.firstWhere(
      (exercise) => exercise.name == value,
      orElse: () => throw ArgumentError('Invalid exercise: $value'),
    );
  }
}
