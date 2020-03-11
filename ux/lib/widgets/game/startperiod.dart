import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/game/perioddropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

class StartPeriod extends StatefulWidget {
  final Game game;

  StartPeriod({@required this.game});

  @override
  State<StatefulWidget> createState() {
    return _StartPeriodState();
  }
}

class _StartPeriodState extends State<StartPeriod> {
  GamePeriod period;

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
        children: <Widget>[
          Text(
            "vs ${widget.game.opponentName}",
            textScaleFactor: 1.5,
            style: Theme.of(context).textTheme.title,
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/basketball.png",
                height: 90.0,
              ),
            ],
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
                  bloc.add(
                    SingleGameUpdate(
                      game: bloc.state.game.rebuild(
                          (b) => b..runningFrom = DateTime.now().toUtc()),
                    ),
                  );
                },
              ),
            ],
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
    super.initState();
  }
}
