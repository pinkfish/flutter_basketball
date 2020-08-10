import 'dart:async';

import 'package:basketballdata/bloc/crashreporting.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../data/team/team.dart';
import 'data/teamsblocstate.dart';

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
/// Resets up the connections because the user might have changed.
///
class TeamsReloadData extends TeamsBlocEvent {
  @override
  List<Object> get props => [];
}

class _TeamsLoadedData extends TeamsBlocEvent {
  final BuiltList<Team> teams;

  _TeamsLoadedData(this.teams);

  @override
  List<Object> get props => [];
}

///
/// The bloc for dealing with all the teams.
///
class TeamsBloc extends HydratedBloc<TeamsBlocEvent, TeamsBlocState> {
  final BasketballDatabase db;
  final CrashReporting crashes;

  StreamSubscription<BuiltList<Team>> _sub;
  StreamSubscription<bool> _dbChange;

  TeamsBloc({@required this.db, @required this.crashes})
      : super(TeamsBlocUninitialized()) {
    print("Created teamsbloc");
    _setupSub();
  }

  void _setupSub() {
    _sub?.cancel();
    _sub = null;
    _sub = db
        .getAllTeams()
        .listen((BuiltList<Team> team) => add(_TeamsLoadedData(team)));
    _sub.onError((e, stack) => crashes.recordError(e, stack));
    _dbChange = db.onDatabaseChange.listen((bool b) {
      _sub?.cancel();
      _sub = db
          .getAllTeams()
          .listen((BuiltList<Team> team) => add(_TeamsLoadedData(team)));
      _sub.onError((e, stack) => crashes.recordError(e, stack));
    });
  }

  @override
  Stream<TeamsBlocState> mapEventToState(TeamsBlocEvent event) async* {
    if (event is TeamsReloadData) {
      _setupSub();
    }

    if (event is _TeamsLoadedData) {
      yield (TeamsBlocLoaded.fromState(state)..teams = event.teams.toBuilder())
          .build();
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

  @override
  TeamsBlocState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return TeamsBlocUninitialized();
    }
    TeamsBlocStateType type = TeamsBlocStateType.valueOf(json["type"]);
    switch (type) {
      case TeamsBlocStateType.Uninitialized:
        return TeamsBlocUninitialized();
      case TeamsBlocStateType.Loaded:
        return TeamsBlocLoaded.fromMap(json);
      default:
        return TeamsBlocUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(TeamsBlocState state) {
    return state.toMap();
  }
}
