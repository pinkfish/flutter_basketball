import 'package:charts_common/common.dart';

import 'durationtickformatterimpl.dart';

/// A [TickFormatter] that formats duration values based on minimum difference
/// between subsequent ticks.
///
/// This formatter assumes that the Tick values passed in are sorted in
/// increasing order.
///
/// This class is setup with a list of formatters that format the input ticks at
/// a given time resolution. The time resolution which will accurately display
/// the difference between 2 subsequent ticks is picked. Each time resolution
/// can be setup with a [TimeTickFormatter], which is used to format ticks as
/// regular or transition ticks based on whether the tick has crossed the time
/// boundary defined in the [TimeTickFormatter].
class DurationTickFormatter implements TickFormatter<Duration> {
  static const int SECOND = 1000;
  static const int MINUTE = 60 * SECOND;
  static const int HOUR = 60 * MINUTE;
  static const int DAY = 24 * HOUR;

  /// Used for the case when there is only one formatter.
  static const int ANY = -1;

  final Map<int, DurationFormatter> _timeFormatters;

  /// Creates a [DurationTickFormatter] that works well with time tick provider
  /// classes.
  ///
  /// The default formatter makes assumptions on border cases that time tick
  /// providers will still provide ticks that make sense. Example: Tick provider
  /// does not provide ticks with 23 hour intervals.  For custom tick providers
  /// where these assumptions are not correct, please create a custom
  /// [TickFormatter].
  factory DurationTickFormatter({Map<int, DurationFormatter> overrides}) {
    final Map<int, DurationFormatter> map = {
      SECOND: DurationFormatterImpl(
          tickFormat: 's',
          msPerTick: SECOND,
          msPerTransition: MINUTE,
          transitionFormat: ""),
      MINUTE: DurationFormatterImpl(
          tickFormat: 's',
          msPerTick: MINUTE,
          msPerTransition: HOUR,
          transitionFormat: ""),
      HOUR: DurationFormatterImpl(
          tickFormat: 's',
          msPerTick: HOUR,
          msPerTransition: DAY,
          transitionFormat: ""),
    };

    // Allow the user to override some of the defaults.
    if (overrides != null) {
      map.addAll(overrides);
    }

    return DurationTickFormatter._internal(map);
  }

  /// Creates a [DurationTickFormatter] that formats all ticks the same.
  ///
  /// Only use this formatter for data with fixed intervals, otherwise use the
  /// default, or build from scratch.
  ///
  /// [formatter] The format for all ticks.
  factory DurationTickFormatter.uniform(DurationFormatter formatter) {
    return DurationTickFormatter._internal({ANY: formatter});
  }

  /// Creates a [DurationTickFormatter] that formats ticks with [formatters].
  ///
  /// The formatters are expected to be provided with keys in increasing order.
  factory DurationTickFormatter.withFormatters(
      Map<int, DurationFormatter> formatters) {
    // Formatters must be non empty.
    if (formatters == null || formatters.isEmpty) {
      throw ArgumentError('At least one DurationFormatter is required.');
    }

    return DurationTickFormatter._internal(formatters);
  }

  DurationTickFormatter._internal(this._timeFormatters) {
    // If there is only one formatter, just use this one and skip this check.
    if (_timeFormatters.length == 1) {
      return;
    }
    _checkPositiveAndSorted(_timeFormatters.keys);
  }

  @override
  List<String> format(List<Duration> tickValues, Map<Duration, String> cache,
      {num stepSize}) {
    final tickLabels = <String>[];
    if (tickValues.isEmpty) {
      return tickLabels;
    }

    // Find the formatter that is the largest interval that has enough
    // resolution to describe the difference between ticks. If no such formatter
    // exists pick the highest res one.
    var formatter = _timeFormatters[_timeFormatters.keys.first];
    var formatterFound = false;
    if (_timeFormatters.keys.first == ANY) {
      formatterFound = true;
    } else {
      int minTimeBetweenTicks = stepSize.toInt();

      // TODO: Skip the formatter if the formatter's step size is
      // smaller than the minimum step size of the data.

      var keys = _timeFormatters.keys.iterator;
      while (keys.moveNext() && !formatterFound) {
        if (keys.current > minTimeBetweenTicks) {
          formatterFound = true;
        } else {
          formatter = _timeFormatters[keys.current];
        }
      }
    }

    // Format the ticks.
    final tickValuesIt = tickValues.iterator;

    var tickValue = (tickValuesIt..moveNext()).current;
    var prevTickValue = tickValue;
    tickLabels.add(formatter.formatFirstTick(tickValue));

    while (tickValuesIt.moveNext()) {
      tickValue = tickValuesIt.current;
      if (formatter.isTransition(tickValue, prevTickValue)) {
        tickLabels.add(formatter.formatTransitionTick(tickValue));
      } else {
        tickLabels.add(formatter.formatSimpleTick(tickValue));
      }
      prevTickValue = tickValue;
    }

    return tickLabels;
  }

  static void _checkPositiveAndSorted(Iterable<int> values) {
    final valuesIterator = values.iterator;
    var prev = (valuesIterator..moveNext()).current;
    var isSorted = true;

    // Only need to check the first value, because the values after are expected
    // to be greater.
    if (prev <= 0) {
      throw ArgumentError('Formatter keys must be positive');
    }

    while (valuesIterator.moveNext() && isSorted) {
      isSorted = prev < valuesIterator.current;
      prev = valuesIterator.current;
    }

    if (!isSorted) {
      throw ArgumentError(
          'Formatters must be sorted with keys in increasing order');
    }
  }
}

/// Formatter of [Duration] ticks
abstract class DurationFormatter {
  /// Format for tick that is the first in a set of ticks.
  String formatFirstTick(Duration date);

  /// Format for a 'simple' tick.
  ///
  /// Ex. Not a first tick or transition tick.
  String formatSimpleTick(Duration date);

  /// Format for a transitional tick.
  String formatTransitionTick(Duration date);

  /// Returns true if tick is a transitional tick.
  bool isTransition(Duration tickValue, Duration prevTickValue);
}
