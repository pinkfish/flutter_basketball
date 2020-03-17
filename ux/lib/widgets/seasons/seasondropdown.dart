import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

///
/// A drop down to select a season from the team.
///
class SeasonDropDown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  SeasonDropDown({@required this.value, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<SingleTeamBloc>(context),
      listener: (BuildContext context, SingleTeamBlocState state) {
        if (state is SingleTeamLoaded && !state.loadedSeasons) {
          BlocProvider.of<SingleTeamBloc>(context).add(SingleTeamLoadSeasons());
        }
      },
      builder: (BuildContext context, SingleTeamBlocState state) {
        if (state is SingleTeamUninitialized ||
            state is SingleTeamDeleted ||
            !state.loadedSeasons) {
          return DropdownButton(
            value: value,
            items: [
              DropdownMenuItem(
                value: value,
                child: Text(Messages.of(context).loading),
              ),
            ],
            onChanged: onChanged,
          );
        }
        return DropdownButton(
          value: value,
          items: state.seasons.map((Season s) => DropdownMenuItem(
                value: s.uid,
                child: Text(s.name),
              )),
          onChanged: onChanged,
        );
      },
    );
  }
}
