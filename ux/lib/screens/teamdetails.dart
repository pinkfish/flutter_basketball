import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

class TeamDetailsScreen extends StatelessWidget {
  final String teamUid;

  TeamDetailsScreen({@required this.teamUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleTeamBloc(
            teamBloc: BlocProvider.of<TeamsBloc>(context), teamUid: teamUid),
        child: Center(
          child: BlocListener(
            bloc: BlocProvider.of<SingleTeamBloc>(context),
            listener: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamDeleted) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              bloc: BlocProvider.of<SingleTeamBloc>(context),
              builder: (BuildContext context, SingleTeamBlocState state) {
                if (state is SingleTeamDeleted) {
                  return Text(Messages.of(context).loading);
                }
                if (state is SingleTeamLoaded) {
                  return Column(
                    children: [],
                  );
                }

                return Text("Unknown");
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGame,
        tooltip: Messages.of(context).addGameTooltip,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _addGame() {}
}
