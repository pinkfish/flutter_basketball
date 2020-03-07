import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../messages.dart';

class GameEventWidget extends StatelessWidget {
  final GameEvent gameEvent;

  GameEventWidget({@required this.gameEvent});

  @override
  Widget build(BuildContext context) {
    print("Event ${gameEvent.playerUid}");
    return Card(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            Text(
              Messages.of(context).getGameEventType(gameEvent),
              style: Theme.of(context).textTheme.body1,
              textScaleFactor: 1.2,
            ),
            SizedBox(width: 20.0),
            gameEvent.playerUid != null && gameEvent.playerUid.isNotEmpty
                ? PlayerName(
                    playerUid: gameEvent.playerUid,
                  )
                : Text(
                    Messages.of(context).getPeriodName(gameEvent.period),
                    style: Theme.of(context).textTheme.body1,
                  ),
          ],
        ),
      ),
    );
  }
}
