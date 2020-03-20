import 'package:basketballdata/basketballdata.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';
import '../widgets/util/datetimepicker.dart';

///
/// Class to add a game to a specific season.
///
class AddGameScreen extends StatelessWidget {
  final String seasonUid;

  AddGameScreen({@required this.seasonUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleSeasonBloc(
            db: BlocProvider.of<TeamsBloc>(context).db, seasonUid: seasonUid),
        child: BlocBuilder(
          bloc: BlocProvider.of<SingleSeasonBloc>(context),
          builder: (BuildContext context, SingleSeasonBlocState state) {
            if (state is SingleSeasonDeleted) {
              return Center(child: DeletedWidget());
            }
            if (state is SingleSeasonUninitialized) {
              return Center(child: LoadingWidget());
            }
            return BlocProvider(
              create: (BuildContext context) => AddGameBloc(
                  teamUid: state.season.teamUid,
                  seasonUid: seasonUid,
                  db: BlocProvider.of<TeamsBloc>(context).db),
              child: Builder(builder: (BuildContext context) {
                return _AddGameForm(
                  season: state.season,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _AddGameForm extends StatefulWidget {
  final Season season;

  _AddGameForm({@required this.season});

  @override
  State<StatefulWidget> createState() {
    return _AddGameFormState();
  }
}

class _AddGameFormState extends State<_AddGameForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _opponent;
  String _location;
  DateTime _dateTime = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  void _saveForm(AddGameBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages
              .of(context)
              .errorForm)));
      return;
    }
    _formKey.currentState.save();
    var map = MapBuilder<String, PlayerGameSummary>();
    map.addEntries(widget.season.playerUids.keys
        .map((var e) => MapEntry(e, PlayerGameSummary())));
    bloc.add(AddGameEventCommit(
        newGame: Game((b) =>
        b
          ..opponentName = _opponent
          ..seasonUid = widget.season.uid
          ..teamUid = widget.season.teamUid
          ..players = map
          ..location = _location ?? ""
          ..summary = (GameSummaryBuilder()
            ..pointsAgainst = 0
            ..pointsFor = 0)
          ..eventTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
              _time.hour, _time.minute)
              .toUtc())));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<AddGameBloc>(context),
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          Navigator.pop(context);
        }
        if (state is AddItemSaveFailed) {
          print(state.error);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<AddGameBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
            saving: state is AddItemSaving,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.people),
                      hintText: Messages.of(context).opponent,
                      labelText: Messages.of(context).opponent,
                    ),
                    onSaved: (String str) {
                      _opponent = str;
                    },
                    autovalidate: false,
                    validator: (String str) {
                      if (str == null || str == '') {
                        return Messages.of(context).emptyText;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.directions),
                      hintText: Messages.of(context).location,
                      labelText: Messages.of(context).location,
                    ),
                    onSaved: (String str) {
                      _location = str;
                    },
                    autovalidate: false,
                  ),
                  DateTimePicker(
                    labelText: Messages.of(context).eventTime,
                    selectedDate: _dateTime,
                    selectedTime: _time,
                    selectDate: (DateTime dt) => _dateTime = dt,
                    selectTime: (TimeOfDay t) => _time = t,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ButtonBar(
                      children: [
                        FlatButton(
                          child: Text(
                              MaterialLocalizations.of(context)
                                  .cancelButtonLabel,
                              style: Theme.of(context).textTheme.button),
                          onPressed: () => Navigator.pop(context),
                        ),
                        RaisedButton.icon(
                          textTheme: ButtonTextTheme.primary,
                          elevation: 2,
                          icon: Icon(Icons.save),
                          label: Text(Messages.of(context).saveButton,
                              style: Theme.of(context).textTheme.button),
                          onPressed: () =>
                              _saveForm(BlocProvider.of<AddGameBloc>(context)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
