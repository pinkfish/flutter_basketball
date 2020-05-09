import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/game/mediaedit.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';

///
/// Adds a media to the game worl.
///
class AddMediaGameScreen extends StatelessWidget {
  final String gameUid;

  AddMediaGameScreen(this.gameUid);

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
  void _saveForm(
      AddMediaBloc bloc, Uri url, String description, DateTime time) async {
    // Download the url and them upload to storage, then do the update.
    bloc.add(AddMediaEventCommit(
        newMedia: MediaInfo(
      (b) => b
        ..url = url
        ..description = description ?? ""
        ..startAt = time ?? widget.state.game.eventTime
        ..teamUid = widget.state.game.teamUid
        ..seasonUid = widget.state.game.seasonUid
        ..gameUid = widget.state.game.uid
        ..type = MediaType.VideoOnDemand
        ..length = Duration(seconds: 0),
    )));
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
          return SavingOverlay(
            saving: state is AddItemSaving,
            child: MediaEdit(
              onSave: (Uri url, String description, DateTime start) =>
                  _saveForm(BlocProvider.of<AddMediaBloc>(context), url,
                      description, start),
            ),
          );
        },
      ),
    );
  }
}
