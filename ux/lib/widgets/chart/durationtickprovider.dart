import 'package:charts_common/common.dart';

import 'durationextents.dart';

/// Provides ticks for a particular time unit.
///
/// Used by [AutoAdjustingDateTimeTickProvider].
abstract class DurationTickProvider extends BaseTickProvider<Duration> {
  /// Returns if this tick provider will produce a sufficient number of ticks
  /// for [domainExtents].
  bool providesSufficientTicksForRange(DurationExtents domainExtents);

  /// Find the closet step size, from provided step size, in milliseconds.
  int getClosestStepSize(int stepSize);
}
