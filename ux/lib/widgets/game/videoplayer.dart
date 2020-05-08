import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'gamestatusoverlay.dart';

///
/// Shows video for the specific game.
///
class GameVideoPlayer extends StatefulWidget {
  final SingleGameState state;
  final MediaInfo video;

  GameVideoPlayer({@required this.state, @required this.video});

  Game get() => state.game;

  @override
  State<StatefulWidget> createState() {
    return _GameVideoPlayer();
  }
}

class _GameVideoPlayer extends State<GameVideoPlayer> {
  VideoPlayerController _controller;
  Uri _currentUrl;

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
    Uri newUrl = widget.video.url;
    if (newUrl != _currentUrl) {
      _currentUrl = newUrl;
      _controller?.dispose();
      _controller = VideoPlayerController.network(newUrl.toString())
        ..initialize().then((_) {
          print("Initialized ");
          setState(() {});
        }).catchError((e) {
          print("Error $e");
        });
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: _controller.value.initialized
                ? Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      GameStatusOverlay(
                          controller: _controller, state: widget.state),
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
        ),
        ButtonBar(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _controller.play(),
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () => _controller.pause(),
            ),
          ],
        ),
        Text(
          widget.video.description,
          overflow: TextOverflow.fade,
        ),
      ],
    );
  }
}
