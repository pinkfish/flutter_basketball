import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/playername.dart';
import 'package:flutter/cupertino.dart';

import '../messages.dart';

class GameEventWidget extends StatelessWidget {
  GameEvent ev;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(Messages.of(context).getGameEventType(ev)),
        PlayerName(
          playerUid: ev.playerUid,
        ),
      ],
    );
  }
}
