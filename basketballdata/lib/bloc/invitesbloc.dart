import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../data/invites/invite.dart';
import 'data/invitesstate.dart';

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
class InvitesBloc extends HydratedBloc<InvitesBlocEvent, InvitesBlocState> {
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
      yield InvitesBlocLoaded((b) => b..invites = event.invites.toBuilder());
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _sub = null;
    _dbChange?.cancel();
    _dbChange = null;
    return super.close();
  }

  @override
  InvitesBlocState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return InvitesBlocUninitialized();
    }
    InvitesBlocStateType type = InvitesBlocStateType.valueOf(json["type"]);
    switch (type) {
      case InvitesBlocStateType.Uninitialized:
        return InvitesBlocUninitialized();
      case InvitesBlocStateType.Loaded:
        return InvitesBlocLoaded.fromMap(json);
      default:
        return InvitesBlocUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(InvitesBlocState state) {
    return state.toMap();
  }
}
