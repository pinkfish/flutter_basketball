import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/teamdetailsexpansionpanel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/loading.dart';

///
/// Shows the details for the player in a nice happy screen.
///
class PlayerDetailsScreen extends StatelessWidget {
  final String playerUid;

  PlayerDetailsScreen(this.playerUid);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SinglePlayerBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          playerUid: playerUid),
      child: _PlayerDetails(),
    );
  }
}

class _PlayerDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<SinglePlayerBloc>(context),
      listener: (BuildContext context, SinglePlayerState state) {
        if (state is SinglePlayerLoaded && !state.loadedGames) {
          BlocProvider.of<SinglePlayerBloc>(context)
              .add(SinglePlayerLoadGames());
        }
        if (state is SinglePlayerDeleted) {
          Navigator.pop(context);
        }
      },
      builder: (BuildContext context, SinglePlayerState state) {
        if (state is SinglePlayerUninitialized) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Messages.of(context).title),
            ),
            body: LoadingWidget(),
          );
        }
        if (state is SinglePlayerDeleted) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Messages.of(context).title),
            ),
            body: DeletedWidget(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Messages.of(context).title),
          ),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      child: Center(
                        child: Text(
                          state.player.jerseyNumber,
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Theme.of(context).accentColor),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Text(
                      state.player.name,
                      style: Theme.of(context).textTheme.headline,
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                ButtonBar(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _doDelete(context, state),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: TeamDetailsExpansionPanel(
                      games: state.games,
                      playerUid: state.player.uid,
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: "editPlayer",
            icon: Icon(Icons.edit),
            label: Text(Messages
                .of(context)
                .editButton),
            onPressed: () =>
                Navigator.pushNamed(context, "/EditPlayer/" + state.player.uid),
          ),
        );
      },
    );
  }

  void _doDelete(BuildContext context, SinglePlayerState state) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(Messages
              .of(context)
              .deletePlayer),
          content: Text(
              Messages.of(context).deletePlayerAreYouSure(state.player.name)),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations
                  .of(context)
                  .cancelButtonLabel,
                  style: Theme
                      .of(context)
                      .textTheme
                      .button),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: Text(MaterialLocalizations
                  .of(context)
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
  }
}
