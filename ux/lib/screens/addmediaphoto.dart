import 'dart:async';
import 'dart:io';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uuid/uuid.dart';

import '../messages.dart';
import '../widgets/loading.dart';
import '../widgets/savingprogressoverlay.dart';

///
/// Adds a media to the game worl.
///
class AddMediaPhotoGameScreen extends StatelessWidget {
  final String gameUid;

  AddMediaPhotoGameScreen(this.gameUid);

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
          builder: (BuildContext context) => BlocProvider(
            create: (BuildContext context) => AddMediaBloc(
              db: RepositoryProvider.of<BasketballDatabase>(context),
            ),
            child: BlocBuilder(
              bloc: BlocProvider.of<SingleGameBloc>(context),
              builder: (BuildContext context, SingleGameState state) =>
                  _AddMediaGameInside(state),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddMediaGameInside extends StatefulWidget {
  final SingleGameState state;

  _AddMediaGameInside(this.state);

  @override
  State<StatefulWidget> createState() {
    return _AddMediaGameInsideState();
  }
}

class _AddMediaGameInsideState extends State<_AddMediaGameInside> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  File _image;
  bool _uploading = false;
  Uuid uuid = Uuid();
  String _description;
  num _percentage = 0;

  void _saveForm(AddMediaBloc bloc) async {
    // Upload the media to storage and use that url.
    setState(() => _uploading = true);
    var id = uuid.v5(
        Uuid.NAMESPACE_URL, "video.whelksoft.com/${widget.state.game.uid}");
    var ref = FirebaseStorage.instance
        .ref()
        .child("image/${widget.state.game.uid}/$id");
    var task = ref.putFile(_image);
    var timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _percentage = task.lastSnapshot.bytesTransferred /
            task.lastSnapshot.totalByteCount *
            100;
      });
    });
    await task.onComplete;
    timer.cancel();
    var url = await ref.getDownloadURL();
    var img = im.decodeImage(_image.readAsBytesSync());
    var dateTime = img.exif.data[0x0132];
    print(dateTime);
    // Download the url and them upload to storage, then do the update.
    bloc.add(AddMediaEventCommit(
        newMedia: MediaInfo(
      (b) => b
        ..uid = id
        ..url = url
        ..description = _description
        ..startAt = dateTime as DateTime ?? widget.state.game.eventTime
        ..teamUid = widget.state.game.teamUid
        ..seasonUid = widget.state.game.seasonUid
        ..gameUid = widget.state.game.uid
        ..type = MediaType.VideoOnDemand
        ..length = Duration(seconds: 0),
    )));
    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<AddMediaBloc>(context),
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          // Pass back the media uid.
          Navigator.pop(
            context,
            state.uid,
          );
        }
        if (state is AddItemSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<AddMediaBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          if (widget.state is SingleGameUninitialized) {
            return LoadingWidget();
          }
          return SavingProgressOverlay(
            saving: state is AddItemSaving || _uploading,
            percentage: _percentage,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child:
                        _image != null ? Image.file(_image) : Icon(Icons.image),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(MdiIcons.text),
                      hintText: Messages.of(context).descriptionTitle,
                      labelText: Messages.of(context).descriptionTitle,
                    ),
                    onSaved: (String str) {
                      _description = str;
                    },
                    initialValue: _description ?? "",
                    autovalidate: false,
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(Messages.of(context).saveButton),
                        onPressed: () =>
                            _saveForm(BlocProvider.of<AddMediaBloc>(context)),
                      ),
                      FlatButton.icon(
                        icon: const Icon(Icons.camera),
                        label: Text(Messages.of(context).takePhotoButton),
                        onPressed: () => _getImage(ImageSource.camera),
                      ),
                      FlatButton.icon(
                        icon: const Icon(MdiIcons.imageAlbum),
                        label: Text(Messages.of(context).selectImageButton),
                        onPressed: () => _getImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _getImage(ImageSource source) async {
    var image = await picker.getImage(source: source);

    setState(() {
      _image = File(image.path);
    });
  }
}
