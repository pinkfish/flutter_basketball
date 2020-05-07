import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../messages.dart';

///
/// Shows the list of players in the team.
///
class PlayerDataTable extends StatefulWidget {
  final Orientation orientation;
  final Game game;

  PlayerDataTable({this.orientation, this.game});

  @override
  State<StatefulWidget> createState() {
    return _PlayerDataTableState();
  }
}

enum SortPlayerBy {
  Points,
  Fouls,
  Turnovers,
  Steals,
  Blocks,
  MadePerentage,
  Rebounds,
}

class _PlayerDataTableState extends State<PlayerDataTable> {
  SortPlayerBy _sortBy = SortPlayerBy.Points;
  int _sortColumnIndex = 1;
  GamePeriod _period = GamePeriod.Finished;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    List<String> sortedList = widget.game.players.keys.toList();
    sortedList.sort((String u1, String u2) =>
        _sortFunction(widget.game.players[u1], widget.game.players[u2]));
    double scale = widget.orientation == Orientation.portrait ? 1.0 : 1.5;
    var style = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: Theme.of(context).accentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButton<GamePeriod>(
          value: _period,
          items: [
            DropdownMenuItem(
              child: Text(Messages.of(context).allPeriods),
              value: GamePeriod.Finished,
            ),
            DropdownMenuItem(
              child: Text(Messages.of(context).allPeriods),
              value: GamePeriod.NotStarted,
            ),
            DropdownMenuItem(
              child:
                  Text(Messages.of(context).getPeriodName(GamePeriod.Period1)),
              value: GamePeriod.Period1,
            ),
            DropdownMenuItem(
              child:
                  Text(Messages.of(context).getPeriodName(GamePeriod.Period2)),
              value: GamePeriod.Period2,
            ),
            DropdownMenuItem(
              child:
                  Text(Messages.of(context).getPeriodName(GamePeriod.Period3)),
              value: GamePeriod.Period3,
            ),
            DropdownMenuItem(
              child:
                  Text(Messages.of(context).getPeriodName(GamePeriod.Period4)),
              value: GamePeriod.Period4,
            ),
            DropdownMenuItem(
              child:
                  Text(Messages.of(context).getPeriodName(GamePeriod.OverTime)),
              value: GamePeriod.OverTime,
            ),
          ],
          onChanged: (GamePeriod p) => setState(() => _period = p),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                horizontalMargin: 5.0,
                columnSpacing: 10.0,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _ascending,
                columns: [
                  DataColumn(
                    label: Text(
                      "Name",
                      textScaleFactor: scale,
                      style: style,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      Messages.of(context).pointsGameSummary,
                      textScaleFactor: scale,
                      style: style,
                    ),
                    numeric: true,
                    onSort: (int colum, bool ascending) => setState(() {
                      _sortBy = SortPlayerBy.Points;
                      _sortColumnIndex = colum;
                      _ascending = ascending;
                    }),
                  ),
                  DataColumn(
                    label: Text(
                      Messages.of(context).percentageGameSummary,
                      textScaleFactor: scale,
                      style: style,
                    ),
                    numeric: true,
                    onSort: (int colum, bool ascending) => setState(() {
                      _sortBy = SortPlayerBy.MadePerentage;
                      _sortColumnIndex = colum;
                      _ascending = ascending;
                    }),
                  ),
                  DataColumn(
                    label: Text(
                      Messages.of(context).foulsGameSummary,
                      textScaleFactor: scale,
                      style: style,
                    ),
                    numeric: true,
                    onSort: (int colum, bool ascending) => setState(() {
                      _sortBy = SortPlayerBy.Fouls;
                      _sortColumnIndex = colum;
                      _ascending = ascending;
                    }),
                  ),
                  DataColumn(
                    label: Text(
                      Messages.of(context).turnoversGameSummary,
                      textScaleFactor: scale,
                      style: style,
                    ),
                    numeric: true,
                    onSort: (int colum, bool ascending) => setState(() {
                      _sortBy = SortPlayerBy.Turnovers;
                      _sortColumnIndex = colum;
                      _ascending = ascending;
                    }),
                  ),
                  DataColumn(
                    label: Text(
                      Messages.of(context).reboundsGameSummary,
                      textScaleFactor: scale,
                      style: style,
                    ),
                    numeric: true,
                    onSort: (int colum, bool ascending) => setState(() {
                      _sortBy = SortPlayerBy.Rebounds;
                      _sortColumnIndex = colum;
                      _ascending = ascending;
                    }),
                  ),
                  DataColumn(
                    label: Text(
                      Messages.of(context).blocks,
                      textScaleFactor: scale,
                      style: style,
                    ),
                    numeric: true,
                    onSort: (int colum, bool ascending) => setState(() {
                      _sortBy = SortPlayerBy.Blocks;
                      _sortColumnIndex = colum;
                      _ascending = ascending;
                    }),
                  ),
                ],
                rows: sortedList
                    .expand((String s) => _playerSummary(
                        s, widget.game.players[s], widget.orientation))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _sortFunction(PlayerGameSummary s1, PlayerGameSummary s2) {
    if (_ascending) {
      return _sortFunctionInner(s1, s2);
    }
    return -_sortFunctionInner(s1, s2);
  }

  int _sortFunctionInner(PlayerGameSummary s1, PlayerGameSummary s2) {
    PlayerSummaryData s1Data;
    PlayerSummaryData s2Data;
    if (_period == GamePeriod.Finished || _period == GamePeriod.NotStarted) {
      s1Data = s1.fullData;
      s2Data = s2.fullData;
    } else {
      s1Data = s1.perPeriod[_period] ?? PlayerSummaryData();
      s2Data = s2.perPeriod[_period] ?? PlayerSummaryData();
    }
    switch (_sortBy) {
      case SortPlayerBy.Points:
        return s2Data.points - s1Data.points;
      case SortPlayerBy.Fouls:
        return s2Data.fouls - s1Data.fouls;
      case SortPlayerBy.Turnovers:
        return s2Data.turnovers - s1Data.turnovers;
      case SortPlayerBy.Steals:
        return s2Data.steals - s1Data.steals;
      case SortPlayerBy.Blocks:
        return s2Data.blocks - s1Data.blocks;
      case SortPlayerBy.Rebounds:
        return (s2Data.offensiveRebounds + s2.fullData.defensiveRebounds) -
            (s1Data.offensiveRebounds + s1.fullData.defensiveRebounds);
      case SortPlayerBy.MadePerentage:
        if ((s2Data.one.attempts +
                s2Data.two.attempts +
                s2Data.three.attempts) >
            0) {
          if ((s1Data.one.attempts +
                  s1Data.two.attempts +
                  s1Data.three.attempts) >
              0) {
            return ((s2Data.one.made + s2Data.two.made + s2Data.three.made) ~/
                    (s2Data.one.attempts +
                        s2Data.two.attempts +
                        s2Data.three.attempts)) -
                ((s1Data.one.made + s1Data.two.made + s1Data.three.made) ~/
                    (s1Data.one.attempts +
                        s1Data.two.attempts +
                        s1Data.three.attempts));
          }
          return 1;
        } else if ((s1Data.one.attempts +
                s1Data.two.attempts +
                s1Data.three.attempts) >
            0) {
          return -1;
        }
    }
    return 0;
  }

  Iterable<DataRow> _playerSummary(
      String uid, PlayerGameSummary s, Orientation orientation) {
    double scale = orientation == Orientation.portrait ? 1.0 : 1.5;
    PlayerSummaryData data;
    if (_period == GamePeriod.Finished || _period == GamePeriod.NotStarted) {
      data = s.fullData;
    } else {
      data = s.perPeriod[_period] ?? PlayerSummaryData();
    }
    if (_period == GamePeriod.NotStarted) {
      double smallScale = orientation == Orientation.portrait ? 0.8 : 1;
      // Show everything!
      return [
        _playerSummaryRow(uid, scale, data, GamePeriod.Finished),
        ...s.perPeriod.keys
            .map((k) => _playerSummaryRow(uid, smallScale, s.perPeriod[k], k))
            .toList()
      ];
    }
    return [
      _playerSummaryRow(uid, scale, data, GamePeriod.Finished),
    ];
  }

  DataRow _playerSummaryRow(
      String uid, double scale, PlayerSummaryData data, GamePeriod p) {
    return DataRow(
      cells: [
        DataCell(
          (p == GamePeriod.Finished
              ? PlayerName(
                  playerUid: uid,
                  textScaleFactor: scale,
                )
              : Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    Messages.of(context).getPeriodName(p),
                    textAlign: TextAlign.right,
                  ),
                )),
          onTap: () => Navigator.pushNamed(
              context, "/Game/Player/" + widget.game.uid + "/" + uid),
        ),
        DataCell(
          Text(
            (data.one.made + data.two.made * 2 + data.three.made * 3)
                .toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            ((data.one.attempts +
                        data.two.attempts * 2 +
                        data.three.attempts * 3) ==
                    0
                ? "0%"
                : ((data.one.made + data.two.made * 2 + data.three.made * 3) /
                            (data.one.attempts +
                                data.two.attempts * 2 +
                                data.three.attempts * 3) *
                            100)
                        .toStringAsFixed(0) +
                    "%"),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (data.fouls).toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (data.turnovers).toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (data.steals).toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (data.blocks).toString(),
            textScaleFactor: scale,
          ),
        ),
      ],
    );
  }
}
