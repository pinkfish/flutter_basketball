import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/mediastreaming.dart';
import 'package:basketballstats/widgets/media/gamestatusoverlay.dart';
import 'package:camera_with_rtmp/camera.dart';
import 'package:camera_with_rtmp/new/src/common/camera_interface.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/savingoverlay.dart';

///
/// Adds a media to the game worl.
///
class AddMediaStreamGameScreen extends StatelessWidget {
  final String gameUid;

  AddMediaStreamGameScreen(this.gameUid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleGameBloc(
          gameUid: gameUid,
          db: RepositoryProvider.of<BasketballDatabase>(context),
        ),
        child: Builder(
          builder: (BuildContext context) => BlocBuilder(
            bloc: BlocProvider.of<SingleGameBloc>(context),
            builder: (BuildContext context, SingleGameState state) =>
                _AddMediaStreamGameInside(state),
          ),
        ),
      ),
    );
  }
}

class _AddMediaStreamGameInside extends StatefulWidget {
  final SingleGameState state;

  _AddMediaStreamGameInside(this.state);

  @override
  State<StatefulWidget> createState() {
    return _AddMediaStreamGameInsideState();
  }
}

class _AddMediaStreamGameInsideState extends State<_AddMediaStreamGameInside> {
  bool _streaming = false;
  bool _saving = false;
  bool _enableAudio = true;
  CameraController _controller;
  SingleMediaInfoBloc _bloc;
  List<CameraDescription> _cameras = [];

  void initState() {
    super.initState();
    _bloc = SingleMediaInfoBloc(
        db: RepositoryProvider.of<BasketballDatabase>(context),
        mediaInfoUid: "bad media info uid");
    availableCameras().then((v) async {
      _cameras = v;
      // Find the back one and use that by default
      var camera = _cameras.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);
      print("Found camera $camera");
      _controller = CameraController(camera, ResolutionPreset.medium,
          enableAudio: _enableAudio);
      _controller.addListener(() async {
        if (mounted) setState(() {});
        if (_controller.value.hasError) {
          showInSnackBar('Camera error ${_controller.value.errorDescription}');
        }
      });
      try {
        await _controller.initialize();
        print("Initialized controller");
        setState(() => true);
      } catch (e, stack) {
        Crashlytics.instance.recordError(e, stack);
        showInSnackBar("Error starting camera");
      }
    });
  }

  Future<void> dispose() async {
    super.dispose();
    await _bloc.close();
    return _controller.dispose();
  }

  void _startStreaming() async {
    // Check first this is what they actually want.

    // Download the url and them upload to storage, then do the update.
    setState(() => _saving = true);
    try {
      var streaming = RepositoryProvider.of<MediaStreaming>(context);
      assert(streaming != null);
      var broadcast = await streaming.createBroadcast(widget.state.game);
      // Navigate to run the broadcast.
      print(broadcast);
      _bloc = SingleMediaInfoBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          mediaInfoUid: broadcast.name);
      // Now we get the media details and subscribe to updates.
      _streaming = true;
      _startVideoStreaming(broadcast.rtmpURL);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
    setState(() => _saving = false);
  }

  /// Returns a suitable camera icon for [direction].
  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return MdiIcons.cameraIris;
    }
    throw ArgumentError('Unknown lens direction');
  }

  void _cameraToggleCamera() {
    if (_controller == null ||
        !_controller.value.isInitialized ||
        _cameras.isEmpty) {
      return;
    }

    var idx =
        _cameras.indexWhere((element) => element == _controller.description);

    onNewCameraSelected(_cameras[(idx + 1) % _cameras.length]);
  }

  @override
  Widget build(BuildContext context) {
    print("Media stuff ${_bloc.state}");
    if (_bloc.state is SingleMediaInfoLoaded &&
        !_controller.value.isStreamingVideoRtmp) {
      print("Starting the stream");
      _startVideoStreaming(_bloc.state.mediaInfo.rtmpUrl.toString());
    }
    return BlocConsumer(
      bloc: _bloc,
      listener: (BuildContext context, SingleMediaInfoState state) {
        if (state is SingleMediaInfoLoaded &&
            !_controller.value.isStreamingVideoRtmp) {
          print("Starting the stream");
          _startVideoStreaming(state.mediaInfo.rtmpUrl.toString());
        }
      },
      builder: (BuildContext context, SingleMediaInfoState state) {
        return SavingOverlay(
          saving: widget.state is SingleGameUninitialized ||
              _saving ||
              _controller == null ||
              !_controller.value.isInitialized,
          child: Stack(
            children: [
              _controller == null || !_controller.value.isInitialized
                  ? CircularProgressIndicator()
                  : AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          CameraPreview(_controller),
                          GestureDetector(
                            onTap: _startStreaming,
                            child: Center(
                              child: _streaming
                                  ? SizedBox(height: 0, width: 0)
                                  : FlatButton(
                                      child: Text(
                                        "START",
                                        textScaleFactor: 2.0,
                                      ),
                                      onPressed: _startStreaming),
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GameStatusPositionOverlay(
                      state: widget.state,
                      position: Duration(days: 5),
                    ),
                    _getButtonBar(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getButtonBar(SingleMediaInfoState state) {
    if (_streaming) {
      return ButtonBar(
        children: <Widget>[
          IconButton(
            icon:
                Icon(_getCameraLensIcon(_controller.description.lensDirection)),
            color: Colors.blue,
            onPressed: _controller != null && _controller.value.isInitialized
                ? _cameraToggleCamera
                : null,
          ),
          IconButton(
            icon: _controller != null && _controller.value.isStreamingPaused
                ? Icon(Icons.play_arrow)
                : Icon(Icons.pause),
            color: Colors.blue,
            onPressed: _controller != null &&
                    _controller.value.isInitialized &&
                    _controller.value.isStreamingVideoRtmp
                ? (_controller != null && _controller.value.isStreamingPaused
                    ? () => onResumeButtonPressed()
                    : () => onPauseButtonPressed())
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            color: Colors.red,
            onPressed: _controller != null &&
                    _controller.value.isInitialized &&
                    _controller.value.isStreamingVideoRtmp
                ? () => onStopButtonPressed()
                : null,
          ),
        ],
      );
    } else {
      return ButtonBar(
        children: <Widget>[
          IconButton(
            icon: Icon(_getCameraLensIcon(
                _controller.description?.lensDirection ?? LensDirection.back)),
            color: Colors.blue,
            onPressed: _controller != null && _controller.value.isInitialized
                ? _cameraToggleCamera
                : null,
          ),
        ],
      );
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    print("New camera ${cameraDescription.name}");
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: _enableAudio,
    );

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e, stack) {
      _showCameraException(e, stack);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoRecordButtonPressed(MediaInfo info) {
    _startVideoStreaming(info.rtmpUrl.toString()).then((bool started) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() async {
    var res = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(Messages.of(context).videoStreaming),
        content: Text(
          Messages.of(context).finishStreamingVideo,
          softWrap: true,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
    if (res == true) {
      var streaming = RepositoryProvider.of<MediaStreaming>(context);
      assert(streaming != null);
      streaming.endBroadcast(this._bloc.state.mediaInfo);

      stopVideoStreaming().then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void onPauseButtonPressed() {
    pauseVideoStreaming().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoStreaming().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<bool> _startVideoStreaming(String uri) async {
    if (!_controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (_controller.value.isStreamingVideoRtmp) {
      return true;
    }

    try {
      _controller.startVideoStreaming(uri.toString());
      // Load the events when we start playing.
      BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadEvents());
    } catch (e, stack) {
      Crashlytics.instance.recordError(e, stack);
      return false;
    }
    return true;

    /*
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isStreamingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoStreaming(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;

     */
  }

  Future<void> stopVideoStreaming() async {
    if (!_controller.value.isStreamingVideoRtmp) {
      return null;
    }

    try {
      await _controller.stopVideoStreaming();
    } on CameraException catch (e, stack) {
      _showCameraException(e, stack);
      return null;
    }
  }

  Future<void> pauseVideoStreaming() async {
    if (!_controller.value.isStreamingVideoRtmp) {
      return null;
    }

    try {
      await _controller.pauseVideoStreaming();
    } on CameraException catch (e, stack) {
      _showCameraException(e, stack);
      rethrow;
    }
  }

  Future<void> resumeVideoStreaming() async {
    if (!_controller.value.isStreamingVideoRtmp) {
      return null;
    }

    try {
      await _controller.resumeVideoStreaming();
    } on CameraException catch (e, stack) {
      _showCameraException(e, stack);
      rethrow;
    }
  }

  void _showCameraException(CameraException e, StackTrace stack) {
    Crashlytics.instance.recordError(e, stack);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}