import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../loading.dart';
import 'gameeventwidget.dart';

///
/// The list of game eevents associated with the single game bloc.
///
class GameEventList extends StatelessWidget {
  final bool Function(GameEvent) eventCheck;
  final bool showName;
  final bool showTimestamp;
  final bool showPeriod;
  final GameEventTapCallback onTap;

  GameEventList(
      {this.eventCheck,
      this.showName = false,
      this.showPeriod = true,
      this.showTimestamp = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<SingleGameBloc>(context),
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
                .where(eventCheck)
                .map(
                  (GameEvent e) => GameEventWidget(
                    gameEvent: e,
                    showTimestamp: showTimestamp,
                    showPeriod: showPeriod,
                    showName: showName,
                    onTap: onTap,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
