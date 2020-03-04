import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';

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
                  style: Theme.of(context).textTheme.title,
                ),
                subtitle: _TeamSummary(),
                leading: team.photoUid != null
                    ? Image.network(team.photoUid)
                    : Icon(Icons.people),
                onTap: () => _onTap(context),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(MdiIcons.graph),
                    label: Text(Messages.of(context).statsButton),
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
    print(team.uid);
    Navigator.pushNamed(context, "/Team/" + team.uid);
  }
}

class _TeamSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        bloc: BlocProvider.of<SingleTeamBloc>(context),
        listener: (BuildContext context, SingleTeamBlocState state) {
          if (state is SingleTeamLoaded && !state.loadedGames) {
            BlocProvider.of<SingleTeamBloc>(context).add(SingleTeamLoadGames());
          }
        },
        builder: (BuildContext context, SingleTeamBlocState state) {
          if (state is SingleTeamLoaded && !state.loadedGames ||
              state is SingleTeamUninitialized) {
            return Text(Messages.of(context).loading,
                style: Theme.of(context).textTheme.subtitle);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Played ${state.games.length} games",
                  style: Theme.of(context).textTheme.subtitle),
              Text("${state.team.playerUids.length} players",
                  style: Theme.of(context).textTheme.subtitle)
            ],
          );
        });
  }
}
