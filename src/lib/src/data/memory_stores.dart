/// In-memory stores: open plans and the current session live only while the
/// server process runs (ADD-002 D-29; stage 1, decision 4).
/// The current session store — later group; it still throws [UnimplementedError].
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

final class InMemoryCurrentSessionStore implements CurrentSessionStore {
  @override
  CurrentSession? get() => throw UnimplementedError('CurrentSessionStore.get');

  @override
  void set(CurrentSession? session) =>
      throw UnimplementedError('CurrentSessionStore.set');
}
