import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/teamdetailsexpansionpanel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
      child: _PlayerDetails(playerUid),
    );
  }
}

class _PlayerDetails extends StatefulWidget {
  final String playerUid;

  _PlayerDetails(this.playerUid);

  @override
  State<StatefulWidget> createState() {
    return _PlayerDetailsState();
  }
}

class _PlayerDetailsState extends State<_PlayerDetails> {
  bool _showGraphs = false;

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
              title: Text(Messages.of(context).titleOfApp),
            ),
            body: LoadingWidget(),
          );
        }
        if (state is SinglePlayerDeleted) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Messages.of(context).titleOfApp),
            ),
            body: DeletedWidget(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Messages.of(context).titleOfApp),
          ),
          body: Container(
            child: OrientationBuilder(
                builder: (BuildContext context, Orientation o) {
              return _playerDetailsStuff(context, o, state);
            }),
          ),
          floatingActionButton: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (Widget w, Animation a) =>
                ScaleTransition(scale: a, child: w),
            child: _showGraphs
                ? SizedBox(
                    height: 0,
                  )
                : FloatingActionButton.extended(
                    heroTag: "editPlayer",
                    icon: Icon(Icons.edit),
                    label: Text(Messages.of(context).editButton),
                    onPressed: () => Navigator.pushNamed(
                        context, "/Player/Edit/" + state.player.uid),
                  ),
          ),
        );
      },
    );
  }

  Widget _playerDetailsStuff(
      BuildContext context, Orientation orientation, SinglePlayerState state) {
    if (orientation == Orientation.portrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _playerDetails(context, state),
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
                showGraphs: _showGraphs,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _playerDetails(context, state),
            ButtonBar(
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(MdiIcons.chartLine),
                  label: Text(Messages.of(context).stats),
                  onPressed: () => setState(() => _showGraphs = !_showGraphs),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _doDelete(context, state),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: TeamDetailsExpansionPanel(
            games: state.games,
            playerUid: state.player.uid,
            showGraphs: _showGraphs,
          ),
        ),
      ],
    );
  }

  Widget _playerDetails(BuildContext context, SinglePlayerState state) {
    return Wrap(
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
            border: Border.all(color: Theme.of(context).accentColor),
          ),
        ),
        SizedBox(width: 20.0),
        Text(
          state.player.name,
          style: Theme.of(context).textTheme.headline5,
          textScaleFactor: 1.5,
        ),
      ],
    );
  }

  void _doDelete(BuildContext context, SinglePlayerState state) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(Messages.of(context).deletePlayer),
          content: Text(
              Messages.of(context).deletePlayerAreYouSure(state.player.name)),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel,
                  style: Theme.of(context).textTheme.button),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
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
