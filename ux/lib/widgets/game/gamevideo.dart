import 'package:basketballdata/bloc/singlegamebloc.dart';
import 'package:basketballstats/messages.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class GameVideo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GameVideoState();
  }
}

class _GameVideoState extends State<GameVideo> {
  VideoPlayerController _controller;
  String _currentUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<SingleGameBloc>(context),
      listener: (BuildContext context, SingleGameState state) {
        if (state is SingleGameLoaded) {
          String newUrl;
          if (state.game.streamingUrl.isNotEmpty) {
            newUrl = state.game.streamingUrl;
          } else if (state.game.playbackUrl.isNotEmpty) {
            newUrl = state.game.playbackUrl;
          }
          if (newUrl != _currentUrl) {
            _currentUrl = newUrl;
            _controller?.dispose();
            _controller = VideoPlayerController.network(newUrl)
              ..initialize().then((_) {
                setState(() {});
              });
          }
        }
      },
      builder: (BuildContext context, SingleGameState state) {
        Widget stuff;

        if (state is SingleGameUninitialized) {
          stuff = Text(Messages.of(context).loading);
        } else if (state is SingleGameDeleted) {
          stuff = Text(Messages.of(context).unknown);
        } else {
          if (_controller != null) {
            stuff = VideoPlayer(_controller);
          } else {
            stuff = Column(
              children: <Widget>[
                Text(Messages.of(context).noVideo),
                ButtonBar(
                  children: <Widget>[
                    RaisedButton(
                      child: Text(Messages.of(context).streamButton),
                      onPressed: _startStreaming,
                    ),
                    RaisedButton(
                      child: Text(Messages.of(context).uploadButton),
                      onPressed: _startUploading,
                    ),
                  ],
                )
              ],
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

  void _startStreaming() {}

  void _startUploading() {}
}
