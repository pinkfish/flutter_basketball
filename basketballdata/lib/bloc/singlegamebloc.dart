import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../data/game.dart';

abstract class SingleGameState extends Equatable {
  final Game game;

  SingleGameState({@required this.game});

  @override
  List<Object> get props => [game];
}

///
/// We have a game, default state.
///
class SingleGameLoaded extends SingleGameState {
  SingleGameLoaded({@required Game game}) : super(game: game);

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
      : super(game: singleGameState.game);

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
      : super(game: singleGameState.game);

  @override
  String toString() {
    return 'SingleGameSaveFailed{}';
  }
}

///
/// Game got deleted.
///
class SingleGameDeleted extends SingleGameState {
  SingleGameDeleted() : super(game: null);

  @override
  String toString() {
    return 'SingleGameDeleted{}';
  }
}

///
/// What the system has not yet read the game state.
///
class SingleGameUninitialized extends SingleGameState {
  SingleGameUninitialized() : super(game: null);
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

class _SingleGameNewGame extends SingleGameEvent {
  final Game newGame;

  _SingleGameNewGame({@required this.newGame});

  @override
  List<Object> get props => [newGame];
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

  StreamSubscription<Game> _gameSub;

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

    if (event is SingleGameAddPlayer) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await db.addGamePlayer(gameUid: gameUid, playerUid: event.playerUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is SingleGameRemovePlayer) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await db.deleteGamePlayer(gameUid: gameUid, playerUid: event.playerUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is SingleGameDelete) {
      try {
        await db.deleteGame(gameUid: gameUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }
  }
}
