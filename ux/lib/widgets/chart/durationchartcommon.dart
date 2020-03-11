import 'dart:collection' show LinkedHashMap;

import 'package:charts_common/common.dart';

import 'durationaxis.dart';
import 'durationtimeaxisspec.dart';

class DurationChartCommon extends CartesianChart<Duration> {
  DurationChartCommon({
    bool vertical,
    LayoutConfig layoutConfig,
    NumericAxis primaryMeasureAxis,
    NumericAxis secondaryMeasureAxis,
    LinkedHashMap<String, NumericAxis> disjointMeasureAxes,
  }) : super(
            vertical: vertical,
            layoutConfig: layoutConfig,
            domainAxis: DurationAxis(),
            primaryMeasureAxis: primaryMeasureAxis,
            secondaryMeasureAxis: secondaryMeasureAxis,
            disjointMeasureAxes: disjointMeasureAxes);

  @override
  void initDomainAxis() {
    domainAxis.tickDrawStrategy = SmallTickRendererSpec<Duration>()
        .createDrawStrategy(context, graphicsFactory);
  }

  @override
  SeriesRenderer<Duration> makeDefaultRenderer() {
    return LineRenderer<Duration>()
      ..rendererId = SeriesRenderer.defaultRendererId;
  }

  @override
  Axis<Duration> createDomainAxisFromSpec(AxisSpec<Duration> axisSpec) {
    return (axisSpec as DurationAxisSpec).createDurationAxis();
  }
}
