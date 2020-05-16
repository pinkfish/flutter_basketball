import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/media/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';

///
/// Shows video details about the game.
///
class GameVideoPlayerScreen extends StatelessWidget {
  final String gameUid;
  final String mediaUid;

  GameVideoPlayerScreen(this.gameUid, this.mediaUid);

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
              if (state is SingleGameLoaded && !state.loadedMedia) {
                BlocProvider.of<SingleGameBloc>(context)
                    .add(SingleGameLoadMedia());
              }
            },
            builder: (BuildContext context, SingleGameState state) {
              return _GameVideoScaffold(state, mediaUid, orientation);
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
  final String mediaUid;

  _GameVideoScaffold(this.state, this.mediaUid, this.orientation);

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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              title: Text(Messages.of(context).playVideoTitle)),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.chartLine),
              title: Text(Messages.of(context).eventList)),
        ],
      ),
    );
  }

  Widget _getBody(BuildContext context, SingleGameState state) {
    if (state is SingleGameDeleted) {
      return DeletedWidget();
    }
    if (state is SingleGameUninitialized || !state.loadedMedia) {
      return LoadingWidget();
    }
    MediaInfo myInfo = state.media.firstWhere((e) => e.uid == widget.mediaUid);
    return GameVideoPlayer(
      state: state,
      video: myInfo,
    );
  }
}
