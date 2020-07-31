import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/localstoragedata.dart';
import 'package:flutter/material.dart';

import '../player/playertile.dart';

typedef void SelectPlayerCallback(BuildContext context, String playerUid);
typedef bool FilterPlayerCallback(String playerUid);
typedef int SortPlayerCallback(Game game, String p1, String p2);

///
/// List showing all the players on the team to be selectable in a dialog.
///
class GamePlayerList extends StatelessWidget {
  final Game game;
  final SelectPlayerCallback onSelectPlayer;
  final FilterPlayerCallback filterPlayer;
  final Orientation orientation;
  final String selectedPlayer;
  final bool compactDisplay;
  final PlayerExtraFunc extra;
  final SortPlayerCallback sort;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    List<String> players = game.players.keys.toList();
    players.addAll(game.opponents.keys);
    players.sort((String p1, String p2) => sort(game, p1, p2));
    return players
        .where((String playerUid) =>
            filterPlayer != null ? filterPlayer(playerUid) : null)
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTile(
              extra: extra,
              compactDisplay: this.compactDisplay,
              playerUid: playerUid,
              editButton: false,
              color: selectedPlayer == playerUid
                  ? Theme.of(context).splashColor
                  : LocalStorageData.isDark(context)
                      ? Theme.of(context).primaryColor
                      : LocalStorageData.brighten(
                          Theme.of(context).primaryColor, 80),
              onTap: onSelectPlayer != null
                  ? (String playerUid) => onSelectPlayer(context, playerUid)
                  : null,
            ),
          ),
        )
        .toList();
  }

  GamePlayerList(
      {@required this.game,
      @required this.onSelectPlayer,
      @required this.orientation,
      this.filterPlayer,
      this.selectedPlayer,
      this.extra,
      this.sort = _sortFunc,
      this.compactDisplay = false});

  static int _sortFunc(Game game, String a, String b) {
    PlayerGameSummary asum = game.players[a] ?? game.opponents[a];
    PlayerGameSummary bsum = game.players[b] ?? game.opponents[b];
    if (asum.currentlyPlaying) {
      return -1;
    }
    if (bsum.currentlyPlaying) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: _populateList(context, orientation),
    );
  }
}
