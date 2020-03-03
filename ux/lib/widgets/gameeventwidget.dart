import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../messages.dart';

class GameEventWidget extends StatelessWidget {
  final GameEvent gameEvent;

  GameEventWidget({@required this.gameEvent});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(Messages.of(context).getGameEventType(gameEvent)),
      subtitle: gameEvent.playerUid != null && gameEvent.playerUid.isNotEmpty
          ? PlayerName(
              playerUid: gameEvent.playerUid,
            )
          : Text(
              Messages.of(context).getPeriodName(gameEvent.period),
            ),
    );
  }
}
