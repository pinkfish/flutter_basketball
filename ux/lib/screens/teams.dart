import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/statsdrawer.dart';
import '../widgets/teamwidget.dart';

class TeamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      drawer: StatsDrawer(),
      body: Center(
        child: BlocBuilder(
          bloc: BlocProvider.of<TeamsBloc>(context),
          builder: (BuildContext context, TeamsBlocState state) {
            if (state is TeamsBlocUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (state is TeamsBlocLoaded) {
              if (state.teams.isEmpty) {
                return Center(
                  child: Text(Messages.of(context).noTeams),
                );
              }
              return Column(
                children: state.teams.map((t) => TeamWidget(t)).toList(),
              );
            }

            return Text("Unknown");
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTeam(context),
        tooltip: Messages.of(context).addTeamTooltip,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _addTeam(BuildContext context) {
    Navigator.pushNamed(context, "/AddTeam");
  }
}
