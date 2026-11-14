/// Plan generator (T-39; REQ-F-006, REQ-F-008, REQ-F-009; SRS §5.1, §5.2,
/// §5.6, §5.7; D-06, D-10, D-11, D-12, D-13, D-25).
///
/// Algorithm (SRS §5.7 leaves it to the design):
/// 1. Candidates — variants eligible by §5.1 for at least one stage.
/// 2. Proven impossibility before the search: a stage without candidates
///    (NO_CANDIDATES_FOR_STAGE); the sum over stages of the smallest minimum
///    volume exceeds `1,1 × D` (MIN_VOLUME_ABOVE_UPPER_BOUND, D-10); the
///    maximum volume of all candidates, each used once, is below `0,9 × D`
///    (MAX_VOLUME_BELOW_LOWER_BOUND).
/// 3. Search over selections of one distinct variant per stage, in an order
///    shuffled by the injected random source (D-11). Before every selection
///    the injected clock is read; when at least 3,000 s have passed since the
///    start, the search stops with GENERATION_SEARCH_LIMIT_REACHED (D-13, D-25).
/// 4. For a selection: recommended values first; if the total is outside
///    `[0,9 × D; 1,1 × D]`, parameters are corrected within `[min; max]` of
///    each variant (D-10); the remaining candidates may be added once each
///    when the selection alone cannot reach the tolerance (§5.2: volume grows
///    through parameters, not duplicates). Reachable totals are computed
///    exactly, so a selection is rejected only when no parameters fit.
/// 5. All selections rejected → proven impossibility (PLAN_GENERATION_IMPOSSIBLE).
library;

import 'dart:math' as math;

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../domain/exercise.dart';
import '../domain/plan.dart';
import '../domain/plan_rules.dart';
import '../ports/system_ports.dart';

/// Technical search limit (D-13, D-25).
const Duration searchLimit = Duration(seconds: 3);

/// A variant eligible for automatic selection (SRS §5.1).
final class Candidate {
  Candidate(this.exercise, this.variant, this.stages);

  final Exercise exercise;
  final Variant variant;

  /// Stages for which the variant is eligible.
  final List<Stage> stages;
}

/// One selected plan item before identifiers are assigned.
typedef GeneratedItem = ({
  Candidate candidate,
  Stage stage,
  PlanItemParameters parameters,
});

/// A successful generation: items per stage in the fixed order (SRS §5.2).
final class GenerationResult {
  const GenerationResult(this.stages, this.checkedSelections);

  final Map<Stage, List<GeneratedItem>> stages;
  final int checkedSelections;
}

final class PlanGenerator {
  PlanGenerator({required this.clock, required this.random});

  final Clock clock;
  final RandomSource random;

  /// Throws [DomainError] PLAN_GENERATION_IMPOSSIBLE or
  /// GENERATION_SEARCH_LIMIT_REACHED.
  GenerationResult generate(
    List<Exercise> exercises,
    GenerationParameters params,
    int targetSeconds,
  ) {
    final tolerance = durationTolerance(targetSeconds);
    final lower = tolerance.minSeconds;
    final upper = tolerance.maxSeconds;

    final candidates = _candidates(exercises, params);
    final perStage = {
      for (final s in Stage.values)
        s: candidates.where((c) => c.stages.contains(s)).toList(),
    };
    _requireNoCandidateGap(perStage);
    final options = {for (final c in candidates) c: _Options(c.variant)};
    _requireVolumeWithinBounds(candidates, perStage, options, lower, upper);
    return _search(candidates, perStage, options, lower, upper);
  }

  /// Step 1 (T-38): variants eligible by §5.1 for at least one stage.
  static List<Candidate> _candidates(
    List<Exercise> exercises,
    GenerationParameters params,
  ) => [
    for (final e in exercises)
      for (final v in e.variants)
        if (Stage.values.where((s) => isEligible(e, v, s, params)).toList()
            case final stages when stages.isNotEmpty)
          Candidate(e, v, stages),
  ];

  /// Step 2 (AC-F-009): a stage without candidates.
  static void _requireNoCandidateGap(Map<Stage, List<Candidate>> perStage) {
    final emptyStages = [
      for (final s in Stage.values)
        if (perStage[s]!.isEmpty) s,
    ];
    if (emptyStages.isNotEmpty) {
      throw DomainError(
        ErrorCode.planGenerationImpossible,
        reasons: [
          for (final s in emptyStages)
            ImpossibilityReason(
              code: ImpossibilityReasonCode.noCandidatesForStage,
              stage: s,
            ),
        ],
      );
    }
  }

  /// Step 2 (AC-F-009, D-10): the smallest volume above `1,1 × D` or the
  /// largest one below `0,9 × D`.
  static void _requireVolumeWithinBounds(
    List<Candidate> candidates,
    Map<Stage, List<Candidate>> perStage,
    Map<Candidate, _Options> options,
    int lower,
    int upper,
  ) {
    final minVolume = Stage.values.fold(
      0,
      (sum, s) => sum + perStage[s]!.map((c) => options[c]!.minDuration).reduce(math.min),
    );
    if (minVolume > upper) {
      throw const DomainError(
        ErrorCode.planGenerationImpossible,
        reasons: [
          ImpossibilityReason(
            code: ImpossibilityReasonCode.minVolumeAboveUpperBound,
          ),
        ],
      );
    }
    final maxVolume = candidates.fold(
      0,
      (sum, c) => sum + options[c]!.maxDuration,
    );
    if (maxVolume < lower) {
      throw const DomainError(
        ErrorCode.planGenerationImpossible,
        reasons: [
          ImpossibilityReason(
            code: ImpossibilityReasonCode.maxVolumeBelowLowerBound,
          ),
        ],
      );
    }
  }

  /// Steps 3–5 (D-11, D-13, D-25): the search over selections.
  GenerationResult _search(
    List<Candidate> candidates,
    Map<Stage, List<Candidate>> perStage,
    Map<Candidate, _Options> options,
    int lower,
    int upper,
  ) {
    final start = clock.now();
    final orders = {for (final s in Stage.values) s: _shuffled(perStage[s]!)};
    final extraStage = {
      for (final c in candidates) c: c.stages[random.nextInt(c.stages.length)],
    };
    var checked = 0;
    for (final w in orders[Stage.warmUp]!) {
      for (final m in orders[Stage.main]!) {
        if (identical(m, w)) continue;
        for (final c in orders[Stage.coolDown]!) {
          if (identical(c, w) || identical(c, m)) continue;
          if (clock.now().difference(start) >= searchLimit) {
            throw DomainError(
              ErrorCode.generationSearchLimitReached,
              limitSeconds: searchLimit.inSeconds,
            );
          }
          checked++;
          final mandatory = [
            (candidate: w, stage: Stage.warmUp),
            (candidate: m, stage: Stage.main),
            (candidate: c, stage: Stage.coolDown),
          ];
          final extras = [
            for (final x in candidates)
              if (!identical(x, w) && !identical(x, m) && !identical(x, c))
                (candidate: x, stage: extraStage[x]!),
          ];
          final items = _fit(mandatory, extras, options, lower, upper);
          if (items != null) {
            return GenerationResult({
              for (final s in Stage.values)
                s: [
                  for (final i in items)
                    if (i.stage == s) i,
                ],
            }, checked);
          }
        }
      }
    }
    // 5. Every selection was checked: no admissible plan exists.
    throw const DomainError(ErrorCode.planGenerationImpossible);
  }

  List<T> _shuffled<T>(List<T> list) {
    final out = List.of(list);
    for (var i = out.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = out[i];
      out[i] = out[j];
      out[j] = tmp;
    }
    return out;
  }

  /// Step 4 for one selection; `null` when no parameters fit the tolerance.
  static List<GeneratedItem>? _fit(
    List<({Candidate candidate, Stage stage})> mandatory,
    List<({Candidate candidate, Stage stage})> extras,
    Map<Candidate, _Options> options,
    int lower,
    int upper,
  ) {
    // D-10: recommended values first.
    final recommended = mandatory.fold(
      0,
      (sum, x) => sum + options[x.candidate]!.recommendedDuration,
    );
    if (recommended >= lower && recommended <= upper) {
      return [
        for (final x in mandatory)
          (
            candidate: x.candidate,
            stage: x.stage,
            parameters: options[x.candidate]!.recommended,
          ),
      ];
    }

    // Exact reachable totals: mandatory items, then optional extras (0 = not added).
    final all = [...mandatory, ...extras];
    final prefixes = <List<_Range>>[
      const [(lo: 0, hi: 0)],
    ];
    for (var i = 0; i < all.length; i++) {
      final o = options[all[i].candidate]!;
      final ranges = i < mandatory.length
          ? o.ranges
          : [(lo: 0, hi: 0), ...o.ranges];
      prefixes.add(_sum(prefixes.last, ranges, upper));
    }
    final target = recommended < lower
        ? _smallestAtLeast(prefixes.last, lower, upper)
        : _largestAtMost(prefixes.last, lower, upper);
    if (target == null) return null;

    // Back from the last item: extras prefer not to be added, every item
    // prefers the duration closest to its recommended one (D-10).
    var rest = target;
    final chosen = List<int>.filled(all.length, 0);
    for (var i = all.length - 1; i >= 0; i--) {
      final o = options[all[i].candidate]!;
      final values = [if (i >= mandatory.length) 0, ...o.byCloseness];
      final value = values.firstWhere(
        (v) => rest - v >= 0 && _contains(prefixes[i], rest - v),
      );
      chosen[i] = value;
      rest -= value;
    }
    return [
      for (var i = 0; i < all.length; i++)
        if (chosen[i] > 0)
          (
            candidate: all[i].candidate,
            stage: all[i].stage,
            parameters: options[all[i].candidate]!.parametersFor(chosen[i]),
          ),
    ];
  }
}

typedef _Range = ({int lo, int hi});

/// Sums of two sets of integer ranges, capped at [cap], merged.
List<_Range> _sum(List<_Range> a, List<_Range> b, int cap) {
  final out = <_Range>[
    for (final x in a)
      for (final y in b)
        if (x.lo + y.lo <= cap) (lo: x.lo + y.lo, hi: math.min(x.hi + y.hi, cap)),
  ];
  return _merge(out);
}

List<_Range> _merge(List<_Range> ranges) {
  ranges.sort((x, y) => x.lo.compareTo(y.lo));
  final out = <_Range>[];
  for (final r in ranges) {
    if (out.isNotEmpty && r.lo <= out.last.hi + 1) {
      final last = out.removeLast();
      out.add((lo: last.lo, hi: math.max(last.hi, r.hi)));
    } else {
      out.add(r);
    }
  }
  return out;
}

bool _contains(List<_Range> ranges, int value) {
  var lo = 0;
  var hi = ranges.length - 1;
  while (lo <= hi) {
    final mid = (lo + hi) >> 1;
    final r = ranges[mid];
    if (value < r.lo) {
      hi = mid - 1;
    } else if (value > r.hi) {
      lo = mid + 1;
    } else {
      return true;
    }
  }
  return false;
}

int? _smallestAtLeast(List<_Range> ranges, int lower, int upper) {
  for (final r in ranges) {
    if (r.hi >= lower) {
      final v = math.max(r.lo, lower);
      return v <= upper ? v : null;
    }
  }
  return null;
}

int? _largestAtMost(List<_Range> ranges, int lower, int upper) {
  for (final r in ranges.reversed) {
    if (r.lo <= upper) {
      final v = math.min(r.hi, upper);
      return v >= lower ? v : null;
    }
  }
  return null;
}

/// Durations a variant can take within `[min; max]` of its parameters
/// (SRS §5.4, §5.7), and for each duration the parameters closest to the
/// recommended values.
final class _Options {
  _Options(this.variant)
    : recommended = _pick(variant.fields, (r) => r.recommended),
      minDuration = itemDurationSeconds(_pick(variant.fields, (r) => r.min)),
      maxDuration = itemDurationSeconds(_pick(variant.fields, (r) => r.max));

  final Variant variant;
  final PlanItemParameters recommended;

  /// §5.4 durations are non-decreasing in every parameter, so the bounds are
  /// the durations at all minimums and at all maximums.
  final int minDuration;
  final int maxDuration;

  int get recommendedDuration => itemDurationSeconds(recommended);

  Map<int, PlanItemParameters>? _best;

  Map<int, PlanItemParameters> get _byDuration => _best ??= _enumerate();

  late final List<_Range> ranges = _merge([
    for (final d in _byDuration.keys) (lo: d, hi: d),
  ]);

  late final List<int> byCloseness = _byDuration.keys.toList()
    ..sort((a, b) {
      final r = recommendedDuration;
      final c = (a - r).abs().compareTo((b - r).abs());
      return c != 0 ? c : a.compareTo(b);
    });

  PlanItemParameters parametersFor(int duration) => _byDuration[duration]!;

  Map<int, PlanItemParameters> _enumerate() {
    final best = <int, PlanItemParameters>{};
    final scores = <int, double>{};
    void offer(PlanItemParameters p, double score) {
      final d = itemDurationSeconds(p);
      final old = scores[d];
      if (old == null || score < old) {
        scores[d] = score;
        best[d] = p;
      }
    }

    switch (variant.fields) {
      case final TimeVariantFields f:
        for (var n = f.rounds.min; n <= f.rounds.max; n++) {
          for (var t = f.intervalSeconds.min; t <= f.intervalSeconds.max; t++) {
            for (final r in _rests(n, f.restSeconds)) {
              offer(
                TimeParameters(rounds: n, intervalSeconds: t, restSeconds: r),
                _gap(n, f.rounds) + _gap(t, f.intervalSeconds) + _gap(r, f.restSeconds),
              );
            }
          }
        }
      case final RepetitionsVariantFields f:
        for (var n = f.sets.min; n <= f.sets.max; n++) {
          for (var p = f.repetitions.min; p <= f.repetitions.max; p++) {
            for (final r in _rests(n, f.restSeconds)) {
              offer(
                RepetitionsParameters(
                  sets: n,
                  repetitions: p,
                  restSeconds: r,
                  repetitionTimeSeconds: f.repetitionTimeSeconds,
                ),
                _gap(n, f.sets) + _gap(p, f.repetitions) + _gap(r, f.restSeconds),
              );
            }
          }
        }
    }
    return best;
  }

  static double _gap(int value, ParameterRange range) =>
      (value - range.recommended).abs() / math.max(1, range.max - range.min);

  /// Rest values to try for [count] rounds or sets: with one round the rest
  /// does not change the duration (§5.4), so only the recommended one.
  static List<int> _rests(int count, ParameterRange rest) => count == 1
      ? [rest.recommended]
      : [for (var r = rest.min; r <= rest.max; r++) r];

  /// Parameters with one value of every range chosen by [pick] (the
  /// recommended values, all minimums or all maximums).
  static PlanItemParameters _pick(
    VariantFields f,
    int Function(ParameterRange) pick,
  ) => switch (f) {
    TimeVariantFields() => TimeParameters(
      rounds: pick(f.rounds),
      intervalSeconds: pick(f.intervalSeconds),
      restSeconds: pick(f.restSeconds),
    ),
    RepetitionsVariantFields() => RepetitionsParameters(
      sets: pick(f.sets),
      repetitions: pick(f.repetitions),
      restSeconds: pick(f.restSeconds),
      repetitionTimeSeconds: f.repetitionTimeSeconds,
    ),
  };
}
