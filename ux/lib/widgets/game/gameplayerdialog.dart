import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import 'dialogplayerlist.dart';

///
/// Shows the players as a nice grid to be able to select from.
///
class GamePlayerDialog extends StatelessWidget {
  final Game game;

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
                child: DialogPlayerList(
                  game: game,
                  onSelectPlayer: _selectPlayer,
                  orientation: o,
                ),
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
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
