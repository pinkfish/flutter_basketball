import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/season.dart';
import '../data/team.dart';

abstract class SingleTeamBlocState extends Equatable {
  final Team team;
  final BuiltList<Season> seasons;
  final bool loadedSeasons;

  SingleTeamBlocState(
      {@required this.team,
      @required this.seasons,
      @required this.loadedSeasons});

  @override
  List<Object> get props => [team, seasons, loadedSeasons];
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamBlocState {
  SingleTeamLoaded(
      {@required SingleTeamBlocState state,
      Team team,
      BuiltList<Season> seasons,
      bool loadedSeasons})
      : super(
            team: team ?? state.team,
            seasons: seasons ?? state.seasons,
            loadedSeasons: loadedSeasons ?? state.loadedSeasons);

  @override
  String toString() {
    return 'SingleTeamLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSaving extends SingleTeamBlocState {
  SingleTeamSaving({@required SingleTeamBlocState singleTeamState})
      : super(
            team: singleTeamState.team,
            seasons: singleTeamState.seasons,
            loadedSeasons: singleTeamState.loadedSeasons);

  @override
  String toString() {
    return 'SingleTeamSaving{}';
  }
}

///
/// Saving operation is successful.
///
class SingleTeamSaveSuccessful extends SingleTeamBlocState {
  SingleTeamSaveSuccessful({@required SingleTeamBlocState singleTeamState})
      : super(
            team: singleTeamState.team,
            seasons: singleTeamState.seasons,
            loadedSeasons: singleTeamState.loadedSeasons);

  @override
  String toString() {
    return 'SingleTeamSaveSuccessful{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSaveFailed extends SingleTeamBlocState {
  final Error error;

  SingleTeamSaveFailed(
      {@required SingleTeamBlocState singleTeamState, this.error})
      : super(
            team: singleTeamState.team,
            seasons: singleTeamState.seasons,
            loadedSeasons: singleTeamState.loadedSeasons);

  @override
  String toString() {
    return 'SingleTeamSaveFailed{}';
  }
}

///
/// Team got deleted.
///
class SingleTeamDeleted extends SingleTeamBlocState {
  SingleTeamDeleted()
      : super(team: null, seasons: BuiltList.of([]), loadedSeasons: false);

  @override
  String toString() {
    return 'SingleTeamDeleted{}';
  }
}

///
/// Team is still loading.
///
class SingleTeamUninitialized extends SingleTeamBlocState {
  SingleTeamUninitialized()
      : super(team: null, seasons: BuiltList.of([]), loadedSeasons: false);

  @override
  String toString() {
    return 'SingleTeamUninitialized{}';
  }
}

abstract class SingleTeamEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamUpdate extends SingleTeamEvent {
  final Team team;

  SingleTeamUpdate({@required this.team});

  @override
  List<Object> get props => [team];
}

///
/// Delete this team from the world.
///
class SingleTeamDelete extends SingleTeamEvent {
  SingleTeamDelete();

  @override
  List<Object> get props => [];
}

///
/// Adds a player to this specific season for this team.
///
class SingleTeamAddSeasonPlayer extends SingleTeamEvent {
  final String seasonUid;
  final String playerUid;

  SingleTeamAddSeasonPlayer(
      {@required this.seasonUid, @required this.playerUid});

  @override
  List<Object> get props => [seasonUid, playerUid];
}

///
/// Loads the games associated with this team.
///
class SingleTeamLoadSeasons extends SingleTeamEvent {
  @override
  List<Object> get props => null;
}

class _SingleTeamNewTeam extends SingleTeamEvent {
  final Team newTeam;

  _SingleTeamNewTeam({@required this.newTeam});

  @override
  List<Object> get props => [newTeam];
}

class _SingleTeamUpdateSeasons extends SingleTeamEvent {
  final BuiltList<Season> seasons;

  _SingleTeamUpdateSeasons({@required this.seasons});

  @override
  List<Object> get props => [seasons];
}

class _SingleTeamDeleted extends SingleTeamEvent {
  _SingleTeamDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamBloc extends Bloc<SingleTeamEvent, SingleTeamBlocState> {
  final BasketballDatabase db;
  final String teamUid;
  final Lock _lock = new Lock();

  StreamSubscription<Team> _teamSub;
  StreamSubscription<BuiltList<Season>> _seasonSub;

  SingleTeamBloc({@required this.db, @required this.teamUid})
      : super(SingleTeamUninitialized()) {
    _teamSub = db.getTeam(teamUid: teamUid).listen((Team t) {
      if (t != null) {
        // Only send this if the team is not the same.
        if (t != state.team || !(state is SingleTeamLoaded)) {
          add(_SingleTeamNewTeam(newTeam: t));
        }
      } else {
        add(_SingleTeamDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    _teamSub?.cancel();
    _seasonSub?.cancel();
    await super.close();
  }

  @override
  Stream<SingleTeamBlocState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      yield SingleTeamLoaded(state: state, team: event.newTeam);
    }

    // The team is deleted.
    if (event is _SingleTeamDeleted) {
      yield SingleTeamDeleted();
    }

    // Save the team.
    if (event is SingleTeamUpdate) {
      yield SingleTeamSaving(singleTeamState: state);
      try {
        Team team = event.team;
        if (team != state.team) {
          await db.updateTeam(team: team);
          // This will get overridden by the loaded event right afterwards.
          yield SingleTeamSaveSuccessful(singleTeamState: state);
        } else {
          yield SingleTeamSaveSuccessful(singleTeamState: state);
          yield SingleTeamLoaded(state: state, team: event.team);
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleTeamSaveFailed(singleTeamState: state, error: error);
      }
    }

    if (event is SingleTeamAddSeasonPlayer) {
      yield SingleTeamSaving(singleTeamState: state);
      try {
        await db.addSeasonPlayer(
            seasonUid: event.seasonUid, playerUid: event.playerUid);
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleTeamSaveFailed(singleTeamState: state, error: error);
      }
    }

    if (event is SingleTeamDelete) {
      try {
        await db.deleteTeam(teamUid: teamUid);
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleTeamSaveFailed(singleTeamState: state, error: error);
      }
    }

    if (event is _SingleTeamUpdateSeasons) {
      yield SingleTeamLoaded(
          state: state, seasons: event.seasons, loadedSeasons: true);
    }

    if (event is SingleTeamLoadSeasons) {
      _lock.synchronized(() {
        _seasonSub = db
            .getTeamSeasons(teamUid: this.teamUid)
            .listen((BuiltList<Season> seasons) {
          add(_SingleTeamUpdateSeasons(seasons: seasons));
        });
      });
    }
  }
}
