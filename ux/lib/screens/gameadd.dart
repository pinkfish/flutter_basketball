import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/seasons/seasondropdown.dart';
import 'package:basketballstats/widgets/seasons/seasonname.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import '../widgets/deleted.dart';
import '../widgets/loading.dart';
import '../widgets/savingoverlay.dart';
import '../widgets/util/datetimepicker.dart';

///
/// Class to add a game to a specific season.
///
class GameAddScreen extends StatelessWidget {
  final String teamUid;

  GameAddScreen({@required this.teamUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addGameTooltip),
      ),
      body: BlocProvider(
        create: (BuildContext context) => SingleTeamBloc(
            db: BlocProvider.of<TeamsBloc>(context).db,
            teamUid: teamUid,
            crashes: RepositoryProvider.of<CrashReporting>(context)),
        child: Builder(
          builder: (BuildContext context) => BlocBuilder(
            cubit: BlocProvider.of<SingleTeamBloc>(context),
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
                    db: BlocProvider.of<TeamsBloc>(context).db,
                    crashes: RepositoryProvider.of<CrashReporting>(context)),
                child: Builder(builder: (BuildContext context) {
                  return _GameAddForm(
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

class _GameAddForm extends StatefulWidget {
  final String teamUid;
  final String currentSeasonUid;

  _GameAddForm({@required this.teamUid, @required this.currentSeasonUid});

  @override
  State<StatefulWidget> createState() {
    return _GameAddFormState();
  }
}

class _GameAddFormState extends State<_GameAddForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _guestPlayersFormKey = GlobalKey<FormState>();
  String _opponent;
  String _location;
  String _seasonUid;
  bool _saving = false;
  DateTime _dateTime = DateTime.now();
  DateTime _eventTime;
  TimeOfDay _time = TimeOfDay.now();
  int _stepIndex = 0;
  List<PlayerBuilder> _guestPlayers = [];

  @override
  void initState() {
    super.initState();
    _seasonUid = widget.currentSeasonUid;
    _eventTime = DateTime.now();
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

      // Go throught he players list and make a builtlist of the ones with
      // names
      var players = BuiltList.of(
          _guestPlayers.where((e) => e.name != "").map((e) => e.build()));

      bloc.add(AddGameEventCommit(
        newGame: Game((b) => b
          ..opponentName = _opponent
          ..seasonUid = season.uid
          ..teamUid = season.teamUid
          ..location = _location ?? ""
          ..summary = (GameSummaryBuilder()
            ..pointsAgainst = 0
            ..pointsFor = 0)
          ..eventTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
                  _time.hour, _time.minute)
              .toUtc()),
        guestPlayers: players,
      ));
    } finally {
      setState(() => _saving = false);
    }
  }

  void _onStepCancel() {
    Navigator.pop(context);
  }

  void _onStepTapped(int index, AddGameBloc bloc) {
    if (index < _stepIndex) {
      setState(() => _stepIndex = index);
    }
    if (index == _stepIndex + 1) {
      _onStepContinue(bloc);
    }
  }

  void _onStepContinue(AddGameBloc bloc) {
    if (_stepIndex == 1) {
      // Verify the form first.
      if (!_formKey.currentState.validate()) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(Messages.of(context).errorForm)));
        return;
      }
      _formKey.currentState.save();
      _eventTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
          _time.hour, _time.minute);
    }
    if (_stepIndex == 2) {
      _guestPlayersFormKey.currentState.save();
      // Filter all the empty guest players out
      _guestPlayers = _guestPlayers.where((p) => p.name.isNotEmpty).toList();
    }
    if (_stepIndex == 3) {
      // Save!
      _saveForm(bloc);
    } else {
      setState(() => _stepIndex++);
    }
  }

  void _onAddGuestPlayerButtonTapped() async {
    setState(() => _guestPlayers.add(PlayerBuilder()
      ..name = ""
      ..uid = ""));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: BlocProvider.of<AddGameBloc>(context),
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
        cubit: BlocProvider.of<AddGameBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
            saving: state is AddItemSaving || _saving,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Stepper(
                controlsBuilder: _stepperButtons,
                onStepContinue: () =>
                    _onStepContinue(BlocProvider.of<AddGameBloc>(context)),
                onStepCancel: _onStepCancel,
                onStepTapped: (i) =>
                    _onStepTapped(i, BlocProvider.of<AddGameBloc>(context)),
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
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          Messages.of(context).guestPlayersForGame,
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        ButtonBar(
                          children: <Widget>[
                            FlatButton.icon(
                              label: Text(
                                  Messages.of(context).addGuestPlayerButton),
                              icon: Icon(Icons.add),
                              onPressed: _onAddGuestPlayerButtonTapped,
                            )
                          ],
                        ),
                        Form(
                          key: _guestPlayersFormKey,
                          child: Column(
                            children: _guestPlayers
                                .map(
                                  (p) => Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            icon: Icon(Icons.text_fields),
                                            hintText:
                                                Messages.of(context).playerName,
                                            labelText:
                                                Messages.of(context).playerName,
                                          ),
                                          onSaved: (String str) {
                                            p.name = str;
                                          },
                                          autovalidate: false,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => setState(
                                          () {
                                            _guestPlayers.remove(p);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: Text(Messages.of(context).addGameSummary),
                    content: BlocProvider(
                      create: (BuildContext context) => SingleSeasonBloc(
                          db: RepositoryProvider.of<BasketballDatabase>(
                              context),
                          seasonUid: _seasonUid,
                          crashes:
                              RepositoryProvider.of<CrashReporting>(context)),
                      child: Builder(
                        builder: (BuildContext context) => BlocBuilder(
                          cubit: BlocProvider.of<SingleSeasonBloc>(context),
                          builder: (BuildContext context,
                              SingleSeasonBlocState seasonState) {
                            if (seasonState is SingleSeasonUninitialized) {
                              return LoadingWidget();
                            }
                            if (seasonState is SingleSeasonDeleted) {
                              return DeletedWidget();
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SeasonName(
                                  seasonUid: _seasonUid,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                ListTile(
                                  leading: Icon(MdiIcons.basketball),
                                  title: Text(
                                    Messages.of(context)
                                        .getGameVs(_opponent, _location),
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                    textScaleFactor: 1.2,
                                  ),
                                  subtitle: Text(
                                    DateFormat("dd MMM hh:mm")
                                        .format(_eventTime.toLocal()),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(
                                          color: Theme.of(context).accentColor,
                                        ),
                                    textScaleFactor: 1.2,
                                  ),
                                ),
                                _guestPlayers.length > 0
                                    ? Column(
                                        children: _guestPlayers
                                            .map((p) => Text(p.name))
                                            .toList(),
                                      )
                                    : Text(
                                        Messages.of(context).noGuestPlayers,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
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

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _stepperButtons(BuildContext context,
      {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: Row(
          children: <Widget>[
            FlatButton(
              onPressed: onStepContinue,
              color: _isDark()
                  ? themeData.backgroundColor
                  : themeData.primaryColor,
              textColor: Colors.white,
              textTheme: ButtonTextTheme.normal,
              child: _stepIndex == 3
                  ? Text(Messages.of(context).saveButton)
                  : Text(localizations.continueButtonLabel),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 8.0),
              child: FlatButton(
                onPressed: onStepCancel,
                textColor: cancelColor,
                textTheme: ButtonTextTheme.normal,
                child: Text(localizations.cancelButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
