import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/bloc/singleplayerbloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

///
/// Shows the details on the player by giving the name and jersey number.
///
class PlayerName extends StatelessWidget {
  final String playerUid;

  PlayerName({@required this.playerUid});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocProvider(
        key: Key("player$playerUid"),
        create: (BuildContext context) => SinglePlayerBloc(
            playerUid: this.playerUid,
            db: BlocProvider.of<TeamsBloc>(context).db),
        child: Builder(
          builder: (BuildContext context) {
            return BlocBuilder(
              bloc: BlocProvider.of<SinglePlayerBloc>(context),
              builder: (BuildContext context, SinglePlayerState state) {
                if (state is SinglePlayerDeleted) {
                  return Text(Messages.of(context).unknown);
                }
                if (state is SinglePlayerUninitialized) {
                  return Text(Messages.of(context).loading);
                }
                if (state is SinglePlayerLoaded) {
                  print(
                      "PlayerName ${BlocProvider.of<SinglePlayerBloc>(context).playerUid} ${state.player.uid} $playerUid");
                  return Text(
                    state.player.name,
                    style: Theme.of(context).textTheme.title,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  );
                }
                return Text(Messages.of(context).unknown);
              },
            );
          },
        ),
      ),
    );
  }
}
