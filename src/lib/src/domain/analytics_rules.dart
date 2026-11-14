/// Analytics rules (T-47; REQ-F-015, REQ-F-016; AC-F-015, AC-F-016; D-21,
/// D-22, ADD-002 D-35).
library;

import 'domain_error.dart';
import 'enums.dart';
import 'training.dart';

/// Calendar comparison of local dates.
int compareDates(LocalDate a, LocalDate b) {
  if (a.year != b.year) return a.year.compareTo(b.year);
  if (a.month != b.month) return a.month.compareTo(b.month);
  return a.day.compareTo(b.day);
}

LocalDate addDays(LocalDate d, int days) {
  final t = DateTime.utc(d.year, d.month, d.day).add(Duration(days: days));
  return LocalDate(t.year, t.month, t.day);
}

/// D-21: the default period — today and the previous days, 30 days in all.
const int defaultPeriodDays = 30;

/// AC-F-015, D-21, D-35: the period of [from] and [to] for [today] (the local
/// date of the device). Both absent → today and the 29 previous days; only
/// one of them → INVALID_PERIOD; `from` after `to` → INVALID_PERIOD; `to`
/// after today → END_DATE_IN_FUTURE. The length is not limited (D-21).
AnalyticsPeriod resolvePeriod(LocalDate? from, LocalDate? to, LocalDate today) {
  if (from == null && to == null) {
    return AnalyticsPeriod(
      from: addDays(today, -(defaultPeriodDays - 1)),
      to: today,
    );
  }
  if (from == null || to == null) {
    throw DomainError(
      ErrorCode.invalidPeriod,
      details: [
        if (from == null)
          // No identifier for a missing `from` in the contract: schema keyword.
          const ErrorDetail(field: 'from', constraint: Constraint.required)
        else
          const ErrorDetail(field: 'to', constraint: Constraint.requiredWithFrom),
      ],
    );
  }
  if (compareDates(from, to) > 0) {
    throw const DomainError(
      ErrorCode.invalidPeriod,
      details: [ErrorDetail(field: 'from', constraint: Constraint.notAfterTo)],
    );
  }
  if (compareDates(to, today) > 0) {
    throw const DomainError(
      ErrorCode.endDateInFuture,
      details: [ErrorDetail(field: 'to', constraint: Constraint.notAfterToday)],
    );
  }
  return AnalyticsPeriod(from: from, to: to);
}

/// AC-F-016, D-22: indicators of the completed [trainings] of [period] (the
/// day is the local start date). `dailyCounts` has every day of the period,
/// including 0; an exercise is counted once per training, whatever its
/// inclusions or variants; its name is the copy from the newest training of
/// the period that contains it.
Analytics computeAnalytics(
  AnalyticsPeriod period,
  List<CompletedTraining> trainings,
) {
  final perDay = <String, int>{};
  String key(LocalDate d) => '${d.year}-${d.month}-${d.day}';
  for (final t in trainings) {
    perDay.update(key(t.localStartDate), (n) => n + 1, ifAbsent: () => 1);
  }
  final daily = <DailyCount>[
    for (
      var d = period.from;
      compareDates(d, period.to) <= 0;
      d = addDays(d, 1)
    )
      DailyCount(date: d, count: perDay[key(d)] ?? 0),
  ];

  final ordered = List.of(trainings)
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  final counts = <String, int>{};
  final names = <String, String>{};
  for (final t in ordered) {
    final seen = <String>{};
    for (final s in t.executedPlan.stages) {
      for (final i in s.items) {
        // Later (newer) trainings overwrite the name (D-22).
        names[i.exerciseId] = i.exerciseName;
        if (seen.add(i.exerciseId)) {
          counts.update(i.exerciseId, (n) => n + 1, ifAbsent: () => 1);
        }
      }
    }
  }
  return Analytics(
    period: period,
    completedTrainingCount: trainings.length,
    dailyCounts: daily,
    exerciseFrequencies: [
      for (final e in counts.entries)
        ExerciseFrequency(
          exerciseId: e.key,
          exerciseName: names[e.key]!,
          trainingCount: e.value,
        ),
    ],
  );
}
