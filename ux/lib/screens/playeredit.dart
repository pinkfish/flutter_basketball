import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playeredit.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// Edit a player ing the world.
///
class PlayerEditScreen extends StatelessWidget {
  final String playerUid;

  PlayerEditScreen(this.playerUid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).editPlayerTitle),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SinglePlayerBloc(
            db: BlocProvider.of<TeamsBloc>(context).db,
            playerUid: playerUid,
            crashes: RepositoryProvider.of<CrashReporting>(context)),
        child: _PlayerEditInside(playerUid),
      ),
    );
  }
}

class _PlayerEditInside extends StatelessWidget {
  final String playerUid;

  _PlayerEditInside(this.playerUid);

  void _saveForm(SinglePlayerBloc bloc, String name, String jersey) {
    bloc.add(SinglePlayerUpdate(
        player: Player((b) => b
          ..uid = playerUid
          ..name = name
          ..jerseyNumber = jersey ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: BlocProvider.of<SinglePlayerBloc>(context),
      listener: (BuildContext context, SinglePlayerState state) {
        if (state is SinglePlayerSaveSuccessful) {
          // Pass back the player uid.
          Navigator.pop(context, playerUid);
        }
        if (state is SinglePlayerSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        cubit: BlocProvider.of<SinglePlayerBloc>(context),
        builder: (BuildContext context, SinglePlayerState state) {
          if (state is SinglePlayerUninitialized) {
            return SavingOverlay(saving: true, child: Text(""));
          }
          return SavingOverlay(
            saving: state is SinglePlayerSaving,
            child: PlayerEdit(
              hasOpponentField: false,
              player: state.player,
              onSave: (String name, String jersey, bool opponent) => _saveForm(
                  BlocProvider.of<SinglePlayerBloc>(context), name, jersey),
            ),
          );
        },
      ),
    );
  }
}
