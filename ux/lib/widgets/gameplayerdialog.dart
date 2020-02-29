import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import 'playertile.dart';

///
/// Shows the point adding items as buttons on the screen.
///
class GamePlayerDialog extends StatelessWidget {
  final Game game;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    List<String> players = game.playerUids.keys.toList();
    return players
        .map((String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: new BorderRadius.all(
                    const Radius.circular(20.0),
                  ),
                ),
                child: PlayerTile(
                    playerUid: playerUid,
                    onTap: () => _selectPlayer(context, playerUid)))))
        .toList();
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    Navigator.pop(context, playerUid);
  }

  GamePlayerDialog({@required this.game});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation o) {
          return Column(
            children: [
              Text("Select Player"),
              Expanded(
                child: GridView.count(
                  childAspectRatio: 3.0,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: _populateList(context, o),
                ),
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
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
