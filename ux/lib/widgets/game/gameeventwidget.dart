import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playername.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../messages.dart';

/// Signature for when a tap has occurred on a GameEventWidget
typedef GameEventTapCallback = void Function(GameEvent ev);

///
/// Shows a game event, for use in lists.  It models the event as a card
/// that can be places inside other lists and places.
///
class GameEventWidget extends StatelessWidget {
  final GameEvent gameEvent;
  final bool showTimestamp;
  final bool showPeriod;
  final bool showName;
  final GameEventTapCallback onTap;

  static DateFormat format = DateFormat("HH:mm");

  GameEventWidget(
      {@required this.gameEvent,
      this.showTimestamp = false,
      this.showPeriod = false,
      this.showName = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getColor(context),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () => onTap(gameEvent),
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
                style: Theme.of(context).textTheme.headline6,
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
                style: Theme.of(context).textTheme.bodyText2,
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
                          style: Theme.of(context).textTheme.bodyText2,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    Color c = Theme.of(context).cardColor;

    switch (gameEvent.type) {
      case GameEventType.Assist:
      case GameEventType.Made:
        return c.withRed(50);
      case GameEventType.Missed:
        return c.withGreen(50);
      case GameEventType.Steal:
      case GameEventType.Turnover:
      case GameEventType.Block:
      case GameEventType.Foul:
      case GameEventType.DefensiveRebound:
      case GameEventType.OffsensiveRebound:
        return c.withBlue(50);
      case GameEventType.PeriodEnd:
      case GameEventType.PeriodStart:
      case GameEventType.PeriodStart:
      case GameEventType.Sub:
      case GameEventType.TimeoutStart:
      case GameEventType.TimeoutEnd:
        return c;
      default:
        throw ArgumentError(gameEvent.type.toString());
    }
  }
}
