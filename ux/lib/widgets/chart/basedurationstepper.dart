import 'durationextents.dart';
import 'durationstepper.dart';

/// A base stepper for operating with DurationFactory and time range steps.
abstract class BaseDurationStepper implements DurationStepper {
  _DurationStepIteratorFactoryImpl _stepsIterable;

  BaseDurationStepper();

  /// Get the step time before or on the given [time] from [tickIncrement].
  Duration getStepTimeBeforeInclusive(Duration time, int tickIncrement);

  /// Get the next step time after [time] from [tickIncrement].
  Duration getNextStepTime(Duration time, int tickIncrement);

  @override
  int getStepCountBetween(DurationExtents timeExtent, int tickIncrement) {
    checkTickIncrement(tickIncrement);
    final min = timeExtent.start;
    final max = timeExtent.end;
    var time = getStepTimeAfterInclusive(min, tickIncrement);

    var cnt = 0;
    while (time.compareTo(max) <= 0) {
      cnt++;
      time = getNextStepTime(time, tickIncrement);
    }
    return cnt;
  }

  @override
  DurationStepIteratorFactory getSteps(DurationExtents timeExtent) {
    // Keep the steps iterable unless time extent changes, so the same iterator
    // can be used and reset for different increments.
    if (_stepsIterable == null || _stepsIterable.timeExtent != timeExtent) {
      _stepsIterable = _DurationStepIteratorFactoryImpl(timeExtent, this);
    }
    return _stepsIterable;
  }

  @override
  DurationExtents updateBoundingSteps(DurationExtents timeExtent) {
    final stepBefore = getStepTimeBeforeInclusive(timeExtent.start, 1);
    final stepAfter = getStepTimeAfterInclusive(timeExtent.end, 1);

    return DurationExtents(start: stepBefore, end: stepAfter);
  }

  Duration getStepTimeAfterInclusive(Duration time, int tickIncrement) {
    final boundedStart = getStepTimeBeforeInclusive(time, tickIncrement);
    if (boundedStart.inMilliseconds == time.inMilliseconds) {
      return boundedStart;
    }
    return getNextStepTime(boundedStart, tickIncrement);
  }
}

class _DurationStepIteratorImpl implements DurationStepIterator {
  final Duration extentStartTime;
  final Duration extentEndTime;
  final BaseDurationStepper stepper;
  Duration _current;
  int _tickIncrement = 1;

  _DurationStepIteratorImpl(
      this.extentStartTime, this.extentEndTime, this.stepper) {
    reset(_tickIncrement);
  }

  @override
  bool moveNext() {
    if (_current == null) {
      _current =
          stepper.getStepTimeAfterInclusive(extentStartTime, _tickIncrement);
    } else {
      _current = stepper.getNextStepTime(_current, _tickIncrement);
    }

    return _current.compareTo(extentEndTime) <= 0;
  }

  @override
  Duration get current => _current;

  @override
  DurationStepIterator reset(int tickIncrement) {
    checkTickIncrement(tickIncrement);
    _tickIncrement = tickIncrement;
    _current = null;
    return this;
  }
}

class _DurationStepIteratorFactoryImpl extends DurationStepIteratorFactory {
  final DurationExtents timeExtent;
  final _DurationStepIteratorImpl _timeStepIterator;

  _DurationStepIteratorFactoryImpl._internal(
      _DurationStepIteratorImpl timeStepIterator, this.timeExtent)
      : _timeStepIterator = timeStepIterator;

  factory _DurationStepIteratorFactoryImpl(
      DurationExtents timeExtent, BaseDurationStepper stepper) {
    final startTime = timeExtent.start;
    final endTime = timeExtent.end;
    return _DurationStepIteratorFactoryImpl._internal(
        _DurationStepIteratorImpl(startTime, endTime, stepper), timeExtent);
  }

  @override
  DurationStepIterator get iterator => _timeStepIterator;
}

void checkTickIncrement(int tickIncrement) {
  /// tickIncrement must be greater than 0
  assert(tickIncrement > 0);
}
