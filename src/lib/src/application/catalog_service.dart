/// Catalog and shared dictionaries (REQ-F-001…REQ-F-004; T-30, T-32, T-33).
library;

import 'package:logging/logging.dart';

import '../domain/catalog.dart';
import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/exercise_validation.dart';
import '../logging/app_logging.dart';
import '../ports/repositories.dart';
import '../ports/system_ports.dart';
import 'storage_write.dart';

final Logger _log = Logger(LogNames.catalog);

final class CatalogService {
  CatalogService({
    required this.exercises,
    required this.catalogSource,
    required this.ids,
  });

  final ExerciseRepository exercises;
  final CatalogSource catalogSource;
  final IdGenerator ids;

  /// Dictionaries of the supplied catalog, set by [initialize].
  Map<DictionaryName, Dictionary> _dictionaries = const {};

  /// T-32: idempotent initialization of the supplied catalog at start
  /// (BDD-001, AC-F-001, AC-NF-001; D-06). The catalog is installed only when
  /// its version differs from the installed one, so a repeated start of the
  /// same version writes nothing and adds no duplicates.
  Future<void> initialize() async {
    final data = await catalogSource.load();
    _dictionaries = {for (final d in data.dictionaries) d.name: d};
    final installed = await exercises.installedCatalogVersion();
    if (installed == data.catalogVersion) {
      _log.info(
        'catalog up to date version=${data.catalogVersion} '
        'placeholder=${data.placeholder}',
      );
      return;
    }
    final deprecated = await exercises.installCatalog(
      data.catalogVersion,
      data.exercises,
    );
    _log.info(
      'catalog installed version=${data.catalogVersion} '
      'previous=${installed ?? '-'} placeholder=${data.placeholder} '
      'initial=${data.exercises.length} '
      'markedDeprecated=[${deprecated.join(',')}]',
    );
  }

  /// operationId `listExercises` (REQ-F-001, REQ-F-003; AC-F-003, D-06, D-09,
  /// D-34; ADD-003 D-36…D-39). The search value is not logged (ADD-003 D-40).
  Future<List<ExerciseSummary>> listExercises(ExerciseFilter filter) async {
    _checkDictionaryValues(filter);
    final search = filter.nameContains?.toLowerCase();
    final all = await exercises.findAll();
    final items = [
      for (final e in all)
        if (!e.deprecated && _matches(e, filter) && _matchesName(e, search))
          ExerciseSummary(id: e.id, name: e.name, type: e.type, origin: e.origin),
    ];
    _log.info(
      'exercises listed count=${items.length} search=${search != null}',
    );
    return items;
  }

  /// operationId `createExercise` (REQ-F-002, REQ-F-004; AC-F-002, D-05, D-07, D-08).
  Future<Exercise> createExercise(ExerciseInput input) async {
    _validate(input);
    final exercise = _build(
      id: ids.newId(EntityKind.customExercise),
      input: input,
      variants: [
        for (final v in input.variants)
          Variant(id: ids.newId(EntityKind.variant), fields: v.fields),
      ],
    );
    await guardStorageWrite(() => exercises.insert(exercise));
    _log.info(
      'exercise created id=${exercise.id} variants=${exercise.variants.length}',
    );
    return exercise;
  }

  /// operationId `getExercise` (REQ-F-002, REQ-F-004; D-06: deprecated too).
  Future<Exercise> getExercise(String exerciseId) async {
    final exercise = await exercises.findById(exerciseId);
    if (exercise == null) throw const DomainError(ErrorCode.notFound);
    return exercise;
  }

  /// operationId `updateExercise`: full atomic replacement of a custom
  /// exercise (REQ-F-002; AC-F-002, D-05, ADD-002 D-33).
  Future<Exercise> updateExercise(String exerciseId, ExerciseInput input) async {
    final stored = await exercises.findById(exerciseId);
    if (stored == null) throw const DomainError(ErrorCode.notFound);
    if (stored.origin == Origin.initial) {
      throw const DomainError(ErrorCode.initialExerciseReadOnly);
    }
    _validate(input);

    // D-33: a stored variant passed with its id keeps it; a variant without
    // an id (or with an id the exercise does not have) is new; a variant
    // missing from the body is removed.
    final storedIds = {for (final v in stored.variants) v.id};
    final kept = <String>{};
    final variants = <Variant>[];
    for (final v in input.variants) {
      final id = v.id;
      if (id != null && storedIds.contains(id) && kept.add(id)) {
        variants.add(Variant(id: id, fields: v.fields));
      } else {
        variants.add(Variant(id: ids.newId(EntityKind.variant), fields: v.fields));
      }
    }
    final exercise = _build(id: stored.id, input: input, variants: variants);
    await guardStorageWrite(() => exercises.update(exercise));
    _log.info(
      'exercise updated id=${exercise.id} variants=${variants.length} '
      'kept=${kept.length} added=${variants.length - kept.length} '
      'removed=${storedIds.length - kept.length}',
    );
    return exercise;
  }

  /// operationId `getDictionary` (REQ-F-003, REQ-F-005; SRS §4.4).
  Future<Dictionary> getDictionary(DictionaryName name) async {
    final dictionary = _dictionaries[name];
    if (dictionary == null) throw const DomainError(ErrorCode.notFound);
    return dictionary;
  }

  void _validate(ExerciseInput input) {
    final details = validateExerciseInput(input);
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.validationFailed, details: details);
    }
  }

  /// D-05: a custom exercise has origin `custom` and is never deprecated.
  static Exercise _build({
    required String id,
    required ExerciseInput input,
    required List<Variant> variants,
  }) => Exercise(
    id: id,
    name: input.name,
    description: input.description,
    origin: Origin.custom,
    type: input.type,
    allowedStages: input.allowedStages,
    allowedLevels: input.allowedLevels,
    allowedIntensities: input.allowedIntensities,
    emphases: input.emphases,
    loadCharacter: input.loadCharacter,
    variants: variants,
    videoUrl: input.videoUrl,
    videoAuthorName: input.videoAuthorName,
    authorPageUrl: input.authorPageUrl,
    deprecated: false,
  );

  /// NEG-05: filter values must exist in the shared dictionaries (SRS §4.4).
  void _checkDictionaryValues(ExerciseFilter filter) {
    final checks = <(String, DictionaryName, List<String>)>[
      ('level', DictionaryName.trainingLevels, filter.levels),
      ('intensity', DictionaryName.intensities, filter.intensities),
      ('emphasis', DictionaryName.emphases, filter.emphases),
      ('executionMeans', DictionaryName.executionMeans, filter.executionMeans),
      ('equipment', DictionaryName.equipment, filter.equipment),
    ];
    final details = <ErrorDetail>[];
    for (final (field, name, values) in checks) {
      final known = {...?_dictionaries[name]?.values.map((v) => v.id)};
      if (values.any((v) => !known.contains(v))) {
        details.add(
          ErrorDetail(field: field, constraint: Constraint.dictionaryValue),
        );
      }
    }
    if (details.isNotEmpty) {
      throw DomainError(ErrorCode.unknownDictionaryValue, details: details);
    }
  }

  /// ADD-003 D-36, D-37: [search] (already lower-cased) is a substring of the
  /// lower-cased name; the description is not used. `null` — no search.
  static bool _matchesName(Exercise e, String? search) =>
      search == null || e.name.toLowerCase().contains(search);

  /// AC-F-003, D-09: «OR» within one attribute, «AND» across attributes.
  static bool _matches(Exercise e, ExerciseFilter f) {
    bool any<T>(List<T> wanted, List<T> actual) =>
        wanted.isEmpty || wanted.any(actual.contains);

    if (!any(f.stages, e.allowedStages)) return false;
    if (f.types.isNotEmpty && !f.types.contains(e.type)) return false;
    if (!any(f.levels, e.allowedLevels)) return false;
    if (!any(f.intensities, e.allowedIntensities)) return false;
    if (!any(f.emphases, e.emphases)) return false;
    // D-09, ADD-002 D-34: with the filter set, `not-applicable` is never shown.
    if (f.loadCharacters.isNotEmpty &&
        (e.loadCharacter == LoadCharacter.notApplicable ||
            !f.loadCharacters.contains(e.loadCharacter))) {
      return false;
    }
    // AC-F-003: execution means and equipment are satisfied by one variant;
    // equipment means «the variant uses this equipment».
    if (f.executionMeans.isEmpty && f.equipment.isEmpty) return true;
    return e.variants.any(
      (v) =>
          (f.executionMeans.isEmpty ||
              f.executionMeans.contains(v.fields.executionMeans)) &&
          any(f.equipment, v.fields.equipment),
    );
  }
}
