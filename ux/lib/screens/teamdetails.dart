import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/playertile.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String teamUid;

  TeamDetailsScreen({@required this.teamUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamDetailsScreenState();
  }
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleTeamBloc(
            teamBloc: BlocProvider.of<TeamsBloc>(context),
            teamUid: widget.teamUid),
        child: Builder(
          builder: (BuildContext context) {
            return Center(
              child: BlocListener(
                bloc: BlocProvider.of<SingleTeamBloc>(context),
                listener: (BuildContext context, SingleTeamBlocState state) {
                  if (!state.loadedGames) {
                    BlocProvider.of<SingleTeamBloc>(context)
                        .add(SingleTeamLoadGames());
                  }
                  if (state is SingleTeamDeleted) {
                    Navigator.pop(context);
                  }
                },
                child: BlocBuilder(
                  bloc: BlocProvider.of<SingleTeamBloc>(context),
                  builder: (BuildContext context, SingleTeamBlocState state) {
                    print(state);
                    if (state is SingleTeamDeleted) {
                      return Text(Messages.of(context).loading);
                    }
                    if (state is SingleTeamLoaded) {
                      if (_currentIndex == 0) {
                        if (!state.loadedGames) {
                          return Center(
                            child: Text(Messages.of(context).loading),
                          );
                        }
                        if (state.games.isEmpty) {
                          return Center(
                            child: Text(Messages.of(context).noGames),
                          );
                        }
                        return Column(
                          children: [],
                        );
                      } else {
                        if (state.team.playerUids.isEmpty) {
                          return Center(
                            child: Text(Messages.of(context).noPlayers),
                          );
                        }
                        return ListView(
                          children: state.team.playerUids.keys
                              .map((String str) => PlayerTile(
                                    playerUid: str,
                                  ))
                              .toList(),
                        );
                      }
                    }

                    return Text("Unknown");
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int i) => setState(() {
          _currentIndex = i;
        }),
        items: [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.tshirtCrew),
            title: Text(Messages.of(context).stats),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text(Messages.of(context).players),
          ),
        ],
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
