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
  final double textScaleFactor;

  static Map<String, String> _nameCache = {};

  PlayerName({@required this.playerUid, this.textScaleFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: Key("player$playerUid"),
      create: (BuildContext context) => SinglePlayerBloc(
          playerUid: this.playerUid,
          db: BlocProvider.of<TeamsBloc>(context).db),
      child: Builder(
        builder: (BuildContext context) {
          return BlocBuilder(
            bloc: BlocProvider.of<SinglePlayerBloc>(context),
            builder: (BuildContext context, SinglePlayerState state) {
              if (_nameCache.containsKey(playerUid) &&
                  !(state is SinglePlayerLoaded)) {
                return Text(
                  _nameCache[playerUid],
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textScaleFactor: textScaleFactor,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SinglePlayerDeleted) {
                return Text(
                  Messages.of(context).unknown,
                  textScaleFactor: textScaleFactor,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SinglePlayerUninitialized) {
                return Text(
                  Messages.of(context).loading,
                  textScaleFactor: textScaleFactor,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SinglePlayerLoaded) {
                _nameCache[playerUid] = state.player.name;
                return Text(
                  state.player.name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textScaleFactor: textScaleFactor,
                  textAlign: TextAlign.start,
                );
              }
              return Text(
                Messages.of(context).unknown,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.start,
                textScaleFactor: textScaleFactor,
              );
            },
          );
        },
      ),
    );
  }
}
