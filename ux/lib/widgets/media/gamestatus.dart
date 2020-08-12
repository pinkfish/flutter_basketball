import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

///
/// Figure out the current statue of the game
///
class GameStatus {
  Duration nextEvent = Duration.zero;
  int ptsFor = 0;
  int ptsAgainst = 0;
  int foulsFor = 0;
  int foulsAgainst = 0;
  GamePeriod period = GamePeriod.NotStarted;

  GameStatus({@required SingleGameState state, @required Duration position}) {
    updateState(state: state, position: position);
  }

  bool updateState({Duration position, SingleGameState state}) {
    Duration nextEvent = Duration.zero;
    int ptsFor = 0;
    int ptsAgainst = 0;
    int foulsFor = 0;
    int foulsAgainst = 0;

    // Recalulate the score/fouls.
    for (var ev in state.gameEvents) {
      if (ev.eventTimeline < position) {
        switch (ev.type) {
          case GameEventType.Made:
            if (ev.opponent) {
              ptsAgainst += ev.points;
            } else {
              ptsFor += ev.points;
            }
            break;
          case GameEventType.Missed:
            break;
          case GameEventType.Foul:
            if (ev.opponent) {
              foulsAgainst++;
            } else {
              foulsFor++;
            }
            break;
          case GameEventType.Sub:
            break;
          case GameEventType.OffsensiveRebound:
            break;
          case GameEventType.DefensiveRebound:
            break;
          case GameEventType.Block:
            break;
          case GameEventType.Steal:
            break;
          case GameEventType.Turnover:
            break;
          case GameEventType.PeriodStart:
            period = ev.period;
            break;
        }
      }
    }
    if (nextEvent != this.nextEvent ||
        ptsFor != this.ptsFor ||
        ptsAgainst != this.ptsAgainst ||
        period != this.period ||
        foulsFor != this.foulsFor ||
        foulsAgainst != this.foulsAgainst) {
      this.nextEvent = nextEvent;
      this.ptsFor = ptsFor;
      this.ptsAgainst = ptsAgainst;
      this.foulsFor = foulsFor;
      this.foulsAgainst = foulsAgainst;
      return true;
    }
    return false;
  }
}
