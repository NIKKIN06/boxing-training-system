/// Current session, completed training and analytics (SRS §3, §4.3.5; REQ-F-012…REQ-F-016).
library;

import 'plan.dart';

/// Calendar date without time (schemas with `format: date`).
final class LocalDate {
  const LocalDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;
}

/// The local calendar date of [localTime].
LocalDate localDateOf(DateTime localTime) =>
    LocalDate(localTime.year, localTime.month, localTime.day);

/// Executed plan — refined composition and actual parameters (D-19; schema `ExecutedPlan`).
final class ExecutedPlan {
  const ExecutedPlan({required this.stages});

  final List<PlanStage> stages;
}

/// Current session, kept in memory only (stage 1, decision 4; schema `CurrentSession`).
final class CurrentSession {
  const CurrentSession({
    required this.startedAt,
    required this.localStartDate,
    required this.executedPlan,
  });

  final DateTime startedAt;
  final LocalDate localStartDate;
  final ExecutedPlan executedPlan;
}

/// Completed training (SRS §4.3.5; schema `CompletedTraining`).
final class CompletedTraining {
  const CompletedTraining({
    required this.id,
    required this.startedAt,
    required this.localStartDate,
    required this.executedPlan,
    required this.note,
  });

  final String id;
  final DateTime startedAt;
  final LocalDate localStartDate;
  final ExecutedPlan executedPlan;
  final String? note;
}

/// History list entry (schema `CompletedTrainingListItem`).
final class CompletedTrainingSummary {
  const CompletedTrainingSummary({required this.id, required this.startedAt});

  final String id;
  final DateTime startedAt;
}

/// Analytics period, both bounds inclusive (schema `AnalyticsPeriod`).
final class AnalyticsPeriod {
  const AnalyticsPeriod({required this.from, required this.to});

  final LocalDate from;
  final LocalDate to;
}

/// Trainings per day (schema `DailyCount`).
final class DailyCount {
  const DailyCount({required this.date, required this.count});

  final LocalDate date;
  final int count;
}

/// Exercise usage frequency (schema `ExerciseFrequency`).
final class ExerciseFrequency {
  const ExerciseFrequency({
    required this.exerciseId,
    required this.exerciseName,
    required this.trainingCount,
  });

  final String exerciseId;
  final String exerciseName;
  final int trainingCount;
}

/// Analytics for a period (schema `Analytics`).
final class Analytics {
  const Analytics({
    required this.period,
    required this.completedTrainingCount,
    required this.dailyCounts,
    required this.exerciseFrequencies,
  });

  final AnalyticsPeriod period;
  final int completedTrainingCount;
  final List<DailyCount> dailyCounts;
  final List<ExerciseFrequency> exerciseFrequencies;
}
