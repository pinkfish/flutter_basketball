import 'dart:async';

import 'package:basketballdata/bloc/crashreporting.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/season/season.dart';
import '../data/team/team.dart';
import 'data/singleteamstate.dart';

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
class SingleTeamBloc extends HydratedBloc<SingleTeamEvent, SingleTeamState> {
  final BasketballDatabase db;
  final String teamUid;
  final Lock _lock = new Lock();
  final CrashReporting crashes;

  StreamSubscription<Team> _teamSub;
  StreamSubscription<BuiltList<Season>> _seasonSub;

  SingleTeamBloc(
      {@required this.db, @required this.teamUid, @required this.crashes})
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
  String get id => teamUid;

  @override
  Future<void> close() async {
    _teamSub?.cancel();
    _seasonSub?.cancel();
    await super.close();
  }

  @override
  Stream<SingleTeamState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      yield (SingleTeamLoaded.fromState(state)
            ..team = event.newTeam.toBuilder())
          .build();
    }

    // The team is deleted.
    if (event is _SingleTeamDeleted) {
      yield SingleTeamDeleted();
    }

    // Save the team.
    if (event is SingleTeamUpdate) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        Team team = event.team;
        if (team != state.team) {
          await db.updateTeam(team: team);
          // This will get overridden by the loaded event right afterwards.
          yield SingleTeamSaveSuccessful.fromState(state).build();
          yield SingleTeamLoaded.fromState(state).build();
        } else {
          yield SingleTeamSaveSuccessful.fromState(state).build();
          yield SingleTeamLoaded.fromState(state).build();
        }
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleTeamSaveFailed.fromState(state)..error = error).build();
      }
    }

    if (event is SingleTeamAddSeasonPlayer) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        await db.addSeasonPlayer(
            seasonUid: event.seasonUid, playerUid: event.playerUid);
        yield SingleTeamSaveSuccessful.fromState(state).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleTeamSaveFailed.fromState(state)..error = error).build();
      }
    }

    if (event is SingleTeamDelete) {
      try {
        await db.deleteTeam(teamUid: teamUid);
        yield SingleTeamSaveSuccessful.fromState(state).build();
        yield SingleTeamDeleted();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleTeamSaveFailed.fromState(state)..error = error).build();
      }
    }

    if (event is _SingleTeamUpdateSeasons) {
      yield (SingleTeamLoaded.fromState(state)
            ..seasons = event.seasons.toBuilder()
            ..loadedSeasons = true)
          .build();
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

  @override
  SingleTeamState fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("type")) {
      return SingleTeamUninitialized();
    }
    SingleTeamStateType type = SingleTeamStateType.valueOf(json["type"]);
    switch (type) {
      case SingleTeamStateType.Uninitialized:
        return SingleTeamUninitialized();
      case SingleTeamStateType.Loaded:
        return SingleTeamLoaded.fromMap(json);
      case SingleTeamStateType.Deleted:
        return SingleTeamDeleted.fromMap(json);
      case SingleTeamStateType.SaveFailed:
        return SingleTeamSaveFailed.fromMap(json);
      case SingleTeamStateType.SaveSuccessful:
        return SingleTeamSaveSuccessful.fromMap(json);
      case SingleTeamStateType.Saving:
        return SingleTeamSaving.fromMap(json);
      default:
        return SingleTeamUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(SingleTeamState state) {
    return state.toMap();
  }
}
