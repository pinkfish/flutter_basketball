import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../player/playertile.dart';

typedef void PlayerSelectFunction(String uid, bool selected);
typedef bool PlayerIsSelected(String uid);

///
/// Shows the players as a nice grid to be able to select from to setup who
/// is currently playing.
///
class PlayerMultiselect extends StatelessWidget {
  final Game game;
  final Season season;
  final PlayerIsSelected isSelected;
  final PlayerSelectFunction selectPlayer;
  final Orientation orientation;
  final Map<String, Player> additionalPlayers;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    Set<String> players = game.players.keys.toSet();
    List<String> seasonPlayers =
        season != null ? season.playerUids.keys.toList() : [];
    seasonPlayers
        .removeWhere((element) => (game.ignoreFromSeason.contains(element)));
    players.addAll(game.opponents.keys);
    players.addAll(seasonPlayers);
    if (additionalPlayers != null) {
      players.addAll(additionalPlayers.keys);
    }
    var ordered = players.toList();
    ordered.sort((String a, String b) {
      PlayerGameSummary asum = game.players[a] ?? game.opponents[a];
      PlayerGameSummary bsum = game.players[b] ?? game.opponents[b];
      if (asum == null || bsum == null) {
        return 0;
      }
      if (asum.currentlyPlaying) {
        return -1;
      }
      if (bsum.currentlyPlaying) {
        return 1;
      }
      return 0;
    });
    return ordered
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTile(
              playerUid: playerUid,
              editButton: false,
              color: isSelected(playerUid)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: isSelected(playerUid)
                      ? Theme.of(context).indicatorColor
                      : Theme.of(context).primaryColor,
                  width: 3.0,
                ),
              ),
              onTap: (String playerUid) =>
                  selectPlayer(playerUid, isSelected(playerUid)),
            ),
          ),
        )
        .toList();
  }

  PlayerMultiselect(
      {@required this.game,
      @required this.season,
      @required this.isSelected,
      @required this.selectPlayer,
      this.additionalPlayers,
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
