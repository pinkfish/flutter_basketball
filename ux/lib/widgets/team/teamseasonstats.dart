import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playerdropdown.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../messages.dart';

enum ShowGameData {
  Points,
  Fouls,
  Turnovers,
  Steals,
  Blocks,
  MadePerentage,
  Rebounds,
  All,
}

///
/// Shows the detailed player based stats for the season.
///
class TeamSeasonStats extends StatefulWidget {
  final SingleSeasonBlocState state;
  final ShowGameData gameData;
  final String playerUid;

  TeamSeasonStats(
      {@required this.state, @required this.gameData, this.playerUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamSeasonStatsData();
  }
}

class _TeamSeasonStatsData extends State<TeamSeasonStats> {
  List<charts.Series<_CumulativeScore, DateTime>> _getEventSeries(
      Iterable<Game> games,
      ShowGameData eventType,
      Color color,
      bool opponent) {
    List<charts.Series<_CumulativeScore, DateTime>> ret = [];

    ret.add(
      charts.Series<_CumulativeScore, DateTime>(
        id: _nameOfSeries(eventType, opponent),
        colorFn: (_, __) =>
            charts.Color(r: color.red, g: color.green, b: color.blue),
        domainFn: (_CumulativeScore e, _) => e.timestamp,
        measureFn: (_CumulativeScore e, _) => e.score,
        data: games.map((e) {
          int val = 0;
          if (opponent) {
            for (var uid in e.opponents.keys) {
              var data = e.opponents[uid];
              if (widget.playerUid == PlayerDropDown.allValue ||
                  widget.playerUid == uid) {
                val += _numByType(eventType, data);
              }
            }
          } else {
            for (var uid in e.players.keys) {
              var data = e.players[uid];
              if (widget.playerUid == PlayerDropDown.allValue ||
                  widget.playerUid == uid) {
                val += _numByType(eventType, data);
              }
            }
          }
          print("Found $eventType  $val");
          return _CumulativeScore(val, e.eventTime);
        }).toList(),
      ),
    );
    return ret;
  }

  int _numByType(ShowGameData eventType, PlayerGameSummary data) {
    switch (eventType) {
      case ShowGameData.Points:
        return data.fullData.points;
      case ShowGameData.Blocks:
        return data.fullData.blocks;
      case ShowGameData.Rebounds:
        return data.fullData.offensiveRebounds +
            data.fullData.defensiveRebounds;
      case ShowGameData.Turnovers:
        return data.fullData.turnovers;
      case ShowGameData.Fouls:
        return data.fullData.fouls;
      case ShowGameData.Steals:
        return data.fullData.steals;
      default:
        return 0;
    }
  }

  String _nameOfSeries(ShowGameData type, bool opponent) {
    switch (type) {
      case ShowGameData.Points:
        return Messages.of(context).points;
      case ShowGameData.Fouls:
        return Messages.of(context).fouls;
      case ShowGameData.Turnovers:
        return Messages.of(context).turnovers;
      case ShowGameData.Steals:
        return Messages.of(context).steals;
      case ShowGameData.Blocks:
        return Messages.of(context).blocks;
      case ShowGameData.MadePerentage:
        return Messages.of(context).points;
      case ShowGameData.Rebounds:
        return Messages.of(context).rebounds;
      case ShowGameData.All:
        return Messages.of(context).unknown;
    }
  }

  List<charts.Series<_CumulativeScore, DateTime>> _getSeries() {
    List<Game> sortedGames = widget.state.games.toList();
    sortedGames.sort((g1, g2) => g1.eventTime.compareTo(g2.eventTime));
    switch (widget.gameData) {
      case ShowGameData.All:
        return [
          ..._getEventSeries(
              sortedGames, ShowGameData.Points, Colors.blue, false),
          ..._getEventSeries(
              sortedGames, ShowGameData.Blocks, Colors.blue, false),
          ..._getEventSeries(
              sortedGames, ShowGameData.Steals, Colors.deepOrange, false),
          ..._getEventSeries(
              sortedGames, ShowGameData.Turnovers, Colors.deepPurple, false),
          ..._getEventSeries(
              sortedGames, ShowGameData.Fouls, Colors.lime, false),
          ..._getEventSeries(
              sortedGames, ShowGameData.Rebounds, Colors.lime, false),
        ];
      default:
        return _getEventSeries(
            sortedGames, widget.gameData, Colors.blue, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: _middleSectionWidget(),
    );
  }

  Widget _middleSectionWidget() {
    var behaviours = <charts.ChartBehavior<dynamic>>[
      charts.SlidingViewport(),
      charts.PanAndZoomBehavior(),
      charts.LinePointHighlighter(),
      charts.SeriesLegend(
        desiredMaxRows: 2,
        desiredMaxColumns: 3,
      ),
    ];

    if (widget.state.games.length > 0) {
      behaviours.add(charts.RangeAnnotation(widget.state.games
          .map(
            (p) => charts.LineAnnotationSegment(
              DateTime.now(),
              charts.RangeAnnotationAxisType.domain,
              startLabel: p.opponentName,
            ),
          )
          .toList()));
    }

    return charts.TimeSeriesChart(
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
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(),
        renderSpec: charts.SmallTickRendererSpec<DateTime>(
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
  final DateTime timestamp;

  _CumulativeScore(this.score, this.timestamp);
}
