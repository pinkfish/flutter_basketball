import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/team/teamwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/username.dart';

///
/// Shows the users of the team in a nice dialog
///
class TeamUsersScreen extends StatelessWidget {
  final String teamUid;

  TeamUsersScreen({this.teamUid});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).usersTitle),
      ),
      body: Column(
        children: [
          TeamWidget(teamUid: teamUid),
          Expanded(
            child: BlocProvider(
              create: (BuildContext context) {
                var bloc = SingleTeamBloc(
                    db: RepositoryProvider.of<BasketballDatabase>(context),
                    teamUid: teamUid,
                    crashes: RepositoryProvider.of<CrashReporting>(context));
                bloc.add(SingleTeamLoadSeasons());
                return bloc;
              },
              child: Builder(
                builder: (BuildContext context) => BlocBuilder(
                  cubit: BlocProvider.of<SingleTeamBloc>(context),
                  builder: (BuildContext context, SingleTeamState state) {
                    if (state is SingleTeamDeleted) {
                      Navigator.pop(context, false);
                      return Text(Messages.of(context).loadingText);
                    }
                    if (state is SingleTeamUninitialized) {
                      return Text(Messages.of(context).loadingText);
                    }
                    return ListView(
                      padding: EdgeInsets.all(10),
                      children: state.team.users.keys.map((e) {
                        return ListTile(
                          title: UserName(userUid: e),
                          leading: Icon(Icons.person),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          ButtonBar(
            children: [
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
