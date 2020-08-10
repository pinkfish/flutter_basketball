import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/season/seasonsummary.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/game/game.dart';
import '../data/season/season.dart';
import 'crashreporting.dart';
import 'data/singleseasonstate.dart';

abstract class SingleSeasonEvent extends Equatable {}

///
/// Updates the season (writes it out to firebase.
///
class SingleSeasonUpdate extends SingleSeasonEvent {
  final Season season;

  SingleSeasonUpdate({@required this.season});

  @override
  List<Object> get props => [season];
}

///
/// Adds an player to the season.
///
class SingleSeasonAddPlayer extends SingleSeasonEvent {
  final String playerUid;

  SingleSeasonAddPlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
}

///
/// Deletes an player from the season.
///
class SingleSeasonRemovePlayer extends SingleSeasonEvent {
  final String playerUid;

  SingleSeasonRemovePlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
}

///
/// Delete this season from the world.
///
class SingleSeasonDelete extends SingleSeasonEvent {
  SingleSeasonDelete();

  @override
  List<Object> get props => [];
}

///
/// Loads the games associated with this season.
///
class SingleSeasonLoadGames extends SingleSeasonEvent {
  @override
  List<Object> get props => null;
}

///
/// Loads the players associated with this season.
///
class SingleSeasonLoadPlayers extends SingleSeasonEvent {
  @override
  List<Object> get props => null;
}

class _SingleSeasonNewSeason extends SingleSeasonEvent {
  final Season newSeason;

  _SingleSeasonNewSeason({@required this.newSeason});

  @override
  List<Object> get props => [newSeason];
}

class _SingleSeasonUpdateGames extends SingleSeasonEvent {
  final BuiltList<Game> games;

  _SingleSeasonUpdateGames({@required this.games});

  @override
  List<Object> get props => [games];
}

class _SingleSeasonUpdatePlayers extends SingleSeasonEvent {
  final BuiltMap<String, Player> players;

  _SingleSeasonUpdatePlayers({@required this.players});

  @override
  List<Object> get props => [players];
}

class _SingleSeasonDeleted extends SingleSeasonEvent {
  _SingleSeasonDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific season.
///
class SingleSeasonBloc
    extends HydratedBloc<SingleSeasonEvent, SingleSeasonState> {
  final BasketballDatabase db;
  final String seasonUid;
  final Lock _lock = new Lock();
  final CrashReporting crashes;

  StreamSubscription<Season> _seasonSub;
  StreamSubscription<BuiltList<Game>> _gameSub;
  Map<String, StreamSubscription<Player>> _players;
  Map<String, Player> _loadedPlayers;

  SingleSeasonBloc(
      {@required this.db, @required this.seasonUid, @required this.crashes})
      : super(SingleSeasonUninitialized()) {
    _players = {};
    _loadedPlayers = {};
    _seasonSub = db.getSeason(seasonUid: seasonUid).listen((Season t) {
      if (t != null) {
        // Only send this if the season is not the same.
        if (t != state.season || !(state is SingleSeasonLoaded)) {
          add(_SingleSeasonNewSeason(newSeason: t));
        }
      } else {
        add(_SingleSeasonDeleted());
      }
    });
  }

  @override
  String get id => seasonUid;

  @override
  Future<void> close() async {
    _seasonSub?.cancel();
    _gameSub?.cancel();
    for (var s in _players.values) {
      s.cancel();
    }
    _players.clear();
    _loadedPlayers.clear();
    await super.close();
  }

  @override
  Stream<SingleSeasonState> mapEventToState(SingleSeasonEvent event) async* {
    if (event is _SingleSeasonNewSeason) {
      yield (SingleSeasonLoaded.fromState(state)
            ..season = event.newSeason.toBuilder())
          .build();
    }

    // The season is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the season.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving.fromState(state).build();
      try {
        Season season = event.season;
        if (season != state.season) {
          await db.updateSeason(season: season);
          yield SingleSeasonSaveSuccessful.fromState(state).build();
          yield (SingleSeasonLoaded.fromState(state)
                ..season = event.season.toBuilder())
              .build();
        } else {
          yield SingleSeasonLoaded.fromState(state).build();
        }
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleSeasonSaveFailed.fromState(state)..error = error).build();
        yield SingleSeasonLoaded.fromState(state).build();
      }
    }

    if (event is SingleSeasonAddPlayer) {
      yield SingleSeasonSaving.fromState(state).build();
      try {
        if (!state.season.playerUids.containsKey(event.playerUid)) {
          await db.addSeasonPlayer(
              seasonUid: seasonUid, playerUid: event.playerUid);
          yield SingleSeasonSaveSuccessful.fromState(state).build();
          yield SingleSeasonLoaded.fromState(state).build();
        } else {
          yield SingleSeasonLoaded.fromState(state).build();
        }
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleSeasonSaveFailed.fromState(state)..error = error).build();
        yield SingleSeasonLoaded.fromState(state).build();
      }
    }

    if (event is SingleSeasonRemovePlayer) {
      yield SingleSeasonSaving.fromState(state).build();
      try {
        if (state.season.playerUids.containsKey(event.playerUid)) {
          await db.deleteSeasonPlayer(
              seasonUid: seasonUid, playerUid: event.playerUid);
          yield SingleSeasonSaveSuccessful.fromState(state).build();
          yield SingleSeasonLoaded.fromState(state).build();
        } else {
          yield SingleSeasonLoaded.fromState(state).build();
        }
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleSeasonSaveFailed.fromState(state)..error = error).build();
        yield SingleSeasonLoaded.fromState(state).build();
      }
    }

    if (event is SingleSeasonDelete) {
      try {
        await db.deleteSeason(seasonUid: seasonUid);
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleSeasonSaveFailed.fromState(state)..error = error).build();
        yield SingleSeasonLoaded.fromState(state).build();
      }
    }

    if (event is _SingleSeasonUpdateGames) {
      yield (SingleSeasonLoaded.fromState(state)
            ..games = event.games.toBuilder()
            ..loadedGames = true)
          .build();
    }

    if (event is _SingleSeasonUpdatePlayers) {
      yield (SingleSeasonLoaded.fromState(state)
            ..players = event.players.toBuilder()
            ..loadedPlayers = true)
          .build();
    }

    if (event is SingleSeasonLoadGames) {
      _lock.synchronized(() {
        _gameSub = db
            .getSeasonGames(seasonUid: this.seasonUid)
            .listen((BuiltList<Game> games) {
          add(_SingleSeasonUpdateGames(games: games));
          if (state.loadedPlayers) {
            // See if we need to load any of the game players too.
            for (Game g in state.games) {
              for (String playerUid in g.players.keys) {
                if (!_players.containsKey(playerUid)) {
                  _players[playerUid] = db
                      .getPlayer(playerUid: playerUid)
                      .listen(_onPlayerUpdated);
                }
              }
            }
          }
          _updateSeasonStats(games);
        });
      });
    }

    if (event is SingleSeasonLoadPlayers) {
      // Load all the player details for this season.
      _lock.synchronized(() {
        for (String playerUid in state.season.playerUids.keys) {
          if (!_players.containsKey(playerUid)) {
            _players[playerUid] =
                db.getPlayer(playerUid: playerUid).listen(_onPlayerUpdated);
          }
        }
        if (state.loadedGames) {
          // See if we need to load any of the game players too.
          for (Game g in state.games) {
            for (String playerUid in g.players.keys) {
              if (!_players.containsKey(playerUid)) {
                _players[playerUid] =
                    db.getPlayer(playerUid: playerUid).listen(_onPlayerUpdated);
              }
            }
          }
        }
      });
    }
  }

  void _updateSeasonStats(BuiltList<Game> games) {
    SeasonSummaryBuilder summary = SeasonSummaryBuilder();
    Map<String, PlayerSeasonSummaryBuilder> playerSummary = {};
    for (var g in games) {
      summary.pointsFor += g.summary.pointsFor;
      summary.pointsAgainst += g.summary.pointsAgainst;
      summary.wins += (summary.pointsFor > summary.pointsAgainst) ? 1 : 0;
      summary.losses += (summary.pointsFor > summary.pointsAgainst) ? 0 : 1;

      for (var p in g.players.entries) {
        if (!playerSummary.containsKey(p.key)) {
          playerSummary[p.key] = PlayerSeasonSummaryBuilder();
        }
        var b = playerSummary[p.key].summary;
        b.fouls += p.value.fullData.fouls;
        b.steals += p.value.fullData.steals;
        b.one.attempts += p.value.fullData.one.attempts;
        b.one.made += p.value.fullData.one.made;
        b.two.attempts += p.value.fullData.two.attempts;
        b.two.made += p.value.fullData.two.made;
        b.three.attempts += p.value.fullData.three.attempts;
        b.three.made += p.value.fullData.three.made;
        b.blocks += p.value.fullData.blocks;
        b.turnovers += p.value.fullData.turnovers;
        b.defensiveRebounds += p.value.fullData.defensiveRebounds;
        b.offensiveRebounds += p.value.fullData.offensiveRebounds;
        b.assists += p.value.fullData.assists;
      }
    }
    if (state.season.summary != summary.build() ||
        state.season.playerUids.entries
            .any((var e) => playerSummary[e.key].build() != e.value)) {
      var season = state.season.toBuilder();
      season.summary = summary;
      for (var e in state.season.playerUids.entries) {
        if (playerSummary.containsKey(e.key)) {
          season.playerUids[e.key] = playerSummary[e.key].build();
        }
      }

      // Do an update.
      add(SingleSeasonUpdate(season: season.build()));
    }
  }

  void _onPlayerUpdated(Player event) {
    _loadedPlayers[event.uid] = event;
    // Do updates after we are loaded.
    if (_loadedPlayers.length == _players.length || state.loadedPlayers) {
      // Loaded them all.
      add(_SingleSeasonUpdatePlayers(players: BuiltMap.of(_loadedPlayers)));
    }
  }

  @override
  SingleSeasonState fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("type")) {
      return SingleSeasonUninitialized();
    }
    SingleSeasonStateType type = SingleSeasonStateType.valueOf(json["type"]);
    switch (type) {
      case SingleSeasonStateType.Uninitialized:
        return SingleSeasonUninitialized();
      case SingleSeasonStateType.Loaded:
        return SingleSeasonLoaded.fromMap(json);
      case SingleSeasonStateType.Deleted:
        return SingleSeasonDeleted.fromMap(json);
      case SingleSeasonStateType.SaveFailed:
        return SingleSeasonSaveFailed.fromMap(json);
      case SingleSeasonStateType.SaveSuccessful:
        return SingleSeasonSaveSuccessful.fromMap(json);
      case SingleSeasonStateType.Saving:
        return SingleSeasonSaving.fromMap(json);
      default:
        return SingleSeasonUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(SingleSeasonState state) {
    return state.toMap();
  }
}
