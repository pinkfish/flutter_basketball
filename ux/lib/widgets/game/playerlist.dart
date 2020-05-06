import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Shows the list of players in the team.
///
class PlayerList extends StatefulWidget {
  final Orientation orientation;
  final Game game;

  PlayerList({this.orientation, this.game});

  @override
  State<StatefulWidget> createState() {
    return _PlayerListState();
  }
}

enum SortPlayerBy {
  Points,
  Fouls,
  Turnovers,
  Steals,
  Blocks,
  MadePerentage,
}

class _PlayerListState extends State<PlayerList> {
  SortPlayerBy _sortBy = SortPlayerBy.Points;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        TextStyle minDataStyle = Theme.of(context).textTheme.subtitle1.copyWith(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.25);

        double width = constraints.maxWidth / 8;
        double scale = widget.orientation == Orientation.portrait ? 1.0 : 1.2;
        List<String> sortedList = widget.game.players.keys.toList();
        sortedList.sort((String u1, String u2) =>
            _sortFunction(widget.game.players[u1], widget.game.players[u2]));
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: width * 2,
                    child: Text(
                      "",
                      style: minDataStyle.copyWith(fontWeight: FontWeight.bold),
                      textScaleFactor: scale,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FlatButton(
                      child: Text(
                        "Pts",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Points
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Points),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FlatButton(
                      child: Text(
                        "Pct",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.MadePerentage
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.MadePerentage),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FlatButton(
                      child: Text(
                        "Fouls",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Fouls
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Fouls),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FlatButton(
                      child: Text(
                        "T/O",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Turnovers
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Turnovers),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FlatButton(
                      child: Text(
                        "Steals",
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Steals
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Steals),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FlatButton(
                      child: Text(
                        "Blk",
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Blocks
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Blocks),
                    ),
                  ),
                ],
              ),
              ...sortedList
                  .map((String s) => _playerSummary(s, widget.game.players[s],
                      constraints, widget.orientation))
                  .toList(),
            ],
          ),
        );
      }),
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

  Widget _playerSummary(String uid, PlayerGameSummary s,
      BoxConstraints constraints, Orientation orientation) {
    double width = constraints.maxWidth / 8;
    double scale = orientation == Orientation.portrait ? 1.0 : 1.5;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, "/Game/Player/" + widget.game.uid + "/" + uid),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: width * 2,
            child: PlayerName(
              playerUid: uid,
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.fullData.one.made +
                      s.fullData.two.made * 2 +
                      s.fullData.three.made * 3)
                  .toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
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
          SizedBox(
            width: width,
            child: Text(
              (s.fullData.fouls).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.fullData.turnovers).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.fullData.steals).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.fullData.blocks).toString(),
              textScaleFactor: scale,
            ),
          ),
        ],
      ),
    );
  }
}
