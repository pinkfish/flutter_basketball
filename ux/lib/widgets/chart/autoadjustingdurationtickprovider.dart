import 'package:charts_common/common.dart';
import 'package:meta/meta.dart' show required;

import 'durationrangetickprovider.dart';
import 'durationrangetickproviderimpl.dart';
import 'durationscale.dart';
import 'incrementdurationstepper.dart';

/// Tick provider for date and time.
///
/// When determining the ticks for a given domain, the provider will use choose
/// one of the internal tick providers appropriate to the size of the data's
/// domain range.  It does this in an attempt to ensure there are at least 3
/// ticks, before jumping to the next more fine grain provider.  The 3 tick
/// minimum is not a hard rule as some of the ticks might be eliminated because
/// of collisions, but the data was within the targeted range.
///
/// Once a tick provider is chosen the selection of ticks is done by the child
/// tick provider.
class AutoAdjustingDurationTickProvider implements TickProvider<Duration> {
  /// List of tick providers to be selected from.
  final List<DurationRangeTickProvider> _potentialTickProviders;

  AutoAdjustingDurationTickProvider._internal(
      List<DurationRangeTickProvider> tickProviders)
      : _potentialTickProviders = tickProviders;

  /// Creates a default [AutoAdjustingDurationTickProvider] for day and time.
  factory AutoAdjustingDurationTickProvider.createDefault() {
    return AutoAdjustingDurationTickProvider._internal([
      createDayTickProvider(),
      createHourTickProvider(),
      createMinuteTickProvider(),
      createSecondTickProvider(),
    ]);
  }

  /// Creates [AutoAdjustingDurationTickProvider] with custom tick providers.
  ///
  /// [potentialTickProviders] must have at least one [DurationRangeTickProvider]
  /// and this list of tick providers are used in the order they are provided.
  factory AutoAdjustingDurationTickProvider.createWith(
      List<DurationRangeTickProvider> potentialTickProviders) {
    if (potentialTickProviders == null || potentialTickProviders.isEmpty) {
      throw ArgumentError('At least one DurationRangeTickProvider is required');
    }

    return AutoAdjustingDurationTickProvider._internal(potentialTickProviders);
  }

  /// Generates a list of ticks for the given data which should not collide
  /// unless the range is not large enough.
  @override
  List<Tick<Duration>> getTicks({
    @required ChartContext context,
    @required GraphicsFactory graphicsFactory,
    @required DurationScale scale,
    @required TickFormatter<Duration> formatter,
    @required Map<Duration, String> formatterValueCache,
    @required TickDrawStrategy tickDrawStrategy,
    @required AxisOrientation orientation,
    bool viewportExtensionEnabled = false,
    TickHint<Duration> tickHint,
  }) {
    List<DurationRangeTickProvider> tickProviders;

    /// If tick hint is provided, use the closest tick provider, otherwise
    /// look through the tick providers for one that provides sufficient ticks
    /// for the viewport.
    if (tickHint != null) {
      tickProviders = [_getClosestTickProvider(tickHint)];
    } else {
      tickProviders = _potentialTickProviders;
    }

    final lastTickProvider = tickProviders.last;

    final viewport = scale.viewportDomain;
    for (final tickProvider in tickProviders) {
      final isLastProvider = (tickProvider == lastTickProvider);
      if (isLastProvider ||
          tickProvider.providesSufficientTicksForRange(viewport)) {
        return tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: formatterValueCache,
          tickDrawStrategy: tickDrawStrategy,
          orientation: orientation,
        );
      }
    }

    return <Tick<Duration>>[];
  }

  /// Find the closest tick provider based on the tick hint.
  DurationRangeTickProvider _getClosestTickProvider(
      TickHint<Duration> tickHint) {
    final stepSize =
        ((tickHint.end.inMilliseconds - tickHint.start.inMilliseconds) ~/
            (tickHint.tickCount - 1));

    int minDifference;
    DurationRangeTickProvider closestTickProvider;

    for (final tickProvider in _potentialTickProviders) {
      final difference =
          (stepSize - tickProvider.getClosestStepSize(stepSize)).abs();
      if (minDifference == null || minDifference > difference) {
        minDifference = difference;
        closestTickProvider = tickProvider;
      }
    }

    return closestTickProvider;
  }

  static DurationRangeTickProvider createDayTickProvider() =>
      DurationRangeTickProviderImpl(DayDurationStepper());

  static DurationRangeTickProvider createHourTickProvider() =>
      DurationRangeTickProviderImpl(HourDurationStepper());

  static DurationRangeTickProvider createMinuteTickProvider() =>
      DurationRangeTickProviderImpl(MinuteDurationStepper());

  static DurationRangeTickProvider createSecondTickProvider() =>
      DurationRangeTickProviderImpl(SecondDurationStepper());
}
