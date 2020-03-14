import 'package:flutter/material.dart';

import 'durationtickformatter.dart';

/// Formatter that can format simple and transition time ticks differently.
class DurationFormatterImpl implements DurationFormatter {
  final int msPerTick;
  final int msPerTransition;
  final String transitionFormat;
  final String tickFormat;

  /// Create time tick formatter.
  ///
  /// [dateTimeFactory] factory to use to generate the [DateFormat].
  /// [simpleFormat] format to use for most ticks.
  /// [transitionFormat] format to use when the time unit transitions.
  /// For example showing the month with the date for Jan 1.
  /// [transitionField] the calendar field that indicates transition.
  DurationFormatterImpl(
      {@required this.msPerTick,
      @required this.tickFormat,
      @required this.msPerTransition,
      @required this.transitionFormat});

  String twoDigits(int num) {
    if (num < 10) {
      return "0" + num.toString();
    }
    return num.toString();
  }

  @override
  String formatFirstTick(Duration date) =>
      (date.inMilliseconds ~/ msPerTransition > 0
          ? twoDigits(date.inMilliseconds ~/ msPerTransition) +
              transitionFormat +
              ":" +
              twoDigits(date.inMilliseconds ~/ msPerTick) +
              tickFormat
          : (date.inMilliseconds ~/ msPerTick).toString() + tickFormat);

  @override
  String formatSimpleTick(Duration date) =>
      (date.inMilliseconds ~/ msPerTick).toString() + tickFormat;

  @override
  String formatTransitionTick(Duration date) =>
      date.inMilliseconds ~/ msPerTransition > 0
          ? twoDigits(date.inMilliseconds ~/ msPerTransition) + transitionFormat
          : (date.inMilliseconds ~/ msPerTransition).toString() +
              transitionFormat;

  @override
  bool isTransition(Duration tickValue, Duration prevTickValue) {
    // Transition is always false if no transition field is specified.
    if (msPerTransition == 0) {
      return false;
    }
    final prevTransitionFieldValue =
        prevTickValue.inMilliseconds ~/ msPerTransition;
    final transitionFieldValue = tickValue.inMilliseconds ~/ msPerTransition;
    return prevTransitionFieldValue != transitionFieldValue;
  }
}
