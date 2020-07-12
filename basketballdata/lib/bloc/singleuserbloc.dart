import 'dart:async';

import 'package:basketballdata/data/user.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

///
/// The basic data for the user and all the data associated with it.
///
abstract class SingleUserState extends Equatable {
  final User user;

  SingleUserState({@required this.user});

  @override
  List<Object> get props => [user];
}

///
/// We have a user, default state.
///
class SingleUserLoaded extends SingleUserState {
  SingleUserLoaded({User user, SingleUserState state})
      : super(user: user ?? state.user);

  @override
  String toString() {
    return 'SingleUserLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleUserSaving extends SingleUserState {
  SingleUserSaving({@required SingleUserState singleUserState})
      : super(user: singleUserState.user);

  @override
  String toString() {
    return 'SingleUserSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleUserSaveFailed extends SingleUserState {
  final Error error;

  SingleUserSaveFailed({@required SingleUserState singleUserState, this.error})
      : super(user: singleUserState.user);

  @override
  String toString() {
    return 'SingleUserSaveFailed{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleUserSaveSuccessful extends SingleUserState {
  SingleUserSaveSuccessful({@required SingleUserState singleUserState})
      : super(user: singleUserState.user);

  @override
  String toString() {
    return 'SingleUserSaveFailed{}';
  }
}

///
/// User got deleted.
///
class SingleUserDeleted extends SingleUserState {
  SingleUserDeleted() : super(user: null);

  @override
  String toString() {
    return 'SingleUserDeleted{}';
  }
}

///
/// What the system has not yet read the user state.
///
class SingleUserUninitialized extends SingleUserState {
  SingleUserUninitialized() : super(user: null);
}

abstract class SingleUserEvent extends Equatable {}

///
/// Updates the user (writes it out to firebase.
///
class SingleUserUpdate extends SingleUserEvent {
  final User user;

  SingleUserUpdate({@required this.user});

  @override
  List<Object> get props => [user];
}

class _SingleUserNewUser extends SingleUserEvent {
  final User newUser;

  _SingleUserNewUser({@required this.newUser});

  @override
  List<Object> get props => [newUser];
}

class _SingleUserDeleted extends SingleUserEvent {
  _SingleUserDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific user.
///
class SingleUserBloc extends Bloc<SingleUserEvent, SingleUserState> {
  final String userUid;
  final BasketballDatabase db;

  StreamSubscription<User> _userSub;

  SingleUserBloc({@required this.db, @required this.userUid}) : super(SingleUserUninitialized()) {
    _userSub = db.getUser(userUid: userUid).listen(_onUserUpdate);
  }

  void _onUserUpdate(User g) {
    if (g != this.state.user) {
      if (g != null) {
        add(_SingleUserNewUser(newUser: g));
      } else {
        add(_SingleUserDeleted());
      }
    }
  }

  @override
  Future<void> close() async {
    _userSub?.cancel();
    _userSub = null;
    await super.close();
  }

  @override
  Stream<SingleUserState> mapEventToState(SingleUserEvent event) async* {
    if (event is _SingleUserNewUser) {
      yield SingleUserLoaded(user: event.newUser, state: state);
    }

    if (event is _SingleUserDeleted) {
      yield SingleUserDeleted();
    }

    // Save the user.
    if (event is SingleUserUpdate) {
      yield SingleUserSaving(singleUserState: state);
      try {
        await db.updateUser(user: event.user);
        yield SingleUserSaveSuccessful(singleUserState: state);
        yield SingleUserLoaded(user: event.user, state: state);
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield SingleUserSaveFailed(singleUserState: state, error: error);
      }
    }
  }
}
