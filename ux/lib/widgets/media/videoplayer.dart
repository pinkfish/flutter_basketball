import 'package:basketballdata/basketballdata.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  void _updateUrl(Uri newUrl) async {
    if (newUrl != _currentUrl) {
      _currentUrl = newUrl;
      String downloadUrl = newUrl.toString();
      if (newUrl.scheme == "gs") {
        var ref = await FirebaseStorage.instance
            .getReferenceFromUrl(newUrl.toString());
        downloadUrl = await ref.getDownloadURL();
      }
      _controller?.dispose();
      _controller = VideoPlayerController.network(downloadUrl)
        ..initialize().then((_) {
          print("Initialized ");
          setState(() {});
        }).catchError((e) {
          print("Error $e");
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    Uri newUrl = widget.video.url;
    _updateUrl(newUrl);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: _controller != null && _controller.value.initialized
                ? Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      GameStatusVideoPlayerOverlay(
                          controller: _controller, state: widget.state),
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
        _controller != null
            ? VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
              )
            : SizedBox(height: 10.0),
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
