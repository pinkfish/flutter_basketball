import 'basedurationstepper.dart';

/// Hour stepper.
class IncrementDurationStepper extends BaseDurationStepper {
  final int millisecondsInIncrement;
  final int millisecondsInNextIncrement;
  final List<int> _allowedTickIncrements;

  IncrementDurationStepper(this._allowedTickIncrements,
      this.millisecondsInIncrement, this.millisecondsInNextIncrement)
      : super();

  @override
  int get typicalStepSizeMs => millisecondsInIncrement;

  @override
  List<int> get allowedTickIncrements => _allowedTickIncrements;

  /// Get the step time before or on the given [time] from [tickIncrement].
  ///
  /// Guarantee a step at the start of the next day.
  /// Ex. Time is Aug 20 10 AM, increment is 1 hour. Returns 10 AM.
  /// Ex. Time is Aug 20 6 AM, increment is 4 hours. Returns 4 AM.
  @override
  Duration getStepTimeBeforeInclusive(Duration time, int tickIncrement) {
    final int ticks = time.inMilliseconds ~/ millisecondsInIncrement;
    final int remainder = ticks % tickIncrement;

    final int rewindIncrement = remainder == 0 ? 0 : tickIncrement - remainder;
    final stepBefore = Duration(
        milliseconds:
            time.inMilliseconds - rewindIncrement * millisecondsInIncrement);

    return stepBefore;
  }

  /// Get next step time.
  ///
  /// [time] is expected to be a [DateTime] with the hour at start of the hour.
  @override
  Duration getNextStepTime(Duration time, int tickIncrement) {
    return Duration(
        milliseconds:
            time.inMilliseconds + tickIncrement * millisecondsInIncrement);
  }
}

const _millisecondsInMinute = 60 * 1000;
const _millisecondsInSecond = 1000;
const _millisecondsInHour = 60 * 60 * 1000;
const _millisecondsInDay = 24 * 60 * 60 * 1000;

class SecondDurationStepper extends IncrementDurationStepper {
  static const _defaultIncrements = [1, 2, 5, 10, 20, 30];

  SecondDurationStepper._internal(List<int> allowedTickIncrements)
      : super(allowedTickIncrements, _millisecondsInSecond,
            _millisecondsInMinute);

  factory SecondDurationStepper({List<int> allowedTickIncrements}) {
    // Set the default increments if null.
    allowedTickIncrements ??= _defaultIncrements;

    // Must have at least one increment option.
    assert(allowedTickIncrements.isNotEmpty);
    // All increments must be between 1 and 24 inclusive.
    assert(allowedTickIncrements.any((increment) => increment <= 0) == false);

    return SecondDurationStepper._internal(allowedTickIncrements);
  }
}

class MinuteDurationStepper extends IncrementDurationStepper {
  static const _defaultIncrements = [5, 10, 15, 20, 30];

  MinuteDurationStepper._internal(List<int> allowedTickIncrements)
      : super(
            allowedTickIncrements, _millisecondsInMinute, _millisecondsInHour);

  factory MinuteDurationStepper({List<int> allowedTickIncrements}) {
    // Set the default increments if null.
    allowedTickIncrements ??= _defaultIncrements;

    // Must have at least one increment option.
    assert(allowedTickIncrements.isNotEmpty);
    // All increments must be between 1 and 24 inclusive.
    assert(allowedTickIncrements.any((increment) => increment <= 0) == false);

    return MinuteDurationStepper._internal(allowedTickIncrements);
  }
}

class HourDurationStepper extends IncrementDurationStepper {
  static const _defaultIncrements = [5, 10, 15, 20, 30];

  HourDurationStepper._internal(List<int> allowedTickIncrements)
      : super(allowedTickIncrements, _millisecondsInHour, _millisecondsInDay);

  factory HourDurationStepper({List<int> allowedTickIncrements}) {
    // Set the default increments if null.
    allowedTickIncrements ??= _defaultIncrements;

    // Must have at least one increment option.
    assert(allowedTickIncrements.isNotEmpty);
    // All increments must be between 1 and 24 inclusive.
    assert(allowedTickIncrements.any((increment) => increment <= 0) == false);

    return HourDurationStepper._internal(allowedTickIncrements);
  }
}

class DayDurationStepper extends IncrementDurationStepper {
  static const _defaultIncrements = [5, 10, 15, 20, 30];

  DayDurationStepper._internal(List<int> allowedTickIncrements)
      : super(allowedTickIncrements, _millisecondsInDay,
            _millisecondsInDay * 100);

  factory DayDurationStepper({List<int> allowedTickIncrements}) {
    // Set the default increments if null.
    allowedTickIncrements ??= _defaultIncrements;

    // Must have at least one increment option.
    assert(allowedTickIncrements.isNotEmpty);
    // All increments must be between 1 and 24 inclusive.
    assert(allowedTickIncrements.any((increment) => increment <= 0) == false);

    return DayDurationStepper._internal(allowedTickIncrements);
  }
}
