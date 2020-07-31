import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../data/invites/invite.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddInviteEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddInviteCommit extends AddInviteEvent {
  final Invite newInvite;

  AddInviteCommit({@required this.newInvite});

  @override
  List<Object> get props => [this.newInvite];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddInviteBloc extends Bloc<AddInviteEvent, AddItemState> {
  final BasketballDatabase db;

  AddInviteBloc({@required this.db}) : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddInviteEvent event) async* {
    // Create a new Player.
    if (event is AddInviteCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addInvite(invite: event.newInvite);
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
