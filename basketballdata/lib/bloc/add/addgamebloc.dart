import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/game.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddGameEvent extends Equatable {}

///
/// Adds this game into the set of games.
///
class AddGameEventCommit extends AddGameEvent {
  final Game newGame;

  AddGameEventCommit({@required this.newGame});

  @override
  List<Object> get props => [this.newGame];
}

///
/// Deals with specific games to allow for accepting/deleting/etc of the
/// games.
///
class AddGameBloc extends Bloc<AddGameEvent, AddItemState> {
  final BasketballDatabase db;
  final String seasonUid;
  final String teamUid;

  AddGameBloc(
      {@required this.db, @required this.seasonUid, @required this.teamUid});

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddGameEvent event) async* {
    // Create a new Game.
    if (event is AddGameEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addGame(
            game: event.newGame.rebuild((b) => b.seasonUid = this.seasonUid));
        yield AddItemDone(uid: uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
