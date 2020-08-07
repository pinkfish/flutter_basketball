import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';
import '../widgets/player/playeredit.dart';
import '../widgets/savingoverlay.dart';

///
/// Adds a player to the game worl.
///
class AddPlayerGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addPlayerTooltip),
      ),
      body: BlocProvider(
        create: (BuildContext context) => AddPlayerBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context)
            , crashes: RepositoryProvider.of<CrashReporting>(context)
        ),
        child: _AddPlayerGameInside(),
      ),
    );
  }
}

class _AddPlayerGameInside extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPlayerGameInsideState();
  }
}

class _AddPlayerGameInsideState extends State<_AddPlayerGameInside> {
  bool _opponent;

  void _saveForm(
      AddPlayerBloc bloc, String name, String jersey, bool opponent) {
    this._opponent = opponent;
    bloc.add(AddPlayerEventCommit(
        newPlayer: Player((b) => b
          ..name = name
          ..jerseyNumber = jersey ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: BlocProvider.of<AddPlayerBloc>(context),
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          // Pass back the player uid.
          Navigator.pop(
            context,
            Tuple2(state.uid, _opponent),
          );
        }
        if (state is AddItemSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        cubit: BlocProvider.of<AddPlayerBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
            saving: state is AddItemSaving,
            child: PlayerEdit(
              hasOpponentField: false,
              onSave: (String name, String jersey, bool opponent) => _saveForm(
                  BlocProvider.of<AddPlayerBloc>(context),
                  name,
                  jersey,
                  opponent),
            ),
          );
        },
      ),
    );
  }
}
