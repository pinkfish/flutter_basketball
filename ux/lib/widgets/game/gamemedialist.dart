import 'package:basketballdata/bloc/singlegamebloc.dart';
import 'package:basketballstats/messages.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../media/mediatypelisttile.dart';

///
/// Shows the controls around the video.  Buttons for uploading/streaming if
/// there is no current video for the game.
///
class GameMediaList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      cubit: BlocProvider.of<SingleGameBloc>(context),
      listener: (BuildContext context, SingleGameState state) {
        print("Got state $state");
        if (state is SingleGameLoaded && !state.loadedMedia) {
          BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadMedia());
        }
        if (state is SingleGameLoaded && !state.loadedGameEvents) {
          BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadEvents());
        }
      },
      builder: (BuildContext context, SingleGameState state) {
        Widget stuff;

        if (state is SingleGameUninitialized || !state.loadedMedia) {
          stuff = Text(Messages.of(context).loadingText);
        } else if (state is SingleGameDeleted) {
          stuff = Text(Messages.of(context).unknown);
        } else {
          if (state.loadedMedia && state.media.length > 0) {
            //stuff = GameVideoPlayer(game: state.game, video: state.media[0]);
            stuff = ListView(
              children: state.media
                  .map((m) => Padding(
                        padding: EdgeInsets.all(5.0),
                        child: MediaTypeListTile(
                          media: m,
                          onTap: () => Navigator.pushNamed(
                              context, "Game/Media/${state.game.uid}/${m.uid}"),
                        ),
                      ))
                  .toList(),
            );
          } else {
            stuff = Center(
              child: Text(Messages.of(context).noMedia,
                  style: Theme.of(context).textTheme.headline3),
            );
          }
        }

        return SavingOverlay(
          saving: state is SingleGameSaving,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: stuff,
          ),
        );
      },
    );
  }
}
