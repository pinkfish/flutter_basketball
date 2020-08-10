import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/deleted.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

///
/// Shows player related graphs for the team data.
///
class TeamPlayerGraphs extends StatefulWidget {
  final String playerUid;
  final SingleSeasonState seasonState;

  TeamPlayerGraphs({@required this.playerUid, @required this.seasonState});

  @override
  State<StatefulWidget> createState() {
    return _TeamPlayerGraphsState();
  }
}

enum _GameTimeseriesType {
  All,
  Points,
  Fouls,
  Turnovers,
  Steals,
  Blocks,
  OffensiveRebounds,
  DefensiveRebounds,
}

class _TeamPlayerGraphsState extends State<TeamPlayerGraphs> {
  _GameTimeseriesType type = _GameTimeseriesType.All;

  @override
  Widget build(BuildContext context) {
    var behaviours = <charts.ChartBehavior<dynamic>>[
      charts.SlidingViewport(),
      charts.PanAndZoomBehavior(),
      charts.LinePointHighlighter()
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DropdownButton<_GameTimeseriesType>(
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              value: type,
              onChanged: (_GameTimeseriesType t) => setState(() => type = t),
              items: [
                DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).allEvents,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  value: _GameTimeseriesType.All,
                ),
                DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).points,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  value: _GameTimeseriesType.Points,
                ),
                DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).blocks,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  value: _GameTimeseriesType.Blocks,
                ),
                DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).rebounds,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  value: _GameTimeseriesType.OffensiveRebounds,
                ),
                DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).fouls,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  value: _GameTimeseriesType.Fouls,
                ),
                DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      Messages.of(context).turnovers,
                      textScaleFactor: 1.2,
                    ),
                  ),
                  value: _GameTimeseriesType.Turnovers,
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: BlocProvider(
            key: Key("season${widget.seasonState.season.uid}"),
            create: (BuildContext context) => SingleSeasonBloc(
              seasonUid: widget.seasonState.season.uid,
              db: RepositoryProvider.of<BasketballDatabase>(context),
              crashes: RepositoryProvider.of<CrashReporting>(context),
            ),
            child: Builder(
              builder: (BuildContext context) => BlocConsumer(
                  cubit: BlocProvider.of<SingleSeasonBloc>(context),
                  listener: (BuildContext context, SingleSeasonState state) {
                    if (state is SingleSeasonLoaded && !state.loadedGames) {
                      BlocProvider.of<SingleSeasonBloc>(context)
                          .add(SingleSeasonLoadGames());
                    }
                  },
                  builder: (BuildContext context, SingleSeasonState state) {
                    if (state is SingleSeasonUninitialized ||
                        !state.loadedGames) {
                      return LoadingWidget();
                    }
                    if (state is SingleSeasonDeleted) {
                      return DeletedWidget();
                    }
                    return charts.BarChart(
                      _getSeries(state),
                      animate: false,
                      animationDuration: Duration(milliseconds: 500),
                      barGroupingType: charts.BarGroupingType.grouped,
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(),
                        renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 18,
                            color: charts.Color.white,
                          ),
                        ),
                      ),
                      domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec<String>(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 18,
                            color: charts.Color.white,
                          ),
                        ),
                      ),
                      behaviors: behaviours,
                      // behaviors: _getAnnotations(),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  List<charts.Series<_CumulativeScore, String>> _getSeries(
      SingleSeasonState state) {
    switch (type) {
      case _GameTimeseriesType.All:
        return [
          _getEventSeries(state, _GameTimeseriesType.Points, Colors.green),
          _getEventSeries(state, _GameTimeseriesType.Blocks, Colors.blue),
          _getEventSeries(state, _GameTimeseriesType.Steals, Colors.orange),
          _getEventSeries(state, _GameTimeseriesType.Turnovers, Colors.purple),
          _getEventSeries(state, _GameTimeseriesType.Fouls, Colors.lime),
          _getEventSeries(
              state, _GameTimeseriesType.OffensiveRebounds, Colors.cyan),
          _getEventSeries(
              state, _GameTimeseriesType.DefensiveRebounds, Colors.cyanAccent),
        ];
      case _GameTimeseriesType.Points:
        return [
          _getEventSeries(state, _GameTimeseriesType.Points, Colors.green),
        ];
      case _GameTimeseriesType.Fouls:
        return [
          _getEventSeries(state, _GameTimeseriesType.Fouls, Colors.lime),
        ];
      case _GameTimeseriesType.Turnovers:
        return [
          _getEventSeries(state, _GameTimeseriesType.Turnovers, Colors.purple),
        ];
      case _GameTimeseriesType.Steals:
        return [
          _getEventSeries(
            state,
            _GameTimeseriesType.Steals,
            Colors.orange,
          ),
        ];
      case _GameTimeseriesType.Blocks:
        return [
          _getEventSeries(state, _GameTimeseriesType.Blocks, Colors.blue),
        ];
      case _GameTimeseriesType.OffensiveRebounds:
        return [
          _getEventSeries(
              state, _GameTimeseriesType.OffensiveRebounds, Colors.cyan),
          _getEventSeries(
              state, _GameTimeseriesType.DefensiveRebounds, Colors.cyanAccent),
        ];
      default:
        return [];
    }
  }

  charts.Series<_CumulativeScore, String> _getEventSeries(
      SingleSeasonState state, _GameTimeseriesType eventType, Color color) {
    return charts.Series<_CumulativeScore, String>(
      id: eventType.toString(),
      seriesCategory: eventType == _GameTimeseriesType.DefensiveRebounds ||
              eventType == _GameTimeseriesType.DefensiveRebounds
          ? "Rebounds"
          : null,
      colorFn: (_, __) =>
          charts.Color(r: color.red, g: color.green, b: color.blue),
      domainFn: (_CumulativeScore e, _) => e.name,
      measureFn: (_CumulativeScore e, _) => e.count,
      data: state.games.map((e) {
        int total = 0;
        String name = "";
        switch (eventType) {
          case _GameTimeseriesType.All:
            break;
          case _GameTimeseriesType.Points:
            total = e.players[widget.playerUid].fullData.points;
            name = Messages.of(context).pointsTitle;
            break;
          case _GameTimeseriesType.Fouls:
            total = e.players[widget.playerUid].fullData.fouls;
            name = Messages.of(context).fouls;
            break;
          case _GameTimeseriesType.Turnovers:
            total = e.players[widget.playerUid].fullData.turnovers;
            name = Messages.of(context).turnoversTitle;
            break;
          case _GameTimeseriesType.Steals:
            total = e.players[widget.playerUid].fullData.steals;
            name = Messages.of(context).stealsTitle;
            break;
          case _GameTimeseriesType.Blocks:
            total = e.players[widget.playerUid].fullData.blocks;
            name = Messages.of(context).blocksTitle;
            break;
          case _GameTimeseriesType.OffensiveRebounds:
            total = e.players[widget.playerUid].fullData.offensiveRebounds;
            name = Messages.of(context).blocksTitle;
            break;
          case _GameTimeseriesType.DefensiveRebounds:
            total = e.players[widget.playerUid].fullData.defensiveRebounds;
            name = Messages.of(context).blocksTitle;
            break;
        }
        print("$name $total");
        return _CumulativeScore(e.opponentName, total);
      }).toList(),
    );
  }
}

class _CumulativeScore {
  final String name;
  final int count;

  _CumulativeScore(this.name, this.count);
}
