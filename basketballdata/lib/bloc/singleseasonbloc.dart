import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/season/seasonsummary.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/game/game.dart';
import '../data/season/season.dart';

abstract class SingleSeasonBlocState extends Equatable {
  final Season season;
  final BuiltList<Game> games;
  final BuiltMap<String, Player> players;
  final bool loadedGames;
  final bool loadedPlayers;

  SingleSeasonBlocState(
      {@required this.season,
      @required this.games,
      @required this.loadedGames,
      @required this.players,
      @required this.loadedPlayers});

  @override
  List<Object> get props =>
      [season, games, loadedGames, players, loadedPlayers];
}

///
/// We have a season, default state.
///
class SingleSeasonLoaded extends SingleSeasonBlocState {
  SingleSeasonLoaded(
      {@required SingleSeasonBlocState state,
      Season season,
      BuiltList<Game> games,
      bool loadedGames,
      BuiltMap<String, Player> players,
      bool loadedPlayers})
      : super(
            season: season ?? state.season,
            games: games ?? state.games,
            loadedGames: loadedGames ?? state.loadedGames,
            players: players ?? state.players,
            loadedPlayers: loadedPlayers ?? state.loadedPlayers);

  @override
  String toString() {
    return 'SingleSeasonLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleSeasonSaving extends SingleSeasonBlocState {
  SingleSeasonSaving({@required SingleSeasonBlocState singleSeasonState})
      : super(
            season: singleSeasonState.season,
            games: singleSeasonState.games,
            loadedGames: singleSeasonState.loadedGames,
            players: singleSeasonState.players,
            loadedPlayers: singleSeasonState.loadedPlayers);

  @override
  String toString() {
    return 'SingleSeasonSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleSeasonSaveFailed extends SingleSeasonBlocState {
  final Error error;

  SingleSeasonSaveFailed(
      {@required SingleSeasonBlocState singleSeasonState, this.error})
      : super(
            season: singleSeasonState.season,
            games: singleSeasonState.games,
            loadedGames: singleSeasonState.loadedGames,
            players: singleSeasonState.players,
            loadedPlayers: singleSeasonState.loadedPlayers);

  @override
  String toString() {
    return 'SingleSeasonSaveFailed{}';
  }
}

///
/// Season got deleted.
///
class SingleSeasonDeleted extends SingleSeasonBlocState {
  SingleSeasonDeleted()
      : super(
            season: null,
            games: BuiltList.of([]),
            loadedGames: false,
            players: BuiltMap.of({}),
            loadedPlayers: false);

  @override
  String toString() {
    return 'SingleSeasonDeleted{}';
  }
}

///
/// Season is still loading.
///
class SingleSeasonUninitialized extends SingleSeasonBlocState {
  SingleSeasonUninitialized()
      : super(
            season: null,
            games: BuiltList.of([]),
            loadedGames: false,
            players: BuiltMap.of({}),
            loadedPlayers: false);

  @override
  String toString() {
    return 'SingleSeasonUninitialized{}';
  }
}

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
class SingleSeasonBloc extends Bloc<SingleSeasonEvent, SingleSeasonBlocState> {
  final BasketballDatabase db;
  final String seasonUid;
  final Lock _lock = new Lock();

  StreamSubscription<Season> _seasonSub;
  StreamSubscription<BuiltList<Game>> _gameSub;
  Map<String, StreamSubscription<Player>> _players;
  Map<String, Player> _loadedPlayers;

  SingleSeasonBloc({@required this.db, @required this.seasonUid})
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
  Future<void> close() async {
    _seasonSub?.cancel();
    _gameSub?.cancel();
    await super.close();
  }

  @override
  Stream<SingleSeasonBlocState> mapEventToState(
      SingleSeasonEvent event) async* {
    if (event is _SingleSeasonNewSeason) {
      yield SingleSeasonLoaded(state: state, season: event.newSeason);
    }

    // The season is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the season.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving(singleSeasonState: state);
      try {
        Season season = event.season;
        if (season != state.season) {
          await db.updateSeason(season: season);
        } else {
          yield SingleSeasonLoaded(state: state, season: event.season);
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: error);
      }
    }

    if (event is SingleSeasonAddPlayer) {
      yield SingleSeasonSaving(singleSeasonState: state);
      try {
        if (!state.season.playerUids.containsKey(event.playerUid)) {
          await db.addSeasonPlayer(
              seasonUid: seasonUid, playerUid: event.playerUid);
        } else {
          yield SingleSeasonLoaded(state: state);
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: error);
      }
    }

    if (event is SingleSeasonRemovePlayer) {
      yield SingleSeasonSaving(singleSeasonState: state);
      try {
        if (state.season.playerUids.containsKey(event.playerUid)) {
          await db.deleteSeasonPlayer(
              seasonUid: seasonUid, playerUid: event.playerUid);
        } else {
          yield SingleSeasonLoaded(state: state);
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: error);
      }
    }

    if (event is SingleSeasonDelete) {
      try {
        await db.deleteSeason(seasonUid: seasonUid);
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: error);
      }
    }

    if (event is _SingleSeasonUpdateGames) {
      yield SingleSeasonLoaded(
          state: state, games: event.games, loadedGames: true);
    }

    if (event is _SingleSeasonUpdatePlayers) {
      yield SingleSeasonLoaded(
          state: state, players: event.players, loadedPlayers: true);
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
}
