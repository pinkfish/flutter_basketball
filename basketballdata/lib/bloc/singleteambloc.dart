import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/game.dart';
import '../data/team.dart';

abstract class SingleTeamBlocState extends Equatable {
  final Team team;
  final BuiltList<Game> games;
  final bool loadedGames;

  SingleTeamBlocState(
      {@required this.team, @required this.games, @required this.loadedGames});

  @override
  List<Object> get props => [team, games, loadedGames];
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamBlocState {
  SingleTeamLoaded(
      {@required SingleTeamBlocState state,
      Team team,
      BuiltList<Game> games,
      bool loadedGames})
      : super(
            team: team ?? state.team,
            games: games ?? state.games,
            loadedGames: loadedGames ?? state.loadedGames);

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
            games: singleTeamState.games,
            loadedGames: singleTeamState.loadedGames);

  @override
  String toString() {
    return 'SingleTeamSaving{}';
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
            games: singleTeamState.games,
            loadedGames: singleTeamState.loadedGames);

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
      : super(team: null, games: BuiltList.of([]), loadedGames: false);

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
      : super(team: null, games: BuiltList.of([]), loadedGames: false);

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
/// Adds an player to the team.
///
class SingleTeamAddPlayer extends SingleTeamEvent {
  final String playerUid;

  SingleTeamAddPlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
}

///
/// Deletes an player from the team.
///
class SingleTeamRemovePlayer extends SingleTeamEvent {
  final String playerUid;

  SingleTeamRemovePlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
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
/// Loads the games associated with this team.
///
class SingleTeamLoadGames extends SingleTeamEvent {
  @override
  List<Object> get props => null;
}

class _SingleTeamNewTeam extends SingleTeamEvent {
  final Team newTeam;

  _SingleTeamNewTeam({@required this.newTeam});

  @override
  List<Object> get props => [newTeam];
}

class _SingleTeamUpdateGames extends SingleTeamEvent {
  final BuiltList<Game> games;

  _SingleTeamUpdateGames({@required this.games});

  @override
  List<Object> get props => [games];
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
  StreamSubscription<BuiltList<Game>> _gameSub;

  SingleTeamBloc({@required this.db, @required this.teamUid}) {
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
    _gameSub?.cancel();
    await super.close();
  }

  @override
  SingleTeamBlocState get initialState {
    return SingleTeamUninitialized();
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
        } else {
          yield SingleTeamLoaded(state: state, team: event.team);
        }
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is SingleTeamAddPlayer) {
      yield SingleTeamSaving(singleTeamState: state);
      try {
        if (!state.team.playerUids.containsKey(event.playerUid)) {
          await db.addTeamPlayer(teamUid: teamUid, playerUid: event.playerUid);
        } else {
          yield SingleTeamLoaded(state: state);
        }
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is SingleTeamRemovePlayer) {
      yield SingleTeamSaving(singleTeamState: state);
      try {
        if (state.team.playerUids.containsKey(event.playerUid)) {
          await db.deleteTeamPlayer(
              teamUid: teamUid, playerUid: event.playerUid);
        } else {
          yield SingleTeamLoaded(state: state);
        }
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is SingleTeamDelete) {
      try {
        await db.deleteTeam(teamUid: teamUid);
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is _SingleTeamUpdateGames) {
      yield SingleTeamLoaded(
          state: state, games: event.games, loadedGames: true);
    }

    if (event is SingleTeamLoadGames) {
      _lock.synchronized(() {
        _gameSub = db
            .getTeamGames(teamUid: this.teamUid)
            .listen((BuiltList<Game> games) {
          add(_SingleTeamUpdateGames(games: games));
        });
      });
    }
  }
}
