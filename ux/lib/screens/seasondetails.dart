import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/game/gametile.dart';
import '../widgets/loading.dart';
import '../widgets/player/playertile.dart';
import '../widgets/savingoverlay.dart';
import 'addplayerseason.dart';

class SeasonDetailsScreen extends StatefulWidget {
  final String seasonUid;

  SeasonDetailsScreen({@required this.seasonUid});

  @override
  State<StatefulWidget> createState() {
    return _SeasonDetailsScreenState();
  }
}

class _SeasonDetailsScreenState extends State<SeasonDetailsScreen> {
  int _currentIndex = 0;

  Widget _innerData(SingleSeasonBlocState state) {
    if (_currentIndex == 0) {
      Widget inner;
      if (!state.loadedGames) {
        inner = Center(
          child: Text(
            Messages.of(context).loadingText,
            textScaleFactor: 2.0,
          ),
        );
      } else if (state.games.isEmpty) {
        inner = Center(
          child: Text(
            Messages.of(context).noGames,
            textScaleFactor: 2.0,
          ),
        );
      } else {
        inner = ListView(
          children: state.games
              .map(
                (Game g) => Padding(
                    padding: EdgeInsets.all(5.0),
                    child: GameTile(
                      game: g,
                      onTap: () =>
                          Navigator.pushNamed(context, "/Season/View/" + g.uid),
                    )),
              )
              .toList(),
        );
      }
      return Column(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text(
                state.season.name,
                textScaleFactor: 1.5,
              ),
              subtitle: Text(
                "${state.season.playerUids.length} players",
                textScaleFactor: 1.5,
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(
                    context, "/Season/Edit/" + widget.seasonUid),
              ),
            ),
          ),
          Expanded(
            child: inner,
          ),
        ],
      );
    } else {
      if (state.season.playerUids.isEmpty) {
        return Center(
          child: Text(Messages.of(context).noPlayers),
        );
      }
      return ListView(
        children: state.season.playerUids.keys
            .map((String str) => PlayerTile(
                  playerUid: str,
                  onTap: (String playerUid) =>
                      Navigator.pushNamed(context, "/Player/View/" + str),
                ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        var bloc = SingleSeasonBloc(
            db: BlocProvider.of<TeamsBloc>(context).db,
            seasonUid: widget.seasonUid);
        bloc.add(SingleSeasonLoadGames());
        return bloc;
      },
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: BlocBuilder(
              bloc: BlocProvider.of<SingleSeasonBloc>(context),
              builder: (BuildContext context, SingleSeasonBlocState state) {
                if (state is SingleSeasonUninitialized ||
                    state is SingleSeasonDeleted) {
                  return Text(Messages.of(context).titleOfApp);
                }
                return Text(state.season.name);
              },
            ),
          ),
          body: BlocConsumer(
            bloc: BlocProvider.of<SingleSeasonBloc>(context),
            listener: (BuildContext context, SingleSeasonBlocState state) {
              if (!state.loadedGames && !(state is SingleSeasonUninitialized)) {
                BlocProvider.of<SingleSeasonBloc>(context)
                    .add(SingleSeasonLoadGames());
              }
              if (state is SingleSeasonDeleted) {
                print("Pop deleted");
                Navigator.pop(context);
              }
            },
            builder: (BuildContext context, SingleSeasonBlocState state) {
              if (state is SingleSeasonDeleted) {
                return DeletedWidget();
              }
              if (state is SingleSeasonUninitialized) {
                return LoadingWidget();
              }
              return SavingOverlay(
                  saving: state is SingleSeasonSaving,
                  child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: _innerData(state)));
            },
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
          floatingActionButton: BlocBuilder(
            bloc: BlocProvider.of<SingleSeasonBloc>(context),
            builder: (BuildContext context, SingleSeasonBlocState state) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: FloatingActionButton.extended(
                  onPressed: _currentIndex == 0
                      ? () => _addGame(context, state.season.uid, state)
                      : () => _addPlayer(context),
                  tooltip: _currentIndex == 0
                      ? Messages.of(context).addGameTooltip
                      : Messages.of(context).addPlayerTooltip,
                  icon: Icon(Icons.add),
                  label: _currentIndex == 0
                      ? Text(Messages.of(context).addGameButton)
                      : Text(Messages.of(context).addPlayerButton),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _addGame(
      BuildContext context, String seasonUid, SingleSeasonBlocState state) {
    if (state.season.playerUids.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(Messages.of(context).noPlayers),
          content: Text(
            Messages.of(context).noPlayersForSeasonDialog,
            softWrap: true,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                print("Ok button");
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, "/Game/Add/" + seasonUid);
    }
  }

  void _addPlayer(BuildContext context) {
    SingleSeasonBloc bloc = // ignore: close_sinks
        BlocProvider.of<SingleSeasonBloc>(context);
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AddPlayerSeasonScreen(
              defaultSeasonUid: widget.seasonUid,
            )).then((FutureOr<String> playerUid) {
      if (playerUid == null || playerUid == "") {
        // Canceled.
        return;
      }
      bloc.add(SingleSeasonAddPlayer(playerUid: playerUid));
    });
  }
}
