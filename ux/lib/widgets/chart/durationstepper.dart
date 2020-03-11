import 'durationextents.dart';

/// Represents the step/tick information for the given time range.
abstract class DurationStepper {
  /// Get new bounding extents to the ticks that would contain the given
  /// timeExtents.
  DurationExtents updateBoundingSteps(DurationExtents timeExtents);

  /// Returns the number steps/ticks are between the given extents inclusive.
  ///
  /// Does not extend the extents to the bounding ticks.
  int getStepCountBetween(DurationExtents timeExtents, int tickIncrement);

  /// Generates an Iterable for iterating over the time steps bounded by the
  /// given timeExtents. The desired tickIncrement can be set on the returned
  /// [TimeStepIteratorFactory].
  DurationStepIteratorFactory getSteps(DurationExtents timeExtents);

  /// Returns the typical stepSize for this stepper assuming increment by 1.
  int get typicalStepSizeMs;

  /// An ordered list of step increments that makes sense given the step.
  ///
  /// Example: hours may increment by 1, 2, 3, 4, 6, 12.  It doesn't make sense
  /// to increment hours by 7.
  List<int> get allowedTickIncrements;
}

/// Iterator with a reset function that can be used multiple times to avoid
/// object instantiation during the Android layout/draw phases.
abstract class DurationStepIterator extends Iterator<Duration> {
  /// Reset the iterator and set the tickIncrement to the specified value.
  ///
  /// This method is provided so that the same iterator instance can be used for
  /// different tick increments, avoiding object allocation during Android
  /// layout/draw phases.
  DurationStepIterator reset(int tickIncrement);
}

/// Factory that creates TimeStepIterator with the set tickIncrement value.
abstract class DurationStepIteratorFactory extends Iterable {
  /// Get iterator and optionally set the tickIncrement.
  @override
  DurationStepIterator get iterator;
}
