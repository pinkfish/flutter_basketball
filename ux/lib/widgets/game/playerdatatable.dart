import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 5.0,
          columnSpacing: 10.0,
          sortColumnIndex: _sortColumnIndex,
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
                "Pts",
                textScaleFactor: scale,
                style: style,
              ),
              numeric: true,
              onSort: (int colum, bool ascending) => setState(() {
                _sortBy = SortPlayerBy.Points;
                _sortColumnIndex = colum;
              }),
            ),
            DataColumn(
              label: Text(
                "Pct",
                textScaleFactor: scale,
                style: style,
              ),
              numeric: true,
              onSort: (int colum, bool ascending) => setState(() {
                _sortBy = SortPlayerBy.MadePerentage;
                _sortColumnIndex = colum;
              }),
            ),
            DataColumn(
              label: Text(
                "Fouls",
                textScaleFactor: scale,
                style: style,
              ),
              numeric: true,
              onSort: (int colum, bool ascending) => setState(() {
                _sortBy = SortPlayerBy.Fouls;
                _sortColumnIndex = colum;
              }),
            ),
            DataColumn(
              label: Text(
                "T/O",
                textScaleFactor: scale,
                style: style,
              ),
              numeric: true,
              onSort: (int colum, bool ascending) => setState(() {
                _sortBy = SortPlayerBy.Turnovers;
                _sortColumnIndex = colum;
              }),
            ),
            DataColumn(
              label: Text(
                "Rb",
                textScaleFactor: scale,
                style: style,
              ),
              numeric: true,
              onSort: (int colum, bool ascending) => setState(() {
                _sortBy = SortPlayerBy.Rebounds;
                _sortColumnIndex = colum;
              }),
            ),
            DataColumn(
              label: Text(
                "Blocks",
                textScaleFactor: scale,
                style: style,
              ),
              numeric: true,
              onSort: (int colum, bool ascending) => setState(() {
                _sortBy = SortPlayerBy.Blocks;
                _sortColumnIndex = colum;
              }),
            ),
          ],
          rows: sortedList
              .map((String s) =>
                  _playerSummary(s, widget.game.players[s], widget.orientation))
              .toList(),
        ),
      ),
    );
  }

  int _sortFunction(PlayerGameSummary s1, PlayerGameSummary s2) {
    switch (_sortBy) {
      case SortPlayerBy.Points:
        return s2.fullData.points - s1.fullData.points;
      case SortPlayerBy.Fouls:
        return s2.fullData.fouls - s1.fullData.fouls;
      case SortPlayerBy.Turnovers:
        return s2.fullData.turnovers - s1.fullData.turnovers;
      case SortPlayerBy.Steals:
        return s2.fullData.steals - s1.fullData.steals;
      case SortPlayerBy.Blocks:
        return s2.fullData.blocks - s1.fullData.blocks;
      case SortPlayerBy.Rebounds:
        return (s2.fullData.offensiveRebounds + s2.fullData.defensiveRebounds) -
            (s1.fullData.offensiveRebounds + s1.fullData.defensiveRebounds);
      case SortPlayerBy.MadePerentage:
        if ((s2.fullData.one.attempts +
                s2.fullData.two.attempts +
                s2.fullData.three.attempts) >
            0) {
          if ((s1.fullData.one.attempts +
                  s1.fullData.two.attempts +
                  s1.fullData.three.attempts) >
              0) {
            return ((s2.fullData.one.made +
                        s2.fullData.two.made +
                        s2.fullData.three.made) ~/
                    (s2.fullData.one.attempts +
                        s2.fullData.two.attempts +
                        s2.fullData.three.attempts)) -
                ((s1.fullData.one.made +
                        s1.fullData.two.made +
                        s1.fullData.three.made) ~/
                    (s1.fullData.one.attempts +
                        s1.fullData.two.attempts +
                        s1.fullData.three.attempts));
          }
          return 1;
        } else if ((s1.fullData.one.attempts +
                s1.fullData.two.attempts +
                s1.fullData.three.attempts) >
            0) {
          return -1;
        }
    }
    return 0;
  }

  DataRow _playerSummary(
      String uid, PlayerGameSummary s, Orientation orientation) {
    double scale = orientation == Orientation.portrait ? 1.0 : 1.5;
    return DataRow(
      cells: [
        DataCell(
          PlayerName(
            playerUid: uid,
            textScaleFactor: scale,
          ),
          onTap: () => Navigator.pushNamed(
              context, "/Game/Player/" + widget.game.uid + "/" + uid),
        ),
        DataCell(
          Text(
            (s.fullData.one.made +
                    s.fullData.two.made * 2 +
                    s.fullData.three.made * 3)
                .toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            ((s.fullData.one.attempts +
                        s.fullData.two.attempts * 2 +
                        s.fullData.three.attempts * 3) ==
                    0
                ? "0%"
                : ((s.fullData.one.made +
                                s.fullData.two.made * 2 +
                                s.fullData.three.made * 3) /
                            (s.fullData.one.attempts +
                                s.fullData.two.attempts * 2 +
                                s.fullData.three.attempts * 3) *
                            100)
                        .toStringAsFixed(0) +
                    "%"),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (s.fullData.fouls).toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (s.fullData.turnovers).toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (s.fullData.steals).toString(),
            textScaleFactor: scale,
          ),
        ),
        DataCell(
          Text(
            (s.fullData.blocks).toString(),
            textScaleFactor: scale,
          ),
        ),
      ],
    );
  }
}
