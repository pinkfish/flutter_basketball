import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../loading.dart';
import 'gameeventwidget.dart';

///
/// The list of game eevents associated with the single game bloc.
///
class GameEventList extends StatelessWidget {
  final String playerUid;

  GameEventList({this.playerUid});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<SingleGameBloc>(context),
      listener: (BuildContext context, SingleGameState state) {
        if (!state.loadedGameEvents) {
          BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadEvents());
        }
      },
      builder: (BuildContext context, SingleGameState state) {
        if (!state.loadedGameEvents) {
          BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadEvents());
          return Center(
            child: LoadingWidget(),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: state.gameEvents
                .where((e) => e.playerUid == playerUid)
                .map(
                  (GameEvent e) => GameEventWidget(
                    gameEvent: e,
                    showTimestamp: true,
                    showPeriod: true,
                    showName: false,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
