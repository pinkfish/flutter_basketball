import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
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
  final String teamUid;

  AddGameScreen({@required this.teamUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addGameTooltip),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleTeamBloc(
            db: BlocProvider.of<TeamsBloc>(context).db, teamUid: teamUid),
        child: Builder(
          builder: (BuildContext context) => BlocBuilder(
            bloc: BlocProvider.of<SingleTeamBloc>(context),
            builder: (BuildContext context, SingleTeamBlocState state) {
              if (state is SingleTeamDeleted) {
                return Center(child: DeletedWidget());
              }
              if (state is SingleTeamUninitialized) {
                return Center(child: LoadingWidget());
              }
              if (!state.loadedSeasons) {
                BlocProvider.of<SingleTeamBloc>(context)
                    .add(SingleTeamLoadSeasons());
              }
              return BlocProvider(
                create: (BuildContext context) => AddGameBloc(
                    teamUid: teamUid,
                    db: BlocProvider.of<TeamsBloc>(context).db),
                child: Builder(builder: (BuildContext context) {
                  return _AddGameForm(
                    teamUid: teamUid,
                    currentSeasonUid: state.team.currentSeasonUid,
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AddGameForm extends StatefulWidget {
  final String teamUid;
  final String currentSeasonUid;

  _AddGameForm({@required this.teamUid, @required this.currentSeasonUid});

  @override
  State<StatefulWidget> createState() {
    return _AddGameFormState();
  }
}

class _AddGameFormState extends State<_AddGameForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _opponent;
  String _location;
  String _seasonUid;
  bool _saving = false;
  DateTime _dateTime = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _seasonUid = widget.currentSeasonUid;
  }

  void _saveForm(AddGameBloc bloc) async {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));
      return;
    }
    _formKey.currentState.save();
    setState(() => _saving = true);
    try {
      // Load the season.
      var db = RepositoryProvider.of<BasketballDatabase>(context);
      var s = db.getSeason(seasonUid: _seasonUid);
      var season = await s.first;

      if (season.playerUids.isEmpty) {
        var res = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(Messages.of(context).noPlayers),
            content: Text(
              Messages.of(context).noPlayersForSeasonDialog,
              softWrap: true,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
        if (!res) {
          _saving = false;
          return;
        }
      }

      var map = MapBuilder<String, PlayerGameSummary>();
      map.addEntries(season.playerUids.keys
          .map((var e) => MapEntry(e, PlayerGameSummary())));
      bloc.add(AddGameEventCommit(
          newGame: Game((b) => b
            ..opponentName = _opponent
            ..seasonUid = season.uid
            ..teamUid = season.teamUid
            ..players = map
            ..location = _location ?? ""
            ..summary = (GameSummaryBuilder()
              ..pointsAgainst = 0
              ..pointsFor = 0)
            ..eventTime = DateTime(_dateTime.year, _dateTime.month,
                    _dateTime.day, _time.hour, _time.minute)
                .toUtc())));
    } finally {
      setState(() => _saving = false);
    }
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
            saving: state is AddItemSaving || _saving,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: Messages.of(context).seasonName,
                                isDense: true,
                                border: InputBorder.none,
                                labelStyle: TextStyle(height: 2.0),
                              ),
                              child: BlocBuilder(
                                bloc: BlocProvider.of<SingleTeamBloc>(context),
                                builder: (BuildContext context,
                                        SingleTeamBlocState teamState) =>
                                    teamState.loadedSeasons
                                        ? DropdownButton<String>(
                                            value: _seasonUid,
                                            isExpanded: true,
                                            items: [
                                              ...teamState.seasons.map(
                                                (Season s) => DropdownMenuItem(
                                                  child: Text(s.name),
                                                  value: s.uid,
                                                ),
                                              ),
                                            ],
                                            onChanged: (String str) => setState(
                                                () => _seasonUid = str),
                                          )
                                        : Text(Messages.of(context).loadingText),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                              onPressed: () => _saveForm(
                                  BlocProvider.of<AddGameBloc>(context)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
