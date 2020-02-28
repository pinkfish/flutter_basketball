import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../data/player.dart';

abstract class SinglePlayerState extends Equatable {
  final Player player;

  SinglePlayerState({@required this.player});

  @override
  List<Object> get props => [player];
}

///
/// We have a player, default state.
///
class SinglePlayerLoaded extends SinglePlayerState {
  SinglePlayerLoaded({@required Player player}) : super(player: player);

  @override
  String toString() {
    return 'SinglePlayerLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SinglePlayerSaving extends SinglePlayerState {
  SinglePlayerSaving({@required SinglePlayerState singlePlayerState})
      : super(player: singlePlayerState.player);

  @override
  String toString() {
    return 'SinglePlayerSaving{}';
  }
}

///
/// Save operation was successful.
///
class SinglePlayerSaveSuccessful extends SinglePlayerState {
  SinglePlayerSaveSuccessful({@required SinglePlayerState singlePlayerState})
      : super(player: singlePlayerState.player);

  @override
  String toString() {
    return 'SinglePlayerSaveSuccessful{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SinglePlayerSaveFailed extends SinglePlayerState {
  final Error error;

  SinglePlayerSaveFailed(
      {@required SinglePlayerState singlePlayerState, this.error})
      : super(player: singlePlayerState.player);

  @override
  String toString() {
    return 'SinglePlayerSaveFailed{}';
  }
}

///
/// Player got deleted.
///
class SinglePlayerDeleted extends SinglePlayerState {
  SinglePlayerDeleted() : super(player: null);

  @override
  String toString() {
    return 'SinglePlayerDeleted{}';
  }
}

///
/// What the system has not yet read the player state.
///
class SinglePlayerUninitialized extends SinglePlayerState {
  SinglePlayerUninitialized() : super(player: null);
}

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

class _SinglePlayerNewPlayer extends SinglePlayerEvent {
  final Player newPlayer;

  _SinglePlayerNewPlayer({@required this.newPlayer});

  @override
  List<Object> get props => [newPlayer];
}

class _SinglePlayerDeleted extends SinglePlayerEvent {
  _SinglePlayerDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific player.
///
class SinglePlayerBloc extends Bloc<SinglePlayerEvent, SinglePlayerState> {
  final String playerUid;
  final BasketballDatabase db;

  StreamSubscription<Player> _playerSub;

  SinglePlayerBloc({@required this.db, @required this.playerUid}) {
    _playerSub = db.getPlayer(playerUid: playerUid).listen(_onPlayerUpdate);
  }

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
    await super.close();
  }

  @override
  SinglePlayerState get initialState {
    return SinglePlayerUninitialized();
  }

  @override
  Stream<SinglePlayerState> mapEventToState(SinglePlayerEvent event) async* {
    if (event is _SinglePlayerNewPlayer) {
      yield SinglePlayerLoaded(player: event.newPlayer);
    }

    // The player is deleted.
    if (event is _SinglePlayerDeleted) {
      yield SinglePlayerDeleted();
    }

    if (event is SinglePlayerDelete) {
      yield SinglePlayerSaving(singlePlayerState: state);
      try {
        Player player = state.player;
        await db.deletePlayer(playerUid: player.uid);
        yield SinglePlayerDeleted();
      } catch (e) {
        yield SinglePlayerSaveFailed(singlePlayerState: state, error: e);
      }
    }

    // Save the player.
    if (event is SinglePlayerUpdate) {
      yield SinglePlayerSaving(singlePlayerState: state);
      try {
        Player player = event.player;
        await db.updatePlayer(player: player);
        yield SinglePlayerSaveSuccessful(singlePlayerState: state);
      } catch (e) {
        yield SinglePlayerSaveFailed(singlePlayerState: state, error: e);
      }
    }
  }
}
