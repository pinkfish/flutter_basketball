import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../basketballdata.dart';
import 'crashreporting.dart';
import 'data/singleplayerstate.dart';

abstract class SinglePlayerEvent extends Equatable {}

///
/// Updates the player (writes it out to firebase.
///
class SinglePlayerUpdate extends SinglePlayerEvent {
  final Player player;

  SinglePlayerUpdate({@required this.player});

  @override
  List<Object> get props => [player];
}

///
/// Deletes this player from the world.
///
class SinglePlayerDelete extends SinglePlayerEvent {
  SinglePlayerDelete();

  @override
  List<Object> get props => [];
}

///
/// Loads the player and loads a game.
///
class SinglePlayerLoadGames extends SinglePlayerEvent {
  SinglePlayerLoadGames();

  @override
  List<Object> get props => [];
}

class _SinglePlayerNewPlayer extends SinglePlayerEvent {
  final Player newPlayer;

  _SinglePlayerNewPlayer({@required this.newPlayer});

  @override
  List<Object> get props => [newPlayer];
}

class _SinglePlayerLoadedGames extends SinglePlayerEvent {
  final BuiltList<Game> games;

  _SinglePlayerLoadedGames({@required this.games});

  @override
  List<Object> get props => [games];
}

class _SinglePlayerDeleted extends SinglePlayerEvent {
  _SinglePlayerDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific player.
///
class SinglePlayerBloc
    extends HydratedBloc<SinglePlayerEvent, SinglePlayerState> {
  final String playerUid;
  final BasketballDatabase db;
  final Lock _lock = Lock();
  final CrashReporting crashes;
  final bool loadGames;

  StreamSubscription<Player> _playerSub;
  StreamSubscription<BuiltList<Game>> _gameEventSub;

  SinglePlayerBloc(
      {@required this.db,
      @required this.playerUid,
      @required this.crashes,
      this.loadGames = false})
      : super(SinglePlayerUninitialized()) {
    _playerSub = db.getPlayer(playerUid: playerUid).listen(_onPlayerUpdate);
    _loadStuff();
  }

  void _loadStuff() {
    if (!(state is SinglePlayerLoaded) && loadGames && !state.loadedGames) {
      add(SinglePlayerLoadGames());
    }
  }

  @override
  String get id => playerUid;

  void _onPlayerUpdate(Player g) {
    if (g != this.state.player) {
      if (g != null) {
        add(_SinglePlayerNewPlayer(newPlayer: g));
      } else {
        add(_SinglePlayerDeleted());
      }
    }
  }

  @override
  Future<void> close() async {
    _playerSub?.cancel();
    _playerSub = null;
    _gameEventSub?.cancel();
    _gameEventSub = null;
    await super.close();
  }

  @override
  Stream<SinglePlayerState> mapEventToState(SinglePlayerEvent event) async* {
    if (event is _SinglePlayerNewPlayer) {
      yield (SinglePlayerLoaded.fromState(state)
            ..player = event.newPlayer.toBuilder())
          .build();
      _loadStuff();
    }

    // The player is deleted.
    if (event is _SinglePlayerDeleted) {
      yield SinglePlayerDeleted();
    }

    if (event is SinglePlayerDelete) {
      yield SinglePlayerSaving.fromState(state).build();
      try {
        Player player = state.player;
        await db.deletePlayer(playerUid: player.uid);
        yield SinglePlayerDeleted();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SinglePlayerSaveFailed.fromState(state)..error = error).build();
      }
    }

    // Save the player.
    if (event is SinglePlayerUpdate) {
      yield SinglePlayerSaving.fromState(state).build();
      try {
        Player player = event.player;
        await db.updatePlayer(player: player);
        yield SinglePlayerSaveSuccessful.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SinglePlayerSaveFailed.fromState(state)..error = error).build();
      }
    }

    if (event is _SinglePlayerLoadedGames) {
      yield (SinglePlayerLoaded.fromState(state)
            ..loadedGames = true
            ..games = event.games.toBuilder())
          .build();
    }

    if (event is SinglePlayerLoadGames) {
      _lock.synchronized(() {
        if (_gameEventSub == null) {
          _gameEventSub = db
              .getGamesForPlayer(playerUid: playerUid)
              .listen((BuiltList<Game> ev) {
            add(_SinglePlayerLoadedGames(games: ev));
          });
        }
      });
    }
  }

  @override
  SinglePlayerState fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("type")) {
      return SinglePlayerUninitialized();
    }
    SinglePlayerStateType type = SinglePlayerStateType.valueOf(json["type"]);
    switch (type) {
      case SinglePlayerStateType.Uninitialized:
        return SinglePlayerUninitialized();
      case SinglePlayerStateType.Loaded:
        return SinglePlayerLoaded.fromMap(json);
      case SinglePlayerStateType.Deleted:
        return SinglePlayerDeleted.fromMap(json);
      case SinglePlayerStateType.SaveFailed:
        return SinglePlayerSaveFailed.fromMap(json);
      case SinglePlayerStateType.SaveSuccessful:
        return SinglePlayerSaveSuccessful.fromMap(json);
      case SinglePlayerStateType.Saving:
        return SinglePlayerSaving.fromMap(json);
      default:
        return SinglePlayerUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(SinglePlayerState state) {
    return state.toMap();
  }
}
