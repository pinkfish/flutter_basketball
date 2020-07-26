import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Shows the list of players in the team.
///
class PlayerList extends StatefulWidget {
  final Orientation orientation;
  final Season season;
  final Game game;
  final Map<String, Player> additonalPlayers;

  PlayerList(
      {this.orientation = Orientation.portrait,
      @required this.game,
      @required this.season,
      this.additonalPlayers});

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
        if (widget.season != null) {
          List<String> seasonList = widget.season.playerUids.keys.toList();
          // Only track things not in the current list and not ignored.
          seasonList.removeWhere((e) =>
              widget.game.ignoreFromSeason.contains(e) ||
              sortedList.contains(e));
          sortedList.addAll(seasonList);
        }
        if (widget.additonalPlayers != null) {
          sortedList.addAll(widget.additonalPlayers.keys);
        }
        sortedList.sort((String u1, String u2) =>
            _sortFunction(_getData(u1), _getData(u2)));
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
                  .map((String s) => _playerSummary(
                      s, _getData(s), constraints, widget.orientation))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  PlayerSummaryData _getData(String playerUid) {
    return widget.game.players[playerUid]?.fullData ??
        widget.season?.playerUids[playerUid]?.summary ??
        PlayerSummaryData();
  }

  int _sortFunction(PlayerSummaryData s1, PlayerSummaryData s2) {
    switch (_sortBy) {
      case SortPlayerBy.Points:
        return s2.points - s1.points;
      case SortPlayerBy.Fouls:
        return s2.fouls - s1.fouls;
      case SortPlayerBy.Turnovers:
        return s2.turnovers - s1.turnovers;
      case SortPlayerBy.Steals:
        return s2.steals - s1.steals;
      case SortPlayerBy.Blocks:
        return s2.blocks - s1.blocks;
      case SortPlayerBy.MadePerentage:
        if ((s2.one.attempts + s2.two.attempts + s2.three.attempts) > 0) {
          if ((s1.one.attempts + s1.two.attempts + s1.three.attempts) > 0) {
            return ((s2.one.made + s2.two.made + s2.three.made) ~/
                    (s2.one.attempts + s2.two.attempts + s2.three.attempts)) -
                ((s1.one.made + s1.two.made + s1.three.made) ~/
                    (s1.one.attempts + s1.two.attempts + s1.three.attempts));
          }
          return 1;
        } else if ((s1.one.attempts + s1.two.attempts + s1.three.attempts) >
            0) {
          return -1;
        }
    }
    return 0;
  }

  Widget _playerSummary(String uid, PlayerSummaryData s,
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
              (s.one.made + s.two.made * 2 + s.three.made * 3).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              ((s.one.attempts + s.two.attempts * 2 + s.three.attempts * 3) == 0
                  ? "0%"
                  : ((s.one.made + s.two.made * 2 + s.three.made * 3) /
                              (s.one.attempts +
                                  s.two.attempts * 2 +
                                  s.three.attempts * 3) *
                              100)
                          .toStringAsFixed(0) +
                      "%"),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.fouls).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.turnovers).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.steals).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.blocks).toString(),
              textScaleFactor: scale,
            ),
          ),
        ],
      ),
    );
  }
}
