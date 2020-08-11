import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../../messages.dart';
import 'dialogplayerlist.dart';

typedef List<Widget> GamePlayerExtraButtons(BuildContext context);

///
/// Shows the players as a nice grid to be able to select from.
///
class GamePlayerDialog extends StatelessWidget {
  final Game game;
  final GamePlayerExtraButtons extraButtons;
  final Stream<bool> changeStream;

  void _selectPlayer(BuildContext context, String playerUid) {
    Navigator.pop(context, playerUid);
  }

  GamePlayerDialog({@required this.game, this.extraButtons, this.changeStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).selectPlayer),
        automaticallyImplyLeading: false,
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation o) {
          if (changeStream != null) {
            return StreamBuilder(
              stream: changeStream,
              builder: (BuildContext context, AsyncSnapshot<bool> val) {
                return _middleBit(context, o);
              },
            );
          }
          return _middleBit(context, o);
        },
      ),
    );
  }

  Widget _middleBit(BuildContext context, Orientation o) {
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
            ...extraButtons != null ? extraButtons(context) : [],
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
  }
}
