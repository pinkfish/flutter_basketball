import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/chart/durationtimeaxisspec.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chart/stuff/durationserieschart.dart';
import '../loading.dart';

class GameTimeseries extends StatelessWidget {
  SingleGameState state;

  GameTimeseries({@required this.state});

  charts.Series<_CumulativeScore, Duration> _getPointSeries() {
    int total = 0;
    int offset = 0;
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
        offset += 1000;
        total += e.points;
        return _CumulativeScore(total,
            Duration(milliseconds: e.eventTimeline.inMilliseconds + offset));
      }).toList(),
    );
  }

  charts.Series<_CumulativeScore, Duration> _getOpponentPointSeries() {
    int total = 0;
    int offset = 0;
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

  List<charts.RangeAnnotation> _getAnnotations() {
    var data = state.gameEvents.where((e) =>
        e.type == GameEventType.PeriodStart ||
        e.type == GameEventType.PeriodEnd);
    return data
        .map(
          (e) => charts.RangeAnnotation(
            [
              charts.RangeAnnotationSegment(
                e.timestamp,
                e.timestamp,
                charts.RangeAnnotationAxisType.domain,
              )
            ],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!state.loadedGameEvents) {
      return LoadingWidget();
    }
    //return fl.LineChart(fl.LineChartData(
    //  lineBarsData: [fl.LineChartBarData()],
    //));
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
      behaviors: [
        charts.SlidingViewport(),
        charts.PanAndZoomBehavior(),
        charts.LinePointHighlighter(),
      ],
      // behaviors: _getAnnotations(),
    );
  }
}

class _CumulativeScore {
  final int score;
  final Duration timestamp;

  _CumulativeScore(this.score, this.timestamp);
}
