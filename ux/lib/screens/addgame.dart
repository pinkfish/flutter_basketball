import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/game/playerlist.dart';
import 'package:basketballstats/widgets/game/playermultiselect.dart';
import 'package:basketballstats/widgets/seasons/seasondropdown.dart';
import 'package:basketballstats/widgets/seasons/seasonname.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  DateTime _eventTime;
  TimeOfDay _time = TimeOfDay.now();
  int _stepIndex = 0;
  List<String> _toIgnorePlayers = [];
  Map<String, Player> _guestPlayers = {};

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

  void _onStepCancel() {
    Navigator.pop(context);
  }

  void _onStepContinue(AddGameBloc bloc) {
    if (_stepIndex == 1) {
      // Verify the form first.
      if (!_formKey.currentState.validate()) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(Messages.of(context).errorForm)));
        return;
      }
      _eventTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
          _time.hour, _time.minute);
    }
    if (_stepIndex == 3) {
      // Save!
      _saveForm(bloc);
    } else {
      _stepIndex++;
    }
  }

  void _onAddGuestPlayerButtonTapped() {}

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
              child: Stepper(
                onStepContinue: () =>
                    _onStepContinue(BlocProvider.of<AddGameBloc>(context)),
                onStepCancel: _onStepCancel,
                currentStep: _stepIndex,
                steps: <Step>[
                  Step(
                    title: Text(Messages.of(context).seasonName),
                    content: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10.0),
                        SeasonDropDown(
                          value: _seasonUid,
                          onChanged: (String uid) =>
                              setState(() => _seasonUid = uid),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: Text(Messages.of(context).gameDetails),
                    content: SingleChildScrollView(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Step(
                    title: Text(Messages.of(context).players),
                    content: BlocProvider(
                      create: (BuildContext context) => SingleSeasonBloc(
                          db: RepositoryProvider.of<BasketballDatabase>(
                              context),
                          seasonUid: _seasonUid),
                      child: Builder(
                        builder: (BuildContext context) => BlocBuilder(
                          bloc: BlocProvider.of<SingleSeasonBloc>(context),
                          builder: (BuildContext context,
                              SingleSeasonBlocState seasonState) {
                            if (seasonState is SingleSeasonUninitialized) {
                              return LoadingWidget();
                            }
                            if (seasonState is SingleSeasonDeleted) {
                              return DeletedWidget();
                            }
                            // Show a multi-select widget, yayness.
                            return Column(
                              children: [
                                ButtonBar(
                                  children: <Widget>[
                                    FlatButton.icon(
                                      label: Text(Messages.of(context)
                                          .addGuestPlayerButton),
                                      icon: Icon(Icons.add),
                                      onPressed: _onAddGuestPlayerButtonTapped,
                                    )
                                  ],
                                ),
                                PlayerMultiselect(
                                  game: Game(),
                                  season: seasonState.season,
                                  orientation: Orientation.portrait,
                                  selectPlayer: (String uid, bool selected) {
                                    if (selected) {
                                      setState(
                                          () => _toIgnorePlayers.remove(uid));
                                    } else {
                                      setState(() => _toIgnorePlayers.add(uid));
                                    }
                                  },
                                  selectedUids: seasonState
                                      .season.playerUids.keys
                                      .where((element) =>
                                          !_toIgnorePlayers.contains(element)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Step(
                    title: Text(Messages.of(context).addGameSummary),
                    content: BlocProvider(
                      create: (BuildContext context) => SingleSeasonBloc(
                          db: RepositoryProvider.of<BasketballDatabase>(
                              context),
                          seasonUid: _seasonUid),
                      child: Builder(
                        builder: (BuildContext context) => BlocBuilder(
                          bloc: BlocProvider.of<SingleSeasonBloc>(context),
                          builder: (BuildContext context,
                              SingleSeasonBlocState seasonState) {
                            if (seasonState is SingleSeasonUninitialized) {
                              return LoadingWidget();
                            }
                            if (seasonState is SingleSeasonDeleted) {
                              return DeletedWidget();
                            }
                            return Column(
                              children: <Widget>[  
                                SeasonName(seasonUid: _seasonUid),
                                Text(Messages.of(context)
                                    .getGameVs(_opponent, _location)),
                                Text(DateFormat("dd MMM hh:mm")
                                    .format(_eventTime.toLocal())),
                                PlayerList(
                                  game: Game(),
                                  season: seasonState.season,
                                  additonalPlayers: _guestPlayers,
                                ),
                                ButtonBar(
                                  children: [
                                    FlatButton(
                                      child: Text(
                                          MaterialLocalizations.of(context)
                                              .okButtonLabel),
                                      onPressed: () => _saveForm(
                                          BlocProvider.of<AddGameBloc>(
                                              context)),
                                    ),
                                    FlatButton(
                                      child: Text(
                                          MaterialLocalizations.of(context)
                                              .cancelButtonLabel),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
