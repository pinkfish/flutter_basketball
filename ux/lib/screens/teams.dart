import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/services/loginbloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/statsdrawer.dart';
import '../widgets/team/teamwidget.dart';

class TeamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      drawer: StatsDrawer(),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: BlocBuilder(
            bloc: BlocProvider.of<AuthenticationBloc>(context),
            builder: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationLoggedInUnverified) {
                // Say you need to verify first.
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Messages.of(context)
                        .verifyexplanation(state.user.email)),
                    RaisedButton(
                        child:
                            new Text(Messages.of(context).resendverifyButton),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () => BlocProvider.of<LoginBloc>(context)
                            .add(LoginEventResendEmail())),
                    RaisedButton(
                        child: new Text(Messages.of(context).logoutButton),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () => BlocProvider.of<LoginBloc>(context)
                            .add(LoginEventLogout()))
                  ],
                );
              } else {
                return BlocBuilder(
                  key: Key('teamsContent'),
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
                      return ListView(
                        children:
                            state.teams.map((t) => TeamWidget(t)).toList(),
                      );
                    }
                    return Text(Messages.of(context).unknown);
                  },
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTeam(context),
        tooltip: Messages.of(context).addTeamTooltip,
        icon: Icon(Icons.add),
        label: Text(Messages.of(context).addTeamButton),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _addTeam(BuildContext context) {
    Navigator.pushNamed(context, "/AddTeam");
  }
}
