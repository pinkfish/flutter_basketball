import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
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

  _SingleGameNewEvents({@required this.events});

  @override
  List<Object> get props => [events];
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
  final Lock _lock = new Lock();

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
      yield SingleGameLoaded(game: event.newGame);
    }

    if (event is _SingleGameNewEvents) {
      yield SingleGameLoaded(gameEvents: event.events);
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
        yield SingleGameLoaded(game: event.game);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Adds the game event into the system.
    if (event is SingleGameAddEvent) {
      try {
        await db.addGameEvent(gameUid: gameUid, event: event.event);
      } catch (e) {
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
    GameSummaryBuilder gameSummary = GameSummaryBuilder();
    PlayerSummaryBuilder playerSummary = PlayerSummaryBuilder();
    PlayerSummaryBuilder opponentSummary = PlayerSummaryBuilder();

    // Check the summary and update if needed.
    for (GameEvent ev in evList) {
      PlayerSummaryBuilder sum;
      PlayerSummaryBuilder playerSum;
      if (ev.opponent) {
        sum = opponentSummary;
        playerSum = opponents[ev.playerUid];
      } else {
        sum = playerSummary;
        playerSum = players[ev.playerUid];
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
          // TODO: Handle this case.
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
      }
    }

    // See if this is different the current state and update if it is.
    if (state.game.playerSummaery != playerSummary.build() ||
        state.game.opponentSummary != opponentSummary.build() ||
        state.game.summary != gameSummary.build() ||
        state.game.players.entries.every((MapEntry<String, PlayerSummary> e) =>
            players[e.key].build() == e.value) ||
        state.game.opponents.entries.every(
            (MapEntry<String, PlayerSummary> e) =>
                opponents[e.key].build() == e.value)) {
      db.updateGame(
          game: state.game.rebuild((b) => b
            ..summary = gameSummary
            ..opponentSummary = opponentSummary
            ..playerSummaery = playerSummary
            ..players = MapBuilder(players)
            ..opponents = MapBuilder(opponents)));
    }

    add(_SingleGameNewEvents(events: evList));
  }
}
