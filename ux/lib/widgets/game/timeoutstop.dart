import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

class TimeoutEnd extends StatelessWidget {
  final Game game;

  TimeoutEnd({@required this.game});

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
          AppBar(
            title: Text("vs ${game.opponentName}"),
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
              Text(Messages.of(context).endTimeout),
              FlatButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  Messages.of(context).endButton,
                  textScaleFactor: 2.0,
                ),
                onPressed: () {
                  // ignore: close_sinks
                  var bloc = BlocProvider.of<SingleGameBloc>(context);
                  var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
                  undoBloc.addEvent(
                    GameEvent((b) => b
                      ..gameUid = game.uid
                      ..playerUid = ""
                      ..period = game.currentPeriod
                      ..timestamp = DateTime.now().toUtc()
                      ..opponent = false
                      ..eventTimeline = bloc.state.game.currentGameTime
                      ..points = 0
                      ..type = GameEventType.TimeoutEnd),
                    false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
