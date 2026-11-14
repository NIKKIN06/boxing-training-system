/// Drift schema of persistent data (CON-001; REQ-NF-002, REQ-NF-003, REQ-NF-004).
///
/// Persisted: catalog exercises, saved plans, completed trainings. Open plans and
/// the current session are not persisted (ADD-002 D-29; stage 1, decision 4).
/// Nested structures (variants, plan stages, executed plan) are stored as JSON
/// copies, so saved data does not depend on later catalog edits (SRS §4.5).
library;

import 'package:drift/drift.dart';

part 'database.g.dart';

/// Catalog exercise, initial or custom (SRS §4.3.1).
@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();

  /// `initial` | `custom`.
  TextColumn get origin => text()();

  /// `simple` | `single-punch` | `combination`.
  TextColumn get type => text()();

  /// JSON array of stage wire values.
  TextColumn get allowedStagesJson => text()();

  /// JSON arrays of dictionary ids.
  TextColumn get allowedLevelsJson => text()();
  TextColumn get allowedIntensitiesJson => text()();
  TextColumn get emphasesJson => text()();

  /// `general-physical` | `special-physical` | `not-applicable` (D-34).
  TextColumn get loadCharacter => text()();

  /// JSON array of variants with ids stable within the exercise (D-33).
  TextColumn get variantsJson => text()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get videoAuthorName => text().nullable()();
  TextColumn get authorPageUrl => text().nullable()();

  /// Deprecated initial exercise (D-06).
  BoolColumn get deprecated => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Key–value metadata of the installed supplied catalog (SRS §4.4, D-06).
@DataClassName('CatalogMetaRow')
class CatalogMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Saved training plan (SRS §4.3.6; D-14, D-16).
@DataClassName('TrainingPlanRow')
class TrainingPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Set on successful save or overwrite (SPEC-GATE v1.1, REV-009).
  DateTimeColumn get modifiedAt => dateTime()();

  /// JSON of the five generation parameters (D-14, D-31).
  TextColumn get generationParametersJson => text()();

  /// JSON of three stages with item copies (SRS §4.5).
  TextColumn get stagesJson => text()();

  /// JSON of the warnings at the moment of saving (AC-F-010, BDD-014): they
  /// are not recomputed from the catalog, so a catalog update does not
  /// rewrite a saved plan (AC-F-011, D-06).
  TextColumn get warningsJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Completed training (SRS §4.3.5).
@DataClassName('CompletedTrainingRow')
class CompletedTrainings extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();

  /// Local start date `YYYY-MM-DD` for analytics grouping.
  TextColumn get localStartDate => text()();

  /// JSON copy of the executed plan (D-19, D-20).
  TextColumn get executedPlanJson => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Exercises, CatalogMeta, TrainingPlans, CompletedTrainings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
