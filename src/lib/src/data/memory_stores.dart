/// In-memory stores: open plans and the current session live only while the
/// server process runs (ADD-002 D-29; stage 1, decision 4).
/// T-10 skeleton: signatures only, every method throws [UnimplementedError].
library;

import '../domain/plan.dart';
import '../domain/training.dart';
import '../ports/repositories.dart';

final class InMemoryOpenPlanStore implements OpenPlanStore {
  @override
  OpenPlan? findById(String id) =>
      throw UnimplementedError('OpenPlanStore.findById');

  @override
  void put(OpenPlan plan) => throw UnimplementedError('OpenPlanStore.put');
}

final class InMemoryCurrentSessionStore implements CurrentSessionStore {
  @override
  CurrentSession? get() => throw UnimplementedError('CurrentSessionStore.get');

  @override
  void set(CurrentSession? session) =>
      throw UnimplementedError('CurrentSessionStore.set');
}
