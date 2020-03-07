import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/player/playeredit.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// Adds a player to the world.
///
class AddPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) =>
            AddPlayerBloc(db: BlocProvider.of<TeamsBloc>(context).db),
        child: _AddPlayerInside(),
      ),
    );
  }
}

class _AddPlayerInside extends StatelessWidget {
  void _saveForm(AddPlayerBloc bloc, String name, String jersey) {
    bloc.add(AddPlayerEventCommit(
        newPlayer: Player((b) => b
          ..name = name
          ..jerseyNumber = jersey ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<AddPlayerBloc>(context),
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          // Pass back the player uid.
          Navigator.pop(context, state.uid);
          print("pop and done");
        }
        if (state is AddItemSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<AddPlayerBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
              saving: state is AddItemSaving,
              child: PlayerEdit(
                onSave: (String name, String jersey) => _saveForm(
                    BlocProvider.of<AddPlayerBloc>(context), name, jersey),
              ));
        },
      ),
    );
  }
}
