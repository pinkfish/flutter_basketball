import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/game/gamemedialist.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';

///
/// Shows video details about the game.
///
class GameVideoListScreen extends StatelessWidget {
  final String gameUid;

  GameVideoListScreen(this.gameUid);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SingleGameBloc>(
      create: (BuildContext context) => SingleGameBloc(
          gameUid: gameUid, db: BlocProvider.of<TeamsBloc>(context).db),
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return BlocConsumer(
            bloc: BlocProvider.of<SingleGameBloc>(context),
            listener: (BuildContext context, SingleGameState state) {
              if (state is SingleGameDeleted) {
                Navigator.pop(context);
              }
              if (state is SingleGameLoaded && !state.loadedGameEvents) {
                BlocProvider.of<SingleGameBloc>(context)
                    .add(SingleGameLoadEvents());
              }
            },
            builder: (BuildContext context, SingleGameState state) {
              return _GameVideoScaffold(state, orientation);
            },
          );
        },
      ),
    );
  }
}

class _GameVideoScaffold extends StatefulWidget {
  final SingleGameState state;
  final Orientation orientation;

  _GameVideoScaffold(this.state, this.orientation);

  @override
  State<StatefulWidget> createState() {
    return _GameVideoScaffoldState();
  }
}

class _GameVideoScaffoldState extends State<_GameVideoScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.state.game == null
            ? Text(Messages.of(context).title)
            : Text("vs " + widget.state.game.opponentName,
                style: Theme.of(context).textTheme.headline4),
      ),
      body: SavingOverlay(
        saving: widget.state is SingleGameSaving,
        child: Center(
          child: AnimatedSwitcher(
            child: _getBody(context, widget.state),
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addMedia,
      ),
    );
  }

  Widget _getBody(BuildContext context, SingleGameState state) {
    if (state is SingleGameDeleted) {
      return DeletedWidget();
    }
    if (state is SingleGameUninitialized) {
      return LoadingWidget();
    }
    return GameMediaList();
  }

  void _addMedia() {
    Navigator.pushNamed(context, "Media/Add/${widget.state.game.uid}");
  }
}
