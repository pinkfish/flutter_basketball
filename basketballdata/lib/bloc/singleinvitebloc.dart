import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/team/teamuser.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../data/invites/invite.dart';
import '../data/season/season.dart';

abstract class SingleInviteBlocState extends Equatable {
  final Invite invite;

  SingleInviteBlocState({@required this.invite});

  @override
  List<Object> get props => [invite];
}

///
/// We have a invite, default state.
///
class SingleInviteLoaded extends SingleInviteBlocState {
  SingleInviteLoaded(
      {@required SingleInviteBlocState state,
      Invite invite,
      BuiltList<Season> seasons,
      bool loadedSeasons})
      : super(
          invite: invite ?? state.invite,
        );

  @override
  String toString() {
    return 'SingleInviteLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleInviteSaving extends SingleInviteBlocState {
  SingleInviteSaving({@required SingleInviteBlocState singleInviteState})
      : super(
          invite: singleInviteState.invite,
        );

  @override
  String toString() {
    return 'SingleInviteSaving{}';
  }
}

///
/// Saving operation is successful.
///
class SingleInviteSaveSuccessful extends SingleInviteBlocState {
  SingleInviteSaveSuccessful(
      {@required SingleInviteBlocState singleInviteState})
      : super(
          invite: singleInviteState.invite,
        );

  @override
  String toString() {
    return 'SingleInviteSaveSuccessful{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleInviteSaveFailed extends SingleInviteBlocState {
  final Error error;

  SingleInviteSaveFailed(
      {@required SingleInviteBlocState singleInviteState, this.error})
      : super(invite: singleInviteState.invite);

  @override
  String toString() {
    return 'SingleInviteSaveFailed{}';
  }
}

///
/// Invite got deleted.
///
class SingleInviteDeleted extends SingleInviteBlocState {
  SingleInviteDeleted() : super(invite: null);

  @override
  String toString() {
    return 'SingleInviteDeleted{}';
  }
}

///
/// Invite is still loading.
///
class SingleInviteUninitialized extends SingleInviteBlocState {
  SingleInviteUninitialized() : super(invite: null);

  @override
  String toString() {
    return 'SingleInviteUninitialized{}';
  }
}

abstract class SingleInviteEvent extends Equatable {}

///
/// Delete this invite from the world.
///
class SingleInviteDelete extends SingleInviteEvent {
  SingleInviteDelete();

  @override
  List<Object> get props => [];
}

///
/// Accept this invite and do whatever than means in acceptance.
///
class SingleInviteEventAcceptInviteToTeam extends SingleInviteEvent {
  SingleInviteEventAcceptInviteToTeam();

  @override
  List<Object> get props => [];
}

class _SingleInviteNewInvite extends SingleInviteEvent {
  final Invite newInvite;

  _SingleInviteNewInvite({@required this.newInvite});

  @override
  List<Object> get props => [newInvite];
}

class _SingleInviteDeleted extends SingleInviteEvent {
  _SingleInviteDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific invite.
///
class SingleInviteBloc extends Bloc<SingleInviteEvent, SingleInviteBlocState> {
  final BasketballDatabase db;
  final String inviteUid;

  StreamSubscription<Invite> _inviteSub;
  StreamSubscription<BuiltList<Season>> _seasonSub;

  SingleInviteBloc({@required this.db, @required this.inviteUid})
      : super(SingleInviteUninitialized()) {
    _inviteSub = db.getInvite(inviteUid: inviteUid).listen((Invite t) {
      if (t != null) {
        // Only send this if the invite is not the same.
        if (t != state.invite || !(state is SingleInviteLoaded)) {
          add(_SingleInviteNewInvite(newInvite: t));
        }
      } else {
        add(_SingleInviteDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    _inviteSub?.cancel();
    _seasonSub?.cancel();
    await super.close();
  }

  @override
  Stream<SingleInviteBlocState> mapEventToState(
      SingleInviteEvent event) async* {
    if (event is _SingleInviteNewInvite) {
      yield SingleInviteLoaded(state: state, invite: event.newInvite);
    }

    // The invite is deleted.
    if (event is _SingleInviteDeleted) {
      yield SingleInviteDeleted();
    }

    // Save the invite.
    if (event is SingleInviteDelete) {
      yield SingleInviteSaving(singleInviteState: state);
      try {
        await db.deleteInvite(inviteUid: inviteUid);
        // This will get overridden by the loaded event right afterwards.
        yield SingleInviteSaveSuccessful(singleInviteState: state);
        yield SingleInviteLoaded(state: state, invite: state.invite);
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleInviteSaveFailed(singleInviteState: state, error: error);
        yield SingleInviteLoaded(state: state, invite: state.invite);
      }
    }

    /// Add the user into the invite stuff.
    if (event is SingleInviteEventAcceptInviteToTeam) {
      try {
        if (state.invite is InviteToTeam) {
          yield SingleInviteSaving(singleInviteState: state);
          InviteToTeam i = state.invite as InviteToTeam;
          var s = db.getTeam(teamUid: i.teamUid);
          var t = (await s.first).toBuilder();
          t.users[db.userUid] = TeamUser((b) => b..enabled = true);
          db.updateTeam(team: t.build());
          yield SingleInviteSaveSuccessful(singleInviteState: state);
          yield SingleInviteLoaded(state: state, invite: state.invite);
        } else {
          var error = ArgumentError("invite not InviteToTeam");
          yield SingleInviteSaveFailed(singleInviteState: state, error: error);
          yield SingleInviteLoaded(state: state, invite: state.invite);
          Crashlytics.instance.recordError(error, StackTrace.current);
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleInviteSaveFailed(singleInviteState: state, error: error);
        yield SingleInviteLoaded(state: state, invite: state.invite);
      }
    }

    if (event is SingleInviteDelete) {
      yield SingleInviteSaving(singleInviteState: state);
      try {
        await db.deleteInvite(inviteUid: inviteUid);
        yield SingleInviteSaveSuccessful(singleInviteState: state);
        yield SingleInviteLoaded(state: state, invite: state.invite);
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleInviteSaveFailed(singleInviteState: state, error: error);
        yield SingleInviteLoaded(state: state, invite: state.invite);
      }
    }
  }
}
