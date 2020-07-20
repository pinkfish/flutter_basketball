import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../data/invites/invite.dart';

///
/// The base state for the invites bloc.  It tracks all the
/// exciting invites stuff.
///
abstract class InvitesBlocState extends Equatable {
  final BuiltList<Invite> invites;

  InvitesBlocState({@required this.invites});

  @override
  List<Object> get props => [invites];
}

///
/// The invites loaded from the database.
///
class InvitesBlocLoaded extends InvitesBlocState {
  InvitesBlocLoaded(
      {@required InvitesBlocState state, @required BuiltList<Invite> invites})
      : super(invites: invites);
}

///
/// The invites bloc that is unitialized.
///
class InvitesBlocUninitialized extends InvitesBlocState {}

///
/// Updates all the invites in the invites bloc.
///
class _InvitesBlocUpdateInvites extends InvitesBlocEvent {
  final BuiltList<Invite> invites;

  _InvitesBlocUpdateInvites({this.invites});

  @override
  List<Object> get props => [this.invites];
}

///
/// The base class for all the events in the invites bloc.
///
abstract class InvitesBlocEvent extends Equatable {}

///
/// The bloc for dealing with all the invites.
///
class InvitesBloc extends Bloc<InvitesBlocEvent, InvitesBlocState> {
  final BasketballDatabase db;
  final String email;
  StreamSubscription<BuiltList<Invite>> _sub;
  StreamSubscription<bool> _dbChange;

  InvitesBloc({this.db, this.email}) : super(InvitesBlocUninitialized()) {
    _sub = db.getAllInvites(email).listen((BuiltList<Invite> invite) =>
        add(_InvitesBlocUpdateInvites(invites: invite)));
  }

  @override
  Stream<InvitesBlocState> mapEventToState(InvitesBlocEvent event) async* {
    if (event is _InvitesBlocUpdateInvites) {
      yield InvitesBlocLoaded(state: state, invites: event.invites);
    }
  }

  @override
  Future<Function> close() {
    _sub?.cancel();
    _sub = null;
    _dbChange?.cancel();
    _dbChange = null;
    return super.close();
  }
}
