import 'package:basketballdata/basketballdata.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';
import '../widgets/datetimepicker.dart';
import '../widgets/savingoverlay.dart';

class AddGameScreen extends StatelessWidget {
  final String teamUid;

  AddGameScreen({@required this.teamUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleTeamBloc(
            teamBloc: BlocProvider.of<TeamsBloc>(context), teamUid: teamUid),
        child: BlocProvider(
          create: (BuildContext context) => AddGameBloc(
              teamUid: teamUid, db: BlocProvider.of<TeamsBloc>(context).db),
          child: Builder(builder: (BuildContext context) {
            return BlocBuilder(
                bloc: BlocProvider.of<SingleTeamBloc>(context),
                builder: (BuildContext context, SingleTeamBlocState state) {
                  if (state is SingleTeamDeleted) {
                    return Center(child: Text(Messages.of(context).unknown));
                  }
                  return _AddGameForm(
                    team: state.team,
                  );
                });
          }),
        ),
      ),
    );
  }
}

class _AddGameForm extends StatefulWidget {
  final Team team;

  _AddGameForm({@required this.team});

  @override
  State<StatefulWidget> createState() {
    return _AddGameFormState();
  }
}

class _AddGameFormState extends State<_AddGameForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name;
  String _location;
  DateTime _dateTime = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  void _saveForm(AddGameBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));
      return;
    }
    _formKey.currentState.save();
    var map = MapBuilder<String, PlayerSummary>();
    map.addEntries(widget.team.playerUids.keys.map((var e) => MapEntry(
        e,
        PlayerSummary((b) => b
          ..oneAttempts = 0
          ..oneMade = 0
          ..twoAttempts = 0
          ..twoMade = 0
          ..threeAttempts = 0
          ..threeMade = 0
          ..steals = 0
          ..defensiveRebounds = 0
          ..offensiveRebounds = 0
          ..fouls = 0))));
    bloc.add(AddGameEventCommit(
        newGame: Game((b) => b
          ..name = _name
          ..teamUid = widget.team.uid
          ..playerUids = map
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
                      hintText: Messages.of(context).gameName,
                      labelText: Messages.of(context).gameName,
                    ),
                    onSaved: (String str) {
                      _name = str;
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
