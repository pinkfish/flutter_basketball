import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/game/perioddropdown.dart';
import 'package:basketballstats/widgets/game/playermultiselect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

class StartPeriod extends StatefulWidget {
  final Game game;
  final Orientation orientation;

  StartPeriod({@required this.game, @required this.orientation});

  @override
  State<StatefulWidget> createState() {
    return _StartPeriodState();
  }
}

class _StartPeriodState extends State<StartPeriod> {
  GamePeriod period;
  List<String> selectedPlayers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppBar(
            title: Text("vs ${widget.game.opponentName}"),
          ),
          SizedBox(
            height: 20.0,
          ),
          widget.orientation == Orientation.portrait
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/basketball.png",
                      height: 90.0,
                    ),
                  ],
                )
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PeriodDropdown(
                value: period,
                onPeriodChange: (GamePeriod p) => setState(() => period = p),
              ),
              SizedBox(width: 30.0),
              FlatButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  Messages.of(context).startButton,
                  textScaleFactor: 2.0,
                ),
                onPressed: () {
                  // ignore: close_sinks
                  var bloc = BlocProvider.of<SingleGameBloc>(context);
                  bloc.add(
                    SingleGameAddEvent(
                      event: GameEvent((b) => b
                        ..gameUid = widget.game.uid
                        ..playerUid = ""
                        ..period = period
                        ..timestamp = DateTime.now().toUtc()
                        ..opponent = false
                        ..eventTimeline = bloc.state.game.currentGameTime
                        ..points = 0
                        ..type = GameEventType.PeriodStart),
                    ),
                  );
                  // Update the game to start the clock.
                  var players = bloc.state.game.players.map((u, d) => MapEntry(
                      u,
                      d.rebuild((b) =>
                          b..currentlyPlaying = selectedPlayers.contains(u))));
                  var opponents = bloc.state.game.opponents.map((u, d) =>
                      MapEntry(
                          u,
                          d.rebuild((b) => b
                            ..currentlyPlaying = selectedPlayers.contains(u))));
                  bloc.add(
                    SingleGameUpdate(
                      game: bloc.state.game.rebuild((b) => b
                        ..runningFrom = DateTime.now().toUtc()
                        ..currentPeriod = period
                        ..players = players.toBuilder()
                        ..opponents = opponents.toBuilder()),
                    ),
                  );
                },
              ),
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: PlayerMultiselect(
                game: widget.game,
                selectedUids: selectedPlayers,
                selectPlayer: _selectPlayer,
                orientation: widget.orientation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    switch (widget.game.currentPeriod) {
      case GamePeriod.NotStarted:
        period = GamePeriod.Period1;
        break;
      case GamePeriod.Period1:
        period = GamePeriod.Period2;
        break;
      case GamePeriod.Period2:
        period = GamePeriod.Period3;
        break;
      case GamePeriod.Period3:
        period = GamePeriod.Period4;
        break;
      case GamePeriod.Period4:
        period = GamePeriod.OverTime;
        break;
      default:
        period = widget.game.currentPeriod;
        break;
    }

    // Find the currently in play people and mark them.
    widget.game.players.forEach((uid, s) {
      if (s.currentlyPlaying) {
        selectedPlayers.add(uid);
      }
    });
    super.initState();
  }

  /// Updates the current set of selected players.
  void _selectPlayer(String uid, bool remove) {
    print("$uid $remove");
    if (remove) {
      setState(() => selectedPlayers.remove(uid));
    } else {
      setState(() => selectedPlayers.add(uid));
    }
  }
}
