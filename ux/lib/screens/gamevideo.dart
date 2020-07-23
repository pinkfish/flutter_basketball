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
            ? Text(Messages.of(context).titleOfApp)
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

  void _addMedia() async {
    var style = Theme.of(context).textTheme.bodyText2;
    switch (await showDialog<MediaType>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(Messages.of(context).selectMediaType),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, MediaType.Image),
                  child:
                      Text(Messages.of(context).imageMediaType, style: style),
                ),
                SimpleDialogOption(
                  onPressed: () =>
                      Navigator.pop(context, MediaType.VideoStreaming),
                  child:
                      Text(Messages.of(context).streamMediaType, style: style),
                ),
                SimpleDialogOption(
                  onPressed: () =>
                      Navigator.pop(context, MediaType.VideoOnDemand),
                  child:
                      Text(Messages.of(context).videoMediaType, style: style),
                ),
              ]);
        })) {
      case MediaType.Image:
        Navigator.pushNamed(
            context, "Media/Add/Photo/${widget.state.game.uid}");
        break;
      case MediaType.VideoOnDemand:
        Navigator.pushNamed(context, "Media/Add/Url/${widget.state.game.uid}");
        break;
      case MediaType.VideoStreaming:
        Navigator.pushNamed(
            context, "Media/Add/Stream/${widget.state.game.uid}");
        break;
    }
  }
}
