import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../player/playertile.dart';

typedef void SelectPlayerCallback(BuildContext context, String playerUid);
typedef bool FilterPlayerCallback(String playerUid);

///
/// List showing all the players on the team to be selectable in a dialog.
///
class DialogPlayerList extends StatelessWidget {
  final Game game;
  final SelectPlayerCallback onSelectPlayer;
  final FilterPlayerCallback filterPlayer;
  final Orientation orientation;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    List<String> players = game.players.keys.toList();
    players.addAll(game.opponents.keys);
    players.sort((String a, String b) {
      PlayerSummary asum = game.players[a] ?? game.opponents[a];
      PlayerSummary bsum = game.players[b] ?? game.opponents[b];
      if (asum.currentlyPlaying) {
        return -1;
      }
      if (bsum.currentlyPlaying) {
        return 1;
      }
      return 0;
    });
    return players
        .where((String playerUid) =>
            filterPlayer != null ? filterPlayer(playerUid) : null)
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTile(
              playerUid: playerUid,
              editButton: false,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: game.players.containsKey(playerUid)
                      ? Theme.of(context).indicatorColor
                      : Theme.of(context).primaryColor,
                  width: 3.0,
                ),
              ),
              onTap: () => onSelectPlayer(context, playerUid),
            ),
          ),
        )
        .toList();
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    Navigator.pop(context, playerUid);
  }

  DialogPlayerList(
      {@required this.game,
      @required this.onSelectPlayer,
      @required this.orientation,
      this.filterPlayer});

  @override
  Widget build(BuildContext context) {
    return orientation == Orientation.portrait
        ? GridView.count(
            childAspectRatio: 3.0,
            crossAxisCount: 2,
            shrinkWrap: true,
            children: _populateList(context, orientation),
          )
        : GridView.count(
            childAspectRatio: 2.5,
            crossAxisCount: 4,
            shrinkWrap: true,
            children: _populateList(context, orientation),
          );
  }
}
