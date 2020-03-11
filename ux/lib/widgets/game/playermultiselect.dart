import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../player/playertile.dart';

typedef void PlayerSelectFunction(String uid, bool selected);

///
/// Shows the players as a nice grid to be able to select from to setup who
/// is currently playing.
///
class PlayerMultiselect extends StatelessWidget {
  final Game game;
  final List<String> selectedUids;
  final PlayerSelectFunction selectPlayer;
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
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTile(
              playerUid: playerUid,
              editButton: false,
              color: selectedUids.contains(playerUid)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: selectedUids.contains(playerUid)
                      ? Theme.of(context).indicatorColor
                      : Theme.of(context).primaryColor,
                  width: 3.0,
                ),
              ),
              onTap: () =>
                  selectPlayer(playerUid, selectedUids.contains(playerUid)),
            ),
          ),
        )
        .toList();
  }

  PlayerMultiselect(
      {@required this.game,
      @required this.selectedUids,
      @required this.selectPlayer,
      this.orientation = Orientation.portrait});

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
