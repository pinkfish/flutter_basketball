import 'package:basketballstats/widgets/chart/durationtickformatter.dart';
import 'package:charts_common/common.dart';
import 'package:meta/meta.dart' show immutable;

import 'autoadjustingdurationtickprovider.dart';
import 'durationaxis.dart';
import 'durationextents.dart';
import 'durationrangetickproviderimpl.dart';
import 'incrementdurationstepper.dart';
import 'simpledurationtickformatter.dart';

/// Generic [AxisSpec] specialized for Timeseries charts.
@immutable
class DurationAxisSpec extends AxisSpec<Duration> {
  /// Sets viewport for this Axis.
  ///
  /// If pan / zoom behaviors are set, this is the initial viewport.
  final DurationExtents viewport;

  /// Creates a [AxisSpec] that specialized for timeseries charts.
  ///
  /// [renderSpec] spec used to configure how the ticks and labels
  ///     actually render. Possible values are [GridlineRendererSpec],
  ///     [SmallTickRendererSpec] & [NoneRenderSpec]. Make sure that the <D>
  ///     given to the RenderSpec is of type [Duration] for Timeseries.
  /// [tickProviderSpec] spec used to configure what ticks are generated.
  /// [tickFormatterSpec] spec used to configure how the tick labels
  ///     are formatted.
  /// [showAxisLine] override to force the axis to draw the axis
  ///     line.
  const DurationAxisSpec({
    RenderSpec<Duration> renderSpec,
    DurationTickProviderSpec tickProviderSpec,
    DurationTickFormatterSpec tickFormatterSpec,
    bool showAxisLine,
    this.viewport,
  }) : super(
            renderSpec: renderSpec,
            tickProviderSpec: tickProviderSpec,
            tickFormatterSpec: tickFormatterSpec,
            showAxisLine: showAxisLine);

  @override
  void configure(Axis<Duration> axis, ChartContext context,
      GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);

    if (axis is DurationAxis && viewport != null) {
      axis.setScaleViewport(viewport);
    }
  }

  Axis<Duration> createAxis() {
    assert(false, 'Call createDurationAxis() to create a DurationAxis.');
    return null;
  }

  /// Creates a [DurationAxis]. This should be called in place of createAxis.
  DurationAxis createDurationAxis() => DurationAxis();

  @override
  bool operator ==(Object other) =>
      other is DurationAxisSpec &&
      viewport == other.viewport &&
      super == (other);

  @override
  int get hashCode {
    int hashcode = super.hashCode;
    hashcode = (hashcode * 37) + viewport.hashCode;
    return hashcode;
  }
}

abstract class DurationTickProviderSpec extends TickProviderSpec<Duration> {}

abstract class DurationTickFormatterSpec extends TickFormatterSpec<Duration> {}

/// [TickProviderSpec] that sets up the automatically assigned time ticks based
/// on the extents of your data.
@immutable
class AutoDurationTickProviderSpec implements DurationTickProviderSpec {
  /// Creates a [TickProviderSpec] that dynamically chooses ticks based on the
  /// extents of the data.
  ///
  const AutoDurationTickProviderSpec();

  @override
  AutoAdjustingDurationTickProvider createTickProvider(ChartContext context) {
    return AutoAdjustingDurationTickProvider.createDefault();
  }

  @override
  bool operator ==(Object other) => other is AutoDurationTickProviderSpec;

  @override
  int get hashCode => 0;
}

/// [TickProviderSpec] that sets up time ticks with days increments only.
@immutable
class DayTickProviderSpec implements DurationTickProviderSpec {
  final List<int> increments;

  const DayTickProviderSpec({this.increments});

  /// Creates a [TickProviderSpec] that dynamically chooses ticks based on the
  /// extents of the data, limited to day increments.
  ///
  /// [increments] specify the number of day increments that can be chosen from
  /// when searching for the appropriate tick intervals.
  @override
  AutoAdjustingDurationTickProvider createTickProvider(ChartContext context) {
    return AutoAdjustingDurationTickProvider.createWith([
      DurationRangeTickProviderImpl(
          DayDurationStepper(allowedTickIncrements: increments))
    ]);
  }

  @override
  bool operator ==(Object other) =>
      other is DayTickProviderSpec && increments == other.increments;

  @override
  int get hashCode => increments?.hashCode ?? 0;
}

/// [TickProviderSpec] that sets up time ticks at the two end points of the axis
/// range.
@immutable
class DurationEndPointsTickProviderSpec implements DurationTickProviderSpec {
  const DurationEndPointsTickProviderSpec();

  /// Creates a [TickProviderSpec] that dynamically chooses time ticks at the
  /// two end points of the axis range
  @override
  EndPointsTickProvider<Duration> createTickProvider(ChartContext context) {
    return EndPointsTickProvider<Duration>();
  }
}

/// [TickProviderSpec] that allows you to specific the ticks to be used.
@immutable
class StaticDurationTickProviderSpec implements DurationTickProviderSpec {
  final List<TickSpec<Duration>> tickSpecs;

  const StaticDurationTickProviderSpec(this.tickSpecs);

  @override
  StaticTickProvider<Duration> createTickProvider(ChartContext context) =>
      StaticTickProvider<Duration>(tickSpecs);

  @override
  bool operator ==(Object other) =>
      other is StaticDurationTickProviderSpec && tickSpecs == other.tickSpecs;

  @override
  int get hashCode => tickSpecs.hashCode;
}

/// A [DurationTickFormatterSpec] that accepts a [DateFormat] or a
/// [DurationFormatterFunction].
@immutable
class BasicDurationTickFormatterSpec implements DurationTickFormatterSpec {
  final DurationFormatterFunction formatter;

  const BasicDurationTickFormatterSpec(this.formatter);

  /// A formatter will be created with the [DateFormat] if it is not null.
  /// Otherwise, it will create one with the provided
  /// [DurationFormatterFunction].
  @override
  DurationTickFormatter createTickFormatter(ChartContext context) {
    return DurationTickFormatter.uniform(
        SimpleDurationTickFormatter(formatter: formatter));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BasicDurationTickFormatterSpec &&
            formatter == other.formatter);
  }

  @override
  int get hashCode {
    int hash = formatter.hashCode;
    hash = (hash * 37);
    return hash;
  }
}

class DurationFormatterSpec {}

/// [TickFormatterSpec] that automatically chooses the appropriate level of
/// formatting based on the tick stepSize. Each level of date granularity has
/// its own [TimeFormatterSpec] used to specify the formatting strings at that
/// level.
@immutable
class AutoDurationTickFormatterSpec implements DurationTickFormatterSpec {
  final DurationFormatterSpec minute;
  final DurationFormatterSpec hour;
  final DurationFormatterSpec day;

  /// Creates a [TickFormatterSpec] that automatically chooses the formatting
  /// given the individual [TimeFormatterSpec] formatters that are set.
  ///
  /// There is a default formatter for each level that is configurable, but
  /// by specifying a level here it replaces the default for that particular
  /// granularity. This is useful for swapping out one or all of the formatters.
  const AutoDurationTickFormatterSpec({this.minute, this.hour, this.day});

  @override
  DurationTickFormatter createTickFormatter(ChartContext context) {
    final Map<int, DurationFormatter> map = {};

    return DurationTickFormatter(overrides: map);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutoDurationTickFormatterSpec &&
          minute == other.minute &&
          hour == other.hour &&
          day == other.day);

  @override
  int get hashCode {
    int hashcode = minute?.hashCode ?? 0;
    hashcode = (hashcode * 37) + hour?.hashCode ?? 0;
    hashcode = (hashcode * 37) + day?.hashCode ?? 0;
    return hashcode;
  }
}
