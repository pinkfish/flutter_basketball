import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../messages.dart';

class GameEventWidget extends StatelessWidget {
  final GameEvent gameEvent;
  final bool showTimestamp;
  final bool showPeriod;
  final bool showName;

  static DateFormat format = DateFormat("HH:mm");

  GameEventWidget(
      {@required this.gameEvent,
      this.showTimestamp = false,
      this.showPeriod = false,
      this.showName = true});

  @override
  Widget build(BuildContext context) {
    print("Event ${gameEvent.playerUid}");
    return Card(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            SizedBox(
              width: showTimestamp ? 80.0 : 0.0,
              child: showTimestamp
                  ? Text(
                      format.format(gameEvent.timestamp),
                      textScaleFactor: 1.2,
                    )
                  : Text(""),
            ),
            Text(
              Messages.of(context).getGameEventType(gameEvent),
              style: Theme
                  .of(context)
                  .textTheme
                  .title,
              textScaleFactor: 1.2,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
            SizedBox(width: 20.0),
            Text(
              showPeriod
                  ? Messages.of(context).getPeriodName(gameEvent.period)
                  : "",
              softWrap: true,
              overflow: TextOverflow.fade,
              textScaleFactor: 1.2,
              style: Theme
                  .of(context)
                  .textTheme
                  .body1,
            ),
            SizedBox(width: 20.0),
            gameEvent.playerUid != null && gameEvent.playerUid.isNotEmpty
                ? showName
                    ? PlayerName(
                        playerUid: gameEvent.playerUid,
                      )
                    : SizedBox(width: 0)
                : showPeriod
                    ? SizedBox(
                        width: 0,
                      )
                    : Text(
              Messages.of(context).getPeriodName(gameEvent.period),
              style: Theme
                  .of(context)
                  .textTheme
                  .body1,
              softWrap: true,
              overflow: TextOverflow.fade,
                      ),
          ],
        ),
      ),
    );
  }
}
