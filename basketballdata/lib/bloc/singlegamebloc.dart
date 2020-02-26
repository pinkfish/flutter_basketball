import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../data/game.dart';
import '../data/player.dart';
import 'gamesbloc.dart';

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
  final Player player;

  SingleGameAddPlayer({@required this.player});

  @override
  List<Object> get props => [player];
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
  final GamesBloc gameBloc;
  final String gameUid;

  StreamSubscription<GamesBlocState> _gameSub;

  SingleGameBloc({@required this.gameBloc, @required this.gameUid}) {
    _gameSub = gameBloc.listen((GamesBlocState gameState) {
      Game game = gameState.games
          .firstWhere((g) => g.uid == gameUid, orElse: () => null);
      if (game != null) {
        // Only send this if the game is not the same.
        if (game != state.game) {
          add(_SingleGameNewGame(newGame: game));
        }
      } else {
        add(_SingleGameDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    _gameSub?.cancel();
    await super.close();
  }

  @override
  SingleGameState get initialState {
    if (gameBloc.state.games.any((g) => g.uid == gameUid)) {
      return SingleGameLoaded(
          game: gameBloc.state.games.firstWhere((g) => g.uid == gameUid));
    }
    return SingleGameDeleted();
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
        await gameBloc.db.updateGame(game: game);
        yield SingleGameLoaded(game: event.game);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is SingleGameAddPlayer) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.db.addGamePlayer(gameUid: gameUid, player: event.player);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is SingleGameRemovePlayer) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.db
            .deleteGamePlayer(gameUid: gameUid, playerUid: event.playerUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is SingleGameDelete) {
      try {
        await gameBloc.db.deleteGame(gameUid: gameUid);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }
  }
}
