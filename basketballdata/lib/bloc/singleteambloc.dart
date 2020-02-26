import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../data/game.dart';
import '../data/player.dart';
import '../data/team.dart';
import 'teamsbloc.dart';

abstract class SingleTeamBlocState extends Equatable {
  final Team team;
  final BuiltList<Game> games;

  SingleTeamBlocState({@required this.team, @required this.games});

  @override
  List<Object> get props => [team, games];
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamBlocState {
  SingleTeamLoaded({@required SingleTeamBlocState state, @required Team team})
      : super(team: team, games: state.games);

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
      : super(team: singleTeamState.team, games: singleTeamState.games);

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
      : super(team: singleTeamState.team, games: singleTeamState.games);

  @override
  String toString() {
    return 'SingleTeamSaveFailed{}';
  }
}

///
/// Team got deleted.
///
class SingleTeamDeleted extends SingleTeamBlocState {
  SingleTeamDeleted() : super(team: null, games: BuiltList.of([]));

  @override
  String toString() {
    return 'SingleTeamDeleted{}';
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
  final Player player;

  SingleTeamAddPlayer({@required this.player});

  @override
  List<Object> get props => [player];
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

class _SingleTeamDeleted extends SingleTeamEvent {
  _SingleTeamDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamBloc extends Bloc<SingleTeamEvent, SingleTeamBlocState> {
  final TeamsBloc teamBloc;
  final String teamUid;

  StreamSubscription<TeamsBlocState> _teamSub;

  SingleTeamBloc({@required this.teamBloc, @required this.teamUid}) {
    _teamSub = teamBloc.listen((TeamsBlocState teamState) {
      Team team = teamState.teams
          .firstWhere((g) => g.uid == teamUid, orElse: () => null);
      if (team != null) {
        // Only send this if the team is not the same.
        if (team != state.team) {
          add(_SingleTeamNewTeam(newTeam: team));
        }
      } else {
        add(_SingleTeamDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    _teamSub?.cancel();
    await super.close();
  }

  @override
  SingleTeamBlocState get initialState {
    if (teamBloc.state.teams.any((g) => g.uid == teamUid)) {
      return SingleTeamLoaded(
          state: null,
          team: teamBloc.state.teams.firstWhere((g) => g.uid == teamUid));
    }
    return SingleTeamDeleted();
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
        await teamBloc.db.updateTeam(team: team);
        yield SingleTeamLoaded(state: state, team: event.team);
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is SingleTeamAddPlayer) {
      yield SingleTeamSaving(singleTeamState: state);
      try {
        await teamBloc.db.addTeamPlayer(teamUid: teamUid, player: event.player);
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is SingleTeamRemovePlayer) {
      yield SingleTeamSaving(singleTeamState: state);
      try {
        await teamBloc.db
            .deleteTeamPlayer(teamUid: teamUid, playerUid: event.playerUid);
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }

    if (event is SingleTeamDelete) {
      try {
        await teamBloc.db.deleteTeam(teamUid: teamUid);
      } catch (e) {
        yield SingleTeamSaveFailed(singleTeamState: state, error: e);
      }
    }
  }
}
