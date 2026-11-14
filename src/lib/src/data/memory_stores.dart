/// In-memory stores: open plans and the current session live only while the
/// server process runs (ADD-002 D-29; stage 1, decision 4).
library;

import '../domain/plan.dart';
import '../domain/training.dart';
import '../ports/repositories.dart';

final class InMemoryOpenPlanStore implements OpenPlanStore {
  final Map<String, OpenPlan> _plans = {};

  @override
  OpenPlan? findById(String id) => _plans[id];

  @override
  void put(OpenPlan plan) => _plans[plan.id] = plan;
}

/// The only current session; lost on a restart (D-18).
final class InMemoryCurrentSessionStore implements CurrentSessionStore {
  CurrentSession? _session;

  @override
  CurrentSession? get() => _session;

  @override
  void set(CurrentSession? session) => _session = session;
}
