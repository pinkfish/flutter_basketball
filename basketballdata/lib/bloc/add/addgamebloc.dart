import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/game/game.dart';
import '../../data/player/player.dart';
import '../../db/basketballdatabase.dart';
import '../crashreporting.dart';
import 'additemstate.dart';

abstract class AddGameEvent extends Equatable {}

///
/// Adds this game into the set of games.
///
class AddGameEventCommit extends AddGameEvent {
  final Game newGame;
  final BuiltList<Player> guestPlayers;

  AddGameEventCommit({@required this.newGame, this.guestPlayers});

  @override
  List<Object> get props => [this.newGame, this.guestPlayers];
}

///
/// Deals with specific games to allow for accepting/deleting/etc of the
/// games.
///
class AddGameBloc extends Bloc<AddGameEvent, AddItemState> {
  final BasketballDatabase db;
  final String teamUid;
  final CrashReporting crashes;

  AddGameBloc(
      {@required this.db, @required this.teamUid, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddGameEvent event) async* {
    // Create a new Game.
    if (event is AddGameEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addGame(
            game: event.newGame.rebuild((b) => b.teamUid = this.teamUid),
            guestPlayers: event.guestPlayers);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        crashes.recordError(e, s);
        yield AddItemSaveFailed(error: e);
        yield AddItemUninitialized();
      }
    }
  }
}
