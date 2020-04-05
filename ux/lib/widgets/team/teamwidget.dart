import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';

///
/// Shows a widget for the team.
///
class TeamWidget extends StatelessWidget {
  final Team team;
  final GestureTapCallback onTap;

  TeamWidget(this.team, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SingleTeamBloc(
          teamUid: team.uid, db: BlocProvider.of<TeamsBloc>(context).db),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Card(
          child: Column(
            children: [
              ListTile(
                dense: false,
                title: Text(
                  team.name,
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: _TeamSummary(),
                leading: team.photoUid != null
                    ? Image.network(team.photoUid)
                    : Icon(MdiIcons.tshirtCrew),
                onTap: () => _onTap(context),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(MdiIcons.basketball),
                    label: Text(
                      Messages.of(context).gamesButton,
                      textScaleFactor: 1.2,
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () => _onTap(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    Navigator.pushNamed(context, "/Team/" + team.uid);
  }
}

class _TeamSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        bloc: BlocProvider.of<SingleTeamBloc>(context),
        listener: (BuildContext context, SingleTeamBlocState state) {
          if (state is SingleTeamLoaded && !state.loadedSeasons) {
            BlocProvider.of<SingleTeamBloc>(context)
                .add(SingleTeamLoadSeasons());
          }
        },
        builder: (BuildContext context, SingleTeamBlocState state) {
          if (state is SingleTeamLoaded && !state.loadedSeasons ||
              state is SingleTeamUninitialized) {
            return Text(Messages
                .of(context)
                .loading,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(Messages.of(context).playedSeasons(state.seasons.length),
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle1),
            ],
          );
        });
  }
}
