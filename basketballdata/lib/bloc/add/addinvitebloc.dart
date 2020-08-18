import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/invites/invite.dart';
import '../../db/basketballdatabase.dart';
import '../crashreporting.dart';
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
  final CrashReporting crashes;

  AddInviteBloc({@required this.db, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddInviteEvent event) async* {
    // Create a new Player.
    if (event is AddInviteCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addInvite(invite: event.newInvite);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        crashes.recordError(e, s);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
