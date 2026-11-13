/// Production implementations of the non-deterministic ports, wired only in the
/// composition root (stage 1, decision 5).
library;

import 'dart:math';

import '../ports/system_ports.dart';

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

final class SystemRandomSource implements RandomSource {
  SystemRandomSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}

/// `<prefix>-<32 hex digits>` from a secure random source, without extra
/// packages (T-57, human decision 3: custom exercises use `custom-`).
final class RandomIdGenerator implements IdGenerator {
  RandomIdGenerator([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  static const Map<EntityKind, String> prefixes = {
    EntityKind.customExercise: 'custom',
    EntityKind.variant: 'var',
    EntityKind.openPlan: 'open',
    EntityKind.planItem: 'item',
    EntityKind.trainingPlan: 'plan',
    EntityKind.completedTraining: 'training',
  };

  @override
  String newId(EntityKind kind) {
    final buffer = StringBuffer('${prefixes[kind]}-');
    for (var i = 0; i < 16; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
