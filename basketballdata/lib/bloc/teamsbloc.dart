import 'dart:async';

import 'package:basketballdata/bloc/crashreporting.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../data/team/team.dart';

///
/// The base state for the teams bloc.  It tracks all the
/// exciting teams stuff.
///
abstract class TeamsBlocState extends Equatable {
  final BuiltList<Team> teams;

  TeamsBlocState({@required this.teams});

  @override
  List<Object> get props => [teams];
}

///
/// The teams loaded from the database.
///
class TeamsBlocLoaded extends TeamsBlocState {
  TeamsBlocLoaded(
      {@required TeamsBlocState state, @required BuiltList<Team> teams})
      : super(teams: teams);
}

///
/// The teams bloc that is unitialized.
///
class TeamsBlocUninitialized extends TeamsBlocState {}

///
/// Updates all the teams in the teams bloc.
///
class TeamsBlocUpdateTeams extends TeamsBlocEvent {
  final BuiltList<Team> teams;

  TeamsBlocUpdateTeams({this.teams});

  @override
  List<Object> get props => [this.teams];
}

///
/// The base class for all the events in the teams bloc.
///
abstract class TeamsBlocEvent extends Equatable {}

///
/// The bloc for dealing with all the teams.
///
class TeamsBloc extends Bloc<TeamsBlocEvent, TeamsBlocState> {
  final BasketballDatabase db;
  final CrashReporting crashes;

  StreamSubscription<BuiltList<Team>> _sub;
  StreamSubscription<bool> _dbChange;

  TeamsBloc({@required this.db, @required this.crashes})
      : super(TeamsBlocUninitialized()) {
    print("Created teamsbloc");
    _sub = db.getAllTeams().listen(
        (BuiltList<Team> team) => add(TeamsBlocUpdateTeams(teams: team)));
    _sub.onError((e, stack) => crashes.recordError(e, stack));
    _dbChange = db.onDatabaseChange.listen((bool b) {
      _sub?.cancel();
      _sub = db.getAllTeams().listen(
          (BuiltList<Team> team) => add(TeamsBlocUpdateTeams(teams: team)));
      _sub.onError((e, stack) => crashes.recordError(e, stack));
    });
  }

  @override
  Stream<TeamsBlocState> mapEventToState(TeamsBlocEvent event) async* {
    if (event is TeamsBlocUpdateTeams) {
      yield TeamsBlocLoaded(state: state, teams: event.teams);
    }
  }

  @override
  Future<Function> close() {
    _sub?.cancel();
    _sub = null;
    _dbChange?.cancel();
    _dbChange = null;
    return super.close();
  }
}
