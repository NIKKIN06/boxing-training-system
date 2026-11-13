/// Non-deterministic dependencies. Implementations are substituted only in the
/// composition root; no test endpoints or headers (stage 1, decision 5).
library;

/// Source of the current time (BDD-040: the search clock is substituted).
abstract interface class Clock {
  DateTime now();
}

/// Source of randomness for plan generation.
abstract interface class RandomSource {
  /// Uniform integer in `[0, max)`.
  int nextInt(int max);
}

/// Kind of a generated identifier.
enum EntityKind {
  /// Custom exercise; ids use the `custom-` prefix (T-57, human decision 3).
  customExercise,
  openPlan,
  planItem,
  trainingPlan,
  completedTraining,
}

/// Generator of new entity identifiers.
abstract interface class IdGenerator {
  String newId(EntityKind kind);
}
