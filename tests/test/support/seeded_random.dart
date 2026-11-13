/// Source of randomness with a fixed seed (REQ-NF-006, AC-NF-006, D-11):
/// plan generation is reproducible in tests. Passed only through `buildApp`.
library;

import 'dart:math';

import 'package:boxing_api/boxing_api.dart';

final class SeededRandom implements RandomSource {
  SeededRandom(this.seed) : _random = Random(seed);

  final int seed;
  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}

/// Fixed seeds for property tests of the generator (T-19, T-20; D-11).
const List<int> fixedSeeds = [1, 7, 42, 2026, 31337];
