import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/services/loginbloc.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/invites/invitecountbox.dart';
import '../widgets/statsdrawer.dart';
import '../widgets/team/teamwidget.dart';

class TeamsScreen extends StatelessWidget {
  final Trace startTrace;

  TeamsScreen(this.startTrace);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).titleOfApp),
      ),
      drawer: StatsDrawer(),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: BlocBuilder(
            cubit: BlocProvider.of<AuthenticationBloc>(context),
            builder: (BuildContext context, AuthenticationState authState) {
              print("State $authState");
              if (authState is AuthenticationLoggedInUnverified) {
                startTrace.putAttribute("state", "unverified");
                startTrace.stop();
                // Say you need to verify first.
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Messages.of(context)
                        .verifyexplanation(authState.user.email)),
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
                  cubit: BlocProvider.of<TeamsBloc>(context),
                  builder: (BuildContext context, TeamsBlocState state) {
                    if (state is TeamsBlocUninitialized) {
                      return Text(Messages.of(context).loadingText);
                    }
                    if (state is TeamsBlocLoaded) {
                      startTrace.putAttribute(
                          "state",
                          authState is AuthenticationLoggedIn
                              ? "LoggedIn"
                              : "Local");
                      startTrace.incrementMetric("teams", state.teams.length);
                      startTrace.stop();
                      if (state.teams.isEmpty) {
                        return Center(
                          child: Text(Messages.of(context).noTeams),
                        );
                      }
                      if (authState is AuthenticationLoggedIn) {
                        return ListView(
                          children: [
                            new GestureDetector(
                              child: InviteCountBox(),
                              onTap: () =>
                                  Navigator.pushNamed(context, "/Invite/List"),
                            ),
                            ...state.teams
                                .map((t) => TeamWidget(teamUid: t.uid))
                                .toList(),
                          ],
                        );
                      } else {
                        return ListView(
                          children: state.teams
                              .map((t) => TeamWidget(teamUid: t.uid))
                              .toList(),
                        );
                      }
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
    Navigator.pushNamed(context, "/Team/Add");
  }
}
