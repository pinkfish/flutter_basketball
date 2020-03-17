import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/playeredit.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:basketballstats/widgets/seasons/seasondropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';

import '../messages.dart';

///
/// Adds a player to the world.
///
class AddPlayerSeasonScreen extends StatelessWidget {
  final String defaultSeasonUid;

  AddPlayerSeasonScreen({@required this.defaultSeasonUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) => AddPlayerBloc(
            db: RepositoryProvider.of<BasketballDatabase>(context)),
        child: _AddPlayerSeasonInside(),
      ),
    );
  }
}

class _AddPlayerSeasonInside extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPlayerSeasonInsideState();
  }
}

class _AddPlayerSeasonInsideState extends State<_AddPlayerSeasonInside> {
  String _selectedSeason;

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
          Navigator.pop(context, Tuple2(state.uid, _selectedSeason));
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
            child: Column(
              children: [
                SeasonDropDown(
                  value: _selectedSeason,
                  onChanged: (String s) => setState(() => _selectedSeason = s),
                ),
                PlayerEdit(
                  hasOpponentField: false,
                  onSave: (String name, String jersey, bool opponent) =>
                      _saveForm(BlocProvider.of<AddPlayerBloc>(context), name,
                          jersey),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
