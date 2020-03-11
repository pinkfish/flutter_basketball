import 'dart:collection' show LinkedHashMap;

import 'package:charts_common/common.dart' as common
    show BaseChart, AxisSpec, NumericAxisSpec, Series, SeriesRendererConfig;
import 'package:charts_flutter/flutter.dart' as charts;

import '../durationchartcommon.dart';

class DurationSeriesChart extends charts.BaseCartesianChart<Duration> {
  /// Create a [TimeSeriesChart].
  ///
  /// [dateTimeFactory] allows specifying a factory that creates [Duration] to
  /// be used for the time axis. If none specified, local date time is used.
  DurationSeriesChart(
    List<common.Series<dynamic, Duration>> seriesList, {
    bool animate,
    Duration animationDuration,
    common.AxisSpec domainAxis,
    common.AxisSpec primaryMeasureAxis,
    common.AxisSpec secondaryMeasureAxis,
    LinkedHashMap<String, common.NumericAxisSpec> disjointMeasureAxes,
    common.SeriesRendererConfig<Duration> defaultRenderer,
    List<common.SeriesRendererConfig<Duration>> customSeriesRenderers,
    List<charts.ChartBehavior> behaviors,
    List<charts.SelectionModelConfig<Duration>> selectionModels,
    charts.LayoutConfig layoutConfig,
    bool defaultInteractions = true,
    bool flipVerticalAxis,
    charts.UserManagedState<Duration> userManagedState,
  }) : super(
          seriesList,
          animate: animate,
          animationDuration: animationDuration,
          domainAxis: domainAxis,
          primaryMeasureAxis: primaryMeasureAxis,
          secondaryMeasureAxis: secondaryMeasureAxis,
          disjointMeasureAxes: disjointMeasureAxes,
          defaultRenderer: defaultRenderer,
          customSeriesRenderers: customSeriesRenderers,
          behaviors: behaviors,
          selectionModels: selectionModels,
          layoutConfig: layoutConfig,
          defaultInteractions: defaultInteractions,
          flipVerticalAxis: flipVerticalAxis,
          userManagedState: userManagedState,
        );

  @override
  common.BaseChart<Duration> createCommonChart(
      charts.BaseChartState chartState) {
    // Optionally create primary and secondary measure axes if the chart was
    // configured with them. If no axes were configured, then the chart will
    // use its default types (usually a numeric axis).
    return new DurationChartCommon(
        layoutConfig: layoutConfig?.commonLayoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
        disjointMeasureAxes: createDisjointMeasureAxes());
  }

  @override
  void addDefaultInteractions(List<charts.ChartBehavior> behaviors) {
    super.addDefaultInteractions(behaviors);

    behaviors.add(new charts.LinePointHighlighter());
  }
}
