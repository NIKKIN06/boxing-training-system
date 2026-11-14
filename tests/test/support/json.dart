/// JSON access helpers and oracles derived from the SRS (not from the code).
///
/// - item duration — SRS §5.4 (time: `n × t + (n − 1) × r`;
///   repetitions: `n × p × e + (n − 1) × r`);
/// - stage order — SRS §5.2 (warm-up, main, cool-down);
/// - target duration — SRS §5.5 (`D = h × 3600 + m × 60`), tolerance §5.6.
library;

typedef Json = Map<String, Object?>;

/// Typed access to decoded JSON values (strict casts, no dynamic calls).
extension JsonAccess on Object? {
  Json get asJson => this! as Json;
  List<Object?> get asList => this! as List<Object?>;
  List<Json> get asJsonList => asList.map((e) => e.asJson).toList();
  String get asString => this! as String;
  String? get asStringOrNull => this as String?;
  int get asInt => this! as int;
  bool get asBool => this! as bool;
}

/// Fixed order of stages (SRS §5.2).
const List<String> stageOrder = ['warm-up', 'main', 'cool-down'];

/// Stage names of a plan or an executed plan, in response order.
List<String> stagesOf(Json planLike) =>
    planLike['stages'].asJsonList.map((s) => s['stage'].asString).toList();

/// Items of one stage of a plan or an executed plan.
List<Json> stageItems(Json planLike, String stage) => planLike['stages']
    .asJsonList
    .firstWhere((s) => s['stage'] == stage)['items']
    .asJsonList;

/// All items of a plan or an executed plan in stage order.
List<Json> allItems(Json planLike) => [
  for (final stage in planLike['stages'].asJsonList) ...stage['items'].asJsonList,
];

/// The item with [itemId].
Json itemById(Json planLike, String itemId) =>
    allItems(planLike).firstWhere((i) => i['id'] == itemId);

/// SRS §5.4: duration of one plan item from its parameters, in seconds.
int expectedItemDuration(Json item) {
  final p = item['parameters'].asJson;
  final mode = item['variant'].asJson['mode'].asString;
  if (mode == 'time') {
    final n = p['rounds'].asInt;
    return n * p['intervalSeconds'].asInt + (n - 1) * p['restSeconds'].asInt;
  }
  final n = p['sets'].asInt;
  final e = item['variant'].asJson['repetitionTimeSeconds'].asInt;
  return n * p['repetitions'].asInt * e + (n - 1) * p['restSeconds'].asInt;
}

/// SRS §5.4: total duration is the sum of item durations.
int expectedPlanDuration(Json planLike) =>
    allItems(planLike).fold(0, (sum, item) => sum + expectedItemDuration(item));

/// SRS §5.5: `D = h × 3600 + m × 60`.
int targetSeconds(int hours, int minutes) => hours * 3600 + minutes * 60;

/// Plan composition without generated identifiers (D-11 reproducibility).
List<Json> composition(Json planLike) => [
  for (final item in allItems(planLike))
    {
      'stage': item['stage'],
      'position': item['position'],
      'exerciseId': item['exerciseId'],
      'variantId': item['variant'].asJson['id'],
      'parameters': item['parameters'],
    },
];

/// Stages with copies of items but without item ids (an opened, saved or
/// executed copy may have its own item ids).
List<Json> stagesWithoutIds(Json planLike) => [
  for (final stage in planLike['stages'].asJsonList)
    {
      'stage': stage['stage'],
      'items': [
        for (final item in stage['items'].asJsonList) Map.of(item)..remove('id'),
      ],
    },
];

/// Warnings of a plan as comparable strings `code|itemId|stage|attribute`.
Set<String> warningKeys(Json plan) => {
  for (final w in plan['warnings'].asJsonList)
    '${w['code']}|${w['itemId'] ?? ''}|${w['stage'] ?? ''}|${w['attribute'] ?? ''}',
};

/// Warning codes of a plan.
List<String> warningCodes(Json plan) =>
    plan['warnings'].asJsonList.map((w) => w['code'].asString).toList();

/// `YYYY-MM-DD` of a local date.
String isoDate(DateTime local) =>
    '${local.year.toString().padLeft(4, '0')}-'
    '${local.month.toString().padLeft(2, '0')}-'
    '${local.day.toString().padLeft(2, '0')}';
