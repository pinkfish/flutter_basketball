import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/gameperiod.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/game.dart';

abstract class SingleGameState extends Equatable {
  final Game game;
  final bool loadedGameEvents;
  final BuiltList<GameEvent> gameEvents;

  SingleGameState(
      {@required this.game,
      @required this.loadedGameEvents,
      @required this.gameEvents});

  @override
  List<Object> get props => [game, loadedGameEvents, gameEvents];
}

///
/// We have a game, default state.
///
class SingleGameLoaded extends SingleGameState {
  SingleGameLoaded(
      {Game game,
      bool loadedGameEvents,
      BuiltList<GameEvent> gameEvents,
      SingleGameState state})
      : super(
            game: game ?? state.game,
            loadedGameEvents: loadedGameEvents ?? state.loadedGameEvents,
            gameEvents: gameEvents ?? state.gameEvents);

  @override
  String toString() {
    return 'SingleGameLoaded{}';
  }
}

///
/// We have a game, default state.
///
class SingleGameChangeEvents extends SingleGameState {
  final BuiltList<GameEvent> newEvents;
  final BuiltList<GameEvent> removedEvents;

  SingleGameChangeEvents({
    Game game,
    bool loadedGameEvents,
    BuiltList<GameEvent> gameEvents,
    SingleGameState state,
    this.newEvents,
    this.removedEvents,
  }) : super(
            game: game ?? state.game,
            loadedGameEvents: loadedGameEvents ?? state.loadedGameEvents,
            gameEvents: gameEvents ?? state.gameEvents);

  @override
  String toString() {
    return 'SingleGameChangeEvents{}';
  }

  @override
  List<Object> get props =>
      [game, loadedGameEvents, gameEvents, newEvents, removedEvents];
}

///
/// Saving operation in progress.
///
class SingleGameSaving extends SingleGameState {
  SingleGameSaving({@required SingleGameState singleGameState})
      : super(
            game: singleGameState.game,
            loadedGameEvents: singleGameState.loadedGameEvents,
            gameEvents: singleGameState.gameEvents);

  @override
  String toString() {
    return 'SingleGameSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleGameSaveFailed extends SingleGameState {
  final Error error;

  SingleGameSaveFailed({@required SingleGameState singleGameState, this.error})
      : super(
            game: singleGameState.game,
            loadedGameEvents: singleGameState.loadedGameEvents,
            gameEvents: singleGameState.gameEvents);

  @override
  String toString() {
    return 'SingleGameSaveFailed{}';
  }
}

///
/// Game got deleted.
///
class SingleGameDeleted extends SingleGameState {
  SingleGameDeleted()
      : super(
            game: null, loadedGameEvents: false, gameEvents: BuiltList.of([]));

  @override
  String toString() {
    return 'SingleGameDeleted{}';
  }
}

///
/// What the system has not yet read the game state.
///
class SingleGameUninitialized extends SingleGameState {
  SingleGameUninitialized()
      : super(
            game: null, loadedGameEvents: false, gameEvents: BuiltList.of([]));
}

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

  SingleGameAddPlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
}

///
/// Adds an event to the game.
///
class SingleGameAddEvent extends SingleGameEvent {
  final GameEvent event;

  SingleGameAddEvent({@required this.event});

  @override
  List<Object> get props => [event];
}

///
/// Removes an event from the game.
///
class SingleGameRemoveEvent extends SingleGameEvent {
  final String eventUid;

  SingleGameRemoveEvent({@required this.eventUid});

  @override
  List<Object> get props => [eventUid];
}

///
/// Deletes an player from the game.
///
class SingleGameRemovePlayer extends SingleGameEvent {
  final String playerUid;

  SingleGameRemovePlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
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

class _SingleGameDeleted extends SingleGameEvent {
  _SingleGameDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleGameBloc extends Bloc<SingleGameEvent, SingleGameState> {
  final String gameUid;
  final BasketballDatabase db;
  final Lock _lock = Lock();

  StreamSubscription<Game> _gameSub;
  StreamSubscription<BuiltList<GameEvent>> _gameEventSub;

  SingleGameBloc({@required this.db, @required this.gameUid}) {
    _gameSub = db.getGame(gameUid: gameUid).listen(_onGameUpdate);
  }

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
    await super.close();
  }

  @override
  SingleGameState get initialState {
    return SingleGameUninitialized();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
      print("newGame ${event.newGame}");
      yield SingleGameLoaded(game: event.newGame, state: state);
    }

    if (event is _SingleGameNewEvents) {
      yield SingleGameChangeEvents(
          gameEvents: event.events,
          state: state,
          newEvents: event.newEvents,
          removedEvents: event.removedEvents);
      yield SingleGameLoaded(gameEvents: event.events, state: state);
    }

    // The game is deleted.
    if (event is _SingleGameDeleted) {
      yield SingleGameDeleted();
    }

    // Save the game.
    if (event is SingleGameUpdate) {
      yield SingleGameSaving(singleGameState: state);
      try {
        Game game = event.game;
        await db.updateGame(game: game);
        yield SingleGameLoaded(game: event.game, state: state);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Adds the game event into the system.
    if (event is SingleGameAddEvent) {
      try {
        await db.addGameEvent(
            event: event.event.rebuild((b) => b..gameUid = this.gameUid));
      } catch (e) {
        print(e);
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Removes the game event from the system.
    if (event is SingleGameRemoveEvent) {
      try {
        await db.deleteGameEvent(gameEventUid: event.eventUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is SingleGameLoadEvents) {
      print("Loading events");
      _lock.synchronized(() {
        if (_gameEventSub == null) {
          _gameEventSub = db
              .getGameEvents(gameUid: gameUid)
              .listen((BuiltList<GameEvent> ev) => _newGameEvents(ev));
        }
      });
    }

    // Adds a player to the game
    if (event is SingleGameAddPlayer) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await db.addGamePlayer(gameUid: gameUid, playerUid: event.playerUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Removes a player from the game.
    if (event is SingleGameRemovePlayer) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await db.deleteGamePlayer(gameUid: gameUid, playerUid: event.playerUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Deletes the game.
    if (event is SingleGameDelete) {
      try {
        await db.deleteGame(gameUid: gameUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }
  }

  void _newGameEvents(BuiltList<GameEvent> evList) {
    // Same length, don't recalculate.
    if (evList.length == state.gameEvents.length) {
      return;
    }
    Map<String, PlayerSummaryBuilder> players = state.game.players
        .toMap()
        .map((var e, var v) => MapEntry(e, PlayerSummaryBuilder()));
    Map<String, PlayerSummaryBuilder> opponents = state.game.opponents
        .toMap()
        .map((var e, var v) => MapEntry(e, PlayerSummaryBuilder()));
    GameSummaryBuilder gameSummary = GameSummaryBuilder()
      ..pointsFor = 0
      ..pointsAgainst = 0;
    PlayerSummaryBuilder playerSummary = PlayerSummaryBuilder();
    PlayerSummaryBuilder opponentSummary = PlayerSummaryBuilder();

    var sortedList = evList.toList();
    sortedList
        .sort((GameEvent a, GameEvent b) => a.timestamp.compareTo(b.timestamp));
    GamePeriod currentPeriod = GamePeriod.NotStarted;
    // Check the summary and update if needed.
    for (GameEvent ev in sortedList) {
      PlayerSummaryDataBuilder sum;
      PlayerSummaryDataBuilder playerSum;
      GamePeriod oldPeriod = currentPeriod;
      if (ev.type != GameEventType.PeriodStart) {
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
          break;
      }
      if (ev.type != GameEventType.PeriodStart) {
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
    if (state.game.playerSummaery != playerSummary.build() ||
        state.game.opponentSummary != opponentSummary.build() ||
        state.game.summary != gameSummary.build() ||
        state.game.players.entries.every((MapEntry<String, PlayerSummary> e) =>
            players[e.key].build() == e.value) ||
        state.game.currentPeriod != currentPeriod ||
        state.game.opponents.entries.every(
            (MapEntry<String, PlayerSummary> e) =>
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
}
