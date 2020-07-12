import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../data/player.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddPlayerEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddPlayerEventCommit extends AddPlayerEvent {
  final Player newPlayer;

  AddPlayerEventCommit({@required this.newPlayer});

  @override
  List<Object> get props => [this.newPlayer];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddPlayerBloc extends Bloc<AddPlayerEvent, AddItemState> {
  final BasketballDatabase db;

  AddPlayerBloc({@required this.db}) : super(AddItemUninitialized());
  
  @override
  Stream<AddItemState> mapEventToState(AddPlayerEvent event) async* {
    // Create a new Player.
    if (event is AddPlayerEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addPlayer(player: event.newPlayer);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        print(e);
        print(s);
        Crashlytics.instance.recordError(e, s);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
