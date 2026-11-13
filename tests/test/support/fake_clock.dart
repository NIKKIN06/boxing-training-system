/// Substituted clock (REQ-NF-006, D-11; stage 1, decision 5): tests never use
/// the real time. It is passed to the application only through `buildApp`.
library;

import 'package:boxing_api/boxing_api.dart';

final class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;
  _SearchScript? _script;

  /// Number of readings since construction.
  int readings = 0;

  @override
  DateTime now() {
    readings++;
    final script = _script;
    return script == null ? _now : script.next();
  }

  /// Sets the current local time.
  void set(DateTime localTime) => _now = localTime;

  /// Moves the current time forward.
  void advance(Duration duration) => _now = _now.add(duration);

  DateTime get current => _now;

  /// BDD-040, D-25: scripted readings of one search. The first reading after
  /// arming is the search start (current time); the next [firstCount] readings
  /// return start + [first]; all later readings return start + [then].
  void armSearch({
    required Duration first,
    required int firstCount,
    required Duration then,
  }) {
    _script = _SearchScript(_now, first, firstCount, then);
  }

  /// Largest elapsed time served by the armed script, `null` when unarmed.
  Duration? get maxElapsedServed => _script?.maxServed;

  /// Number of readings served by the armed script, `0` when unarmed.
  int get scriptedReadings => _script?.served ?? 0;

  /// Stops the script; the clock returns the current time again.
  void disarm() => _script = null;
}

final class _SearchScript {
  _SearchScript(this.start, this.first, this.firstCount, this.then);

  final DateTime start;
  final Duration first;
  final int firstCount;
  final Duration then;
  int served = 0;
  Duration maxServed = Duration.zero;

  DateTime next() {
    final Duration elapsed;
    if (served == 0) {
      elapsed = Duration.zero;
    } else if (served <= firstCount) {
      elapsed = first;
    } else {
      elapsed = then;
    }
    served++;
    if (elapsed > maxServed) maxServed = elapsed;
    return start.add(elapsed);
  }
}
