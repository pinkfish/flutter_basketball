import 'dart:async';

import 'package:basketballdata/data/media/mediainfo.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/game/game.dart';
import '../data/game/gameevent.dart';
import '../data/game/gameeventtype.dart';
import '../data/game/gameperiod.dart';
import '../data/game/gamesummary.dart';
import '../data/game/playergamesummary.dart';
import '../data/player/player.dart';
import '../data/player/playersummarydata.dart';
import '../db/basketballdatabase.dart';
import 'crashreporting.dart';
import 'data/singlegamestate.dart';

abstract class SingleGameEvent extends Equatable {}

///
/// Updates the game (writes it out to firebase.
///
class SingleGameUpdate extends SingleGameEvent {
  final Game game;

  SingleGameUpdate({@required this.game});

  @override
  List<Object> get props => [game];
}

///
/// Adds an admin to the game.
///
class SingleGameAddPlayer extends SingleGameEvent {
  final String playerUid;
  final bool opponent;

  SingleGameAddPlayer({@required this.playerUid, @required this.opponent});

  @override
  List<Object> get props => [playerUid, opponent];
}

///
/// Adds an admin to the game.
///
class SingleGameUpdatePlayer extends SingleGameEvent {
  final BuiltMap<String, PlayerSummaryWithOpponent> summary;

  SingleGameUpdatePlayer({
    @required this.summary,
  });

  @override
  List<Object> get props => [summary];
}

///
/// The summary with the opponent flag.
///
class PlayerSummaryWithOpponent {
  final PlayerGameSummary summary;
  final bool opponent;

  PlayerSummaryWithOpponent(this.opponent, this.summary);
}

///
/// Deletes an player from the game.
///
class SingleGameRemovePlayer extends SingleGameEvent {
  final String playerUid;
  final bool opponent;

  SingleGameRemovePlayer({@required this.playerUid, @required this.opponent});

  @override
  List<Object> get props => [playerUid, opponent];
}

///
/// Delete this game from the world.
///
class SingleGameDelete extends SingleGameEvent {
  SingleGameDelete();

  @override
  List<Object> get props => [];
}

///
/// Load the game eventsa
///
class SingleGameLoadEvents extends SingleGameEvent {
  SingleGameLoadEvents();

  @override
  List<Object> get props => [];
}

///
/// Load the game media
///
class SingleGameLoadMedia extends SingleGameEvent {
  SingleGameLoadMedia();

  @override
  List<Object> get props => [];
}

///
/// Loads the players associated with this game.
///
class SingleGameLoadPlayers extends SingleGameEvent {
  @override
  List<Object> get props => null;
}

class _SingleGameNewGame extends SingleGameEvent {
  final Game newGame;

  _SingleGameNewGame({@required this.newGame});

  @override
  List<Object> get props => [newGame];
}

class _SingleGameNewEvents extends SingleGameEvent {
  final BuiltList<GameEvent> events;
  final BuiltList<GameEvent> newEvents;
  final BuiltList<GameEvent> removedEvents;

  _SingleGameNewEvents(
      {@required this.events, this.newEvents, this.removedEvents});

  @override
  List<Object> get props => [events, newEvents, removedEvents];
}

class _SingleGameNewMedia extends SingleGameEvent {
  final BuiltList<MediaInfo> newMedia;

  _SingleGameNewMedia({@required this.newMedia});

  @override
  List<Object> get props => [newMedia];
}

class _SingleGameDeleted extends SingleGameEvent {
  _SingleGameDeleted();

  @override
  List<Object> get props => [];
}

class _SingleGameUpdatePlayers extends SingleGameEvent {
  final BuiltMap<String, Player> players;

  _SingleGameUpdatePlayers({@required this.players});

  @override
  List<Object> get props => [players];
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleGameBloc extends HydratedBloc<SingleGameEvent, SingleGameState> {
  final String gameUid;
  final BasketballDatabase db;
  final Lock _lock = Lock();
  final CrashReporting crashes;
  final bool loadPlayers;
  final bool loadMedia;
  final bool loadGameEvents;

  StreamSubscription<Game> _gameSub;
  StreamSubscription<BuiltList<GameEvent>> _gameEventSub;

  StreamSubscription<BuiltList<MediaInfo>> _mediaInfoSub;

  Map<String, StreamSubscription<Player>> _players;
  Map<String, Player> _loadedPlayers;

  SingleGameBloc(
      {@required this.db,
      @required this.gameUid,
      @required this.crashes,
      this.loadPlayers = false,
      this.loadMedia = false,
      this.loadGameEvents = false})
      : super(SingleGameUninitialized()) {
    _gameSub = db.getGame(gameUid: gameUid).listen(_onGameUpdate);
    _players = {};
    _loadedPlayers = {};
    _loadStuff();
  }

  void _loadStuff() {
    if (state is SingleGameLoaded) {
      if (loadPlayers && !state.loadedPlayers) {
        add(SingleGameLoadPlayers());
      }
      if (loadMedia && !state.loadedMedia) {
        add(SingleGameLoadMedia());
      }
      if (loadGameEvents && !state.loadedGameEvents) {
        add(SingleGameLoadEvents());
      }
    }
  }

  @override
  String get id => gameUid;

  void _onGameUpdate(Game g) {
    if (g != this.state.game) {
      if (g != null) {
        add(_SingleGameNewGame(newGame: g));
      } else {
        add(_SingleGameDeleted());
      }
    }
  }

  @override
  Future<void> close() async {
    _gameSub?.cancel();
    _gameSub = null;
    _gameEventSub?.cancel();
    _gameEventSub = null;
    _mediaInfoSub?.cancel();
    _mediaInfoSub = null;
    for (var s in _players.values) {
      s.cancel();
    }
    _players.clear();
    _loadedPlayers.clear();
    await super.close();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
      yield (SingleGameLoaded.fromState(state)
            ..game = event.newGame.toBuilder())
          .build();
      _loadStuff();
    }

    if (event is _SingleGameNewEvents) {
      yield (SingleGameChangeEvents.fromState(state)
            ..gameEvents = event.events.toBuilder()
            ..newEvents = event.newEvents.toBuilder()
            ..removedEvents = event.removedEvents.toBuilder())
          .build();
      yield (SingleGameLoaded.fromState(state)
            ..gameEvents = event.events.toBuilder()
            ..loadedGameEvents = true)
          .build();
    }

    // The game is deleted.
    if (event is _SingleGameDeleted) {
      yield SingleGameDeleted();
    }

    // Save the game.
    if (event is SingleGameUpdate) {
      yield SingleGameSaving.fromState(state).build();
      try {
        // Add an opponent if they don't exist.
        if (event.game.opponents.length == 0) {
          String name = event.game.opponentName;
          if (name == null || name.isEmpty) {
            name = "Default";
          }
          String uid = await db.addPlayer(
              player: Player((b) => b
                ..jerseyNumber = "**"
                ..name = name));
          await db.addGamePlayer(
              gameUid: gameUid, playerUid: uid, opponent: true);
        }

        Game game = event.game;
        await db.updateGame(game: game);
        yield (SingleGameSaveSuccessful.fromState(state)
              ..game = event.game.toBuilder())
            .build();
        yield (SingleGameLoaded.fromState(state)..game = event.game.toBuilder())
            .build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
      }
    }

    if (event is SingleGameLoadEvents) {
      print(" events $event");

      _lock.synchronized(() {
        if (_gameEventSub == null) {
          _gameEventSub = db
              .getGameEvents(gameUid: gameUid)
              .listen((BuiltList<GameEvent> ev) => _newGameEvents(ev));
        }
      });
    }

    if (event is SingleGameLoadMedia) {
      print(" events $event");

      _lock.synchronized(() {
        if (_mediaInfoSub == null) {
          _mediaInfoSub = db.getMediaForGame(gameUid: gameUid).listen(
              (BuiltList<MediaInfo> ev) =>
                  add(_SingleGameNewMedia(newMedia: ev)));
        }
      });
    }

    if (event is _SingleGameNewMedia) {
      yield (SingleGameLoaded.fromState(state)
            ..media = event.newMedia.toBuilder()
            ..loadedMedia = true)
          .build();
    }

    // Adds a player to the game
    if (event is SingleGameAddPlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.addGamePlayer(
            gameUid: gameUid,
            playerUid: event.playerUid,
            opponent: event.opponent);
        yield SingleGameSaveSuccessful.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }

    // Updates a player in the game
    if (event is SingleGameUpdatePlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        for (MapEntry<String, PlayerSummaryWithOpponent> entry
            in event.summary.entries) {
          await db.updateGamePlayerData(
              gameUid: gameUid,
              opponent: entry.value.opponent,
              summary: entry.value.summary,
              playerUid: entry.key);
        }
        yield SingleGameSaveSuccessful.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }
    // Removes a player from the game.
    if (event is SingleGameRemovePlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.deleteGamePlayer(
            gameUid: gameUid,
            playerUid: event.playerUid,
            opponent: event.opponent);
        yield SingleGameSaveSuccessful.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }

    // Deletes the game.
    if (event is SingleGameDelete) {
      try {
        await db.deleteGame(gameUid: gameUid);
        yield SingleGameSaveSuccessful.fromState(state).build();
        yield SingleGameDeleted();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }

    if (event is SingleGameLoadPlayers) {
      // Load all the player details for this season.
      _lock.synchronized(() {
        for (String playerUid in state.game.players.keys) {
          if (!_players.containsKey(playerUid)) {
            _players[playerUid] =
                db.getPlayer(playerUid: playerUid).listen(_onPlayerUpdated);
          }
        }
      });
    }

    if (event is _SingleGameUpdatePlayers) {
      yield (SingleGameLoaded.fromState(state)
            ..players = event.players.toBuilder()
            ..loadedPlayers = true)
          .build();
    }
  }

  void _onPlayerUpdated(Player event) {
    _loadedPlayers[event.uid] = event;
    // Do updates after we are loaded.
    if (_loadedPlayers.length == _players.length || state.loadedPlayers) {
      // Loaded them all.
      add(_SingleGameUpdatePlayers(players: BuiltMap.of(_loadedPlayers)));
    }
  }

  void _newGameEvents(BuiltList<GameEvent> evList) {
    // Same length, don't recalculate.
    if (evList.length == state.gameEvents.length && state.loadedGameEvents) {
      return;
    }
    Map<String, PlayerGameSummaryBuilder> players = state.game.players
        .toMap()
        .map((var e, var v) => MapEntry(e, PlayerGameSummaryBuilder()));
    Map<String, PlayerGameSummaryBuilder> opponents = state.game.opponents
        .toMap()
        .map((var e, var v) => MapEntry(e, PlayerGameSummaryBuilder()));
    GameSummaryBuilder gameSummary = GameSummaryBuilder()
      ..pointsFor = 0
      ..pointsAgainst = 0;
    PlayerGameSummaryBuilder playerSummary = PlayerGameSummaryBuilder();
    PlayerGameSummaryBuilder opponentSummary = PlayerGameSummaryBuilder();

    var sortedList = evList.toList();
    sortedList
        .sort((GameEvent a, GameEvent b) => a.timestamp.compareTo(b.timestamp));
    GamePeriod currentPeriod = GamePeriod.NotStarted;

    // Check the summary and update if needed.
    for (GameEvent ev in sortedList) {
      PlayerSummaryDataBuilder sum;
      PlayerSummaryDataBuilder playerSum;
      GamePeriod oldPeriod = currentPeriod;
      if (ev.type != GameEventType.PeriodStart &&
          ev.type != GameEventType.PeriodEnd &&
          ev.type != GameEventType.TimeoutEnd &&
          ev.type != GameEventType.TimeoutStart) {
        if (ev.opponent) {
          sum = opponentSummary.perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
          // .putIfAbsent(currentPeriod, () => PlayerSummaryData());
          playerSum = opponents[ev.playerUid]
              .perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
        } else {
          sum = playerSummary.perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
          playerSum = players[ev.playerUid]
              .perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
        }
      }
      switch (ev.type) {
        case GameEventType.Made:
          if (ev.points == 1) {
            sum.one.made++;
            sum.one.attempts++;
            playerSum.one.made++;
            playerSum.one.attempts++;
          } else if (ev.points == 2) {
            sum.two.made++;
            sum.two.attempts++;
            playerSum.two.made++;
            playerSum.two.attempts++;
          } else if (ev.points == 3) {
            sum.three.made++;
            sum.three.attempts++;
            playerSum.three.made++;
            playerSum.three.attempts++;
          }
          if (ev.opponent) {
            gameSummary.pointsAgainst += ev.points;
          } else {
            gameSummary.pointsFor += ev.points;
          }
          break;
        case GameEventType.Missed:
          if (ev.points == 1) {
            sum.one.attempts++;
            playerSum.one.attempts++;
          } else if (ev.points == 2) {
            sum.two.attempts++;
            playerSum.two.attempts++;
          } else if (ev.points == 3) {
            sum.three.attempts++;
            playerSum.three.attempts++;
          }
          break;
        case GameEventType.Foul:
          sum.fouls++;
          playerSum.fouls++;
          break;
        case GameEventType.Sub:
          if (ev.opponent) {
            opponents[ev.playerUid].currentlyPlaying = false;
            opponents[ev.replacementPlayerUid].currentlyPlaying = true;
          } else {
            players[ev.playerUid].currentlyPlaying = false;
            players[ev.replacementPlayerUid].currentlyPlaying = true;
          }
          break;
        case GameEventType.OffsensiveRebound:
          sum.offensiveRebounds++;
          playerSum.offensiveRebounds++;
          break;
        case GameEventType.DefensiveRebound:
          sum.defensiveRebounds++;
          playerSum.defensiveRebounds++;
          break;
        case GameEventType.Block:
          sum.blocks++;
          playerSum.blocks++;
          break;
        case GameEventType.Assist:
          sum.assists++;
          playerSum.assists++;
          break;
        case GameEventType.Steal:
          sum.steals++;
          playerSum.steals++;
          break;
        case GameEventType.Turnover:
          sum.turnovers++;
          playerSum.turnovers++;
          break;
        case GameEventType.PeriodStart:
          currentPeriod = ev.period;
          if (ev.period == GamePeriod.Finished) {
            gameSummary.finished = true;
          } else {
            gameSummary.finished = false;
          }
          break;
      }
      if (ev.type != GameEventType.PeriodStart &&
          ev.type != GameEventType.PeriodEnd &&
          ev.type != GameEventType.TimeoutEnd &&
          ev.type != GameEventType.TimeoutStart) {
        if (ev.opponent) {
          opponentSummary.perPeriod[oldPeriod] = sum.build();
          opponents[ev.playerUid].perPeriod[oldPeriod] = playerSum.build();
        } else {
          playerSummary.perPeriod[oldPeriod] = sum.build();
          players[ev.playerUid].perPeriod[oldPeriod] = playerSum.build();
        }
      }
    }

    // See if this is different the current state and update if it is.
    print(gameSummary.build());
    if (state.game.playerSummaery != playerSummary.build() ||
        state.game.opponentSummary != opponentSummary.build() ||
        state.game.summary != gameSummary.build() ||
        state.game.players.entries.every(
            (MapEntry<String, PlayerGameSummary> e) =>
                players[e.key].build() == e.value) ||
        state.game.currentPeriod != currentPeriod ||
        state.game.opponents.entries.every(
            (MapEntry<String, PlayerGameSummary> e) =>
                opponents[e.key].build() == e.value)) {
      db.updateGame(
          game: state.game.rebuild((b) => b
            ..summary = gameSummary
            ..opponentSummary = opponentSummary
            ..playerSummaery = playerSummary
            ..currentPeriod = currentPeriod
            ..players = MapBuilder(
                players.map((var e, var v) => MapEntry(e, v.build())))
            ..opponents = MapBuilder(
                opponents.map((var e, var v) => MapEntry(e, v.build())))));
    }

    var removed = state.gameEvents
        .where((GameEvent e) => evList.every((GameEvent e2) => e != e2));
    var added = evList.where(
        (GameEvent e) => state.gameEvents.every((GameEvent e2) => e != e2));
    add(_SingleGameNewEvents(
        events: evList,
        removedEvents: BuiltList.of(removed),
        newEvents: BuiltList.of(added)));
  }

  @override
  SingleGameState fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("type")) {
      return SingleGameUninitialized();
    }
    SingleGameStateType type = SingleGameStateType.valueOf(json["type"]);
    switch (type) {
      case SingleGameStateType.Uninitialized:
        return SingleGameUninitialized();
      case SingleGameStateType.Loaded:
        return SingleGameLoaded.fromMap(json);
      case SingleGameStateType.Deleted:
        return SingleGameDeleted.fromMap(json);
      case SingleGameStateType.SaveFailed:
        return SingleGameSaveFailed.fromMap(json);
      case SingleGameStateType.SaveSuccessful:
        return SingleGameSaveSuccessful.fromMap(json);
      case SingleGameStateType.Saving:
        return SingleGameSaving.fromMap(json);
      default:
        return SingleGameUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(SingleGameState state) {
    return state.toMap();
  }
}
