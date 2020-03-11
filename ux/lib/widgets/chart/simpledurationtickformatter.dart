import 'package:meta/meta.dart';

import 'durationtickformatter.dart';

typedef DurationFormatterFunction = String Function(Duration datetime);

/// Formatter that formats all ticks using a single [DurationFormatterFunction].
class SimpleDurationTickFormatter implements DurationFormatter {
  DurationFormatterFunction formatter;

  SimpleDurationTickFormatter({@required this.formatter});

  @override
  String formatFirstTick(Duration date) => formatter(date);

  @override
  String formatSimpleTick(Duration date) => formatter(date);

  @override
  String formatTransitionTick(Duration date) => formatter(date);

  // Transition fields don't matter here.
  @override
  bool isTransition(Duration tickValue, Duration prevTickValue) => false;
}
