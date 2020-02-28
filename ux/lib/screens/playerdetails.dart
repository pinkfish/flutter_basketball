import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/fabmenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final String playerUid;

  PlayerDetailsScreen(this.playerUid);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => SinglePlayerBloc(
            db: BlocProvider.of<TeamsBloc>(context).db, playerUid: playerUid),
        child: _PlayerDetails());
  }
}

class _PlayerDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocBuilder(
          bloc: BlocProvider.of<SinglePlayerBloc>(context),
          builder: (BuildContext context, SinglePlayerState state) {
            if (state is SinglePlayerUninitialized ||
                state is SinglePlayerDeleted) {
              return Text(Messages.of(context).loading);
            }
            return Stack(children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(state.player.name,
                        style: Theme.of(context).textTheme.headline),
                    Text(state.player.jerseyNumber,
                        style: Theme.of(context).textTheme.subtitle),
                  ],
                ),
              ),
              FabMenu(
                children: <FloatingActionButton>[
                  FloatingActionButton(
                    heroTag: "editPlayer",
                    child: Icon(Icons.edit),
                    onPressed: () => Navigator.pushNamed(
                        context, "/EditPlayer/" + state.player.uid),
                  ),
                  FloatingActionButton(
                    heroTag: "deletePlayer",
                    child: Icon(Icons.delete),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text(Messages.of(context).deletePlayer),
                            content: Text(Messages.of(context)
                                .deletePlayerAreYouSure(state.player.name)),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                    MaterialLocalizations.of(context)
                                        .cancelButtonLabel,
                                    style: Theme.of(context).textTheme.button),
                                onPressed: () {
                                  Navigator.of(dialogContext)
                                      .pop(); // Dismiss alert dialog
                                },
                              ),
                              FlatButton(
                                child: Text(MaterialLocalizations.of(context)
                                    .okButtonLabel),
                                onPressed: () {
                                  BlocProvider.of<SinglePlayerBloc>(context)
                                      .add(SinglePlayerDelete());
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  FloatingActionButton(
                    heroTag: "backbutton",
                    child: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ]);
          }),
    );
  }
}
