import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/chart/durationtimeaxisspec.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../messages.dart';
import '../chart/stuff/durationserieschart.dart';
import '../loading.dart';

class GameTimeseries extends StatelessWidget {
  final SingleGameState state;

  GameTimeseries({@required this.state});

  charts.Series<_CumulativeScore, Duration> _getPointSeries() {
    int total = 0;
    bool first = false;
    return charts.Series<_CumulativeScore, Duration>(
      id: 'Score',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (_CumulativeScore e, _) =>
          Duration(milliseconds: e.timestamp.inMilliseconds),
      measureFn: (_CumulativeScore e, _) => e.score,
      data: state.gameEvents
          .where((e) => e.type == GameEventType.Made && !e.opponent || first)
          .map((e) {
        if (first && e.type != GameEventType.Made) {
          first = false;
          return _CumulativeScore(total, Duration(milliseconds: 0));
        }
        total += e.points;
        return _CumulativeScore(total, e.eventTimeline);
      }).toList(),
    );
  }

  charts.Series<_CumulativeScore, Duration> _getOpponentPointSeries() {
    int total = 0;
    bool first = false;

    return charts.Series<_CumulativeScore, Duration>(
      id: 'Opponent',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (_CumulativeScore e, _) => e.timestamp,
      measureFn: (_CumulativeScore e, _) => e.score,
      data: state.gameEvents
          .where((e) => e.type == GameEventType.Made && e.opponent)
          .map((e) {
        if (first && e.type != GameEventType.Made) {
          first = false;
          return _CumulativeScore(total, e.eventTimeline);
        }

        total += e.points;
        return _CumulativeScore(total, e.eventTimeline);
      }).toList(),
    );
  }

  List<charts.Series<_CumulativeScore, Duration>> _getSeries() {
    return [
      _getPointSeries(),
      _getOpponentPointSeries(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!state.loadedGameEvents) {
      return LoadingWidget();
    }
    var periods =
        state.gameEvents.where((e) => e.type == GameEventType.PeriodEnd);

    var behaviours = <charts.ChartBehavior<dynamic>>[
      charts.SlidingViewport(),
      charts.PanAndZoomBehavior(),
      charts.LinePointHighlighter()
    ];

    if (periods.length > 0) {
      behaviours.add(charts.RangeAnnotation(periods
          .map(
            (p) => charts.LineAnnotationSegment(
              p.eventTimeline,
              charts.RangeAnnotationAxisType.domain,
              startLabel: Messages.of(context).getPeriodName(p.period),
            ),
          )
          .toList()));
    }

    return DurationSeriesChart(
      _getSeries(),
      animate: true,
      animationDuration: Duration(milliseconds: 500),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(),
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 18,
            color: charts.Color.white,
          ),
        ),
      ),
      domainAxis: DurationAxisSpec(
        tickFormatterSpec: AutoDurationTickFormatterSpec(),
        renderSpec: charts.SmallTickRendererSpec<Duration>(
          labelStyle: charts.TextStyleSpec(
            fontSize: 18,
            color: charts.Color.white,
          ),
        ),
      ),
      behaviors: behaviours,
      // behaviors: _getAnnotations(),
    );
  }
}

class _CumulativeScore {
  final int score;
  final Duration timestamp;

  _CumulativeScore(this.score, this.timestamp);
}
