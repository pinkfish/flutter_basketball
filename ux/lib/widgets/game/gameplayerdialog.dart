import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../player/playertile.dart';

///
/// Shows the players as a nice grid to be able to select from.
///
class GamePlayerDialog extends StatelessWidget {
  final Game game;

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
            child:
                /*Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: game.players.containsKey(playerUid)
                      ? Colors.amberAccent
                      : Colors.greenAccent,
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(20.0),
                  ),
                ),
                child: */
                PlayerTile(
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
              onTap: () => _selectPlayer(context, playerUid),
            ),
          ),
        )
        .toList();
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    Navigator.pop(context, playerUid);
  }

  GamePlayerDialog({@required this.game});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Player"),
        automaticallyImplyLeading: false,
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation o) {
          return Column(
            children: [
              Expanded(
                child: o == Orientation.portrait
                    ? GridView.count(
                  childAspectRatio: 3.0,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: _populateList(context, o),
                )
                    : GridView.count(
                  childAspectRatio: 2.5,
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  children: _populateList(context, o),
                ),
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    child: Text(
                      MaterialLocalizations
                          .of(context)
                          .cancelButtonLabel,
                      textScaleFactor: 1.5,
                    ),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
