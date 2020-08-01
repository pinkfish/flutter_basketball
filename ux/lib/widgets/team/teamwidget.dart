import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/deleted.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';

///
/// Shows a widget for the team.
///
class TeamWidget extends StatelessWidget {
  final String teamUid;
  final Team team;
  final GestureTapCallback onTap;
  final bool showGameButton;

  TeamWidget(
      {String teamUid, this.team, this.onTap, this.showGameButton = true})
      : assert(team != null || teamUid != null),
        this.teamUid = teamUid ?? team.uid;

  @override
  Widget build(BuildContext context) {
    if (team != null) {
      return _buildTeam(context, team);
    } else {
      return BlocProvider(
        create: (BuildContext context) => SingleTeamBloc(
            teamUid: teamUid, db: BlocProvider.of<TeamsBloc>(context).db),
        child: Builder(
          builder: (BuildContext context) => BlocConsumer(
            cubit: BlocProvider.of<SingleTeamBloc>(context),
            listener: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamLoaded && !state.loadedSeasons) {
                BlocProvider.of<SingleTeamBloc>(context)
                    .add(SingleTeamLoadSeasons());
              }
            },
            builder: (BuildContext context, SingleTeamBlocState state) {
              var widget;
              if (state is SingleTeamLoaded) {
                widget = _buildTeam(context, state.team);
              } else if (state is SingleTeamUninitialized) {
                widget = Card(
                  child: Column(
                    children: [
                      ListTile(
                        dense: false,
                        title: Text(
                          Messages.of(context).loadingText,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        subtitle: Text(
                          Messages.of(context).loadingText,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        leading: Container(
                          constraints: BoxConstraints.tight(
                            Size(
                              60.0,
                              60.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/hands_and_trophy.png"),
                              fit: BoxFit.fitHeight,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      showGameButton
                          ? ButtonBar(
                              children: <Widget>[
                                FlatButton.icon(
                                  icon: Icon(MdiIcons.basketball),
                                  label: Text(
                                    Messages.of(context).gamesButton,
                                    textScaleFactor: 1.2,
                                    style: Theme.of(context).textTheme.button,
                                  ),
                                  onPressed: null,
                                ),
                              ],
                            )
                          : SizedBox(height: 0),
                    ],
                  ),
                );
              } else if (state is SingleTeamDeleted) {
                widget = DeletedWidget();
              }

              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: widget,
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildTeam(BuildContext context, Team localTeam) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Card(
        child: Column(
          children: [
            ListTile(
              dense: false,
              title: Text(
                localTeam.name,
                style: Theme.of(context).textTheme.headline5,
              ),
              subtitle: team != null ? null : _TeamSummary(),
              leading: Hero(
                tag: "team" + localTeam.uid,
                child: AnimatedContainer(
                  constraints: BoxConstraints.tight(
                    Size(
                      60.0,
                      60.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    image: DecorationImage(
                      image: localTeam.photoUid != null
                          ? NetworkImage(localTeam.photoUid)
                          : AssetImage("assets/images/hands_and_trophy.png"),
                      fit: BoxFit.fitHeight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  duration: Duration(milliseconds: 500),
                ),
              ),
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
    );
  }

  void _onTap(BuildContext context) {
    var r = RepositoryProvider.of<Router>(context);
    r.navigateTo(context, "/Team/View/" + teamUid,
        transition: TransitionType.inFromRight);
  }
}

class _TeamSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        cubit: BlocProvider.of<SingleTeamBloc>(context),
        builder: (BuildContext context, SingleTeamBlocState state) {
          if (state is SingleTeamLoaded && !state.loadedSeasons ||
              state is SingleTeamUninitialized) {
            return Text(Messages.of(context).loadingText,
                style: Theme.of(context).textTheme.subtitle1);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(Messages.of(context).playedSeasons(state.seasons.length),
                  style: Theme.of(context).textTheme.subtitle1),
            ],
          );
        });
  }
}
