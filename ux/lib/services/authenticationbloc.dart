import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

///
/// States for the authentication bloc.
///
abstract class AuthenticationState extends Equatable {
  final FirebaseUser user;

  AuthenticationState({@required this.user});

  @override
  List<Object> get props => [user?.email];
}

///
/// We are not setup yet, still waiting.
///
class AuthenticationUninitialized extends AuthenticationState {
  AuthenticationUninitialized() : super(user: null);

  @override
  String toString() => "AuthenticationState::AuthenticatonUninitialized";
}

///
/// The user is logged in.
///
class AuthenticationLoggedIn extends AuthenticationState {
  AuthenticationLoggedIn({@required FirebaseUser user}) : super(user: user);

  @override
  String toString() =>
      "AuthenticationState::AuthenticatonLoggedIn{${user.email}}";
}

///
/// The user is logged in, but unvierified.
///
class AuthenticationLoggedInUnverified extends AuthenticationState {
  AuthenticationLoggedInUnverified({@required FirebaseUser user})
      : super(user: user);

  @override
  String toString() => "AuthenticationLoggedInUnverified{${user.email})";
}

///
/// The user is logged out.
///
class AuthenticationLoggedOut extends AuthenticationState {
  AuthenticationLoggedOut() : super(user: null);

  @override
  String toString() => "AuthenticationState::AuthenticationLoggedOut";
}

///
/// Events associated with the authentication bloc
///
abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent() : super();
}

class _AuthenticationLogIn extends AuthenticationEvent {
  final FirebaseUser user;

  _AuthenticationLogIn({@required this.user});

  @override
  String toString() => "LoggedIn";

  @override
  List<Object> get props => [user];
}

///
/// Logs the current user out.
///
class _AuthenticationLogOut extends AuthenticationEvent {
  @override
  String toString() => "_AuthenticationLogOut";

  @override
  List<Object> get props => [];
}

///
/// This bloc deals with all the pieces related to authentication.
///
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAnalytics analyticsSubsystem;

  StreamSubscription<FirebaseUser> _listener;

  AuthenticationBloc({@required this.analyticsSubsystem})
      : super(AuthenticationUninitialized()) {
    FirebaseAuth.instance
        .currentUser()
        .then((FirebaseUser user) => _authChanged(user))
        .catchError((e) => _authChanged(null));
    _listener = FirebaseAuth.instance.onAuthStateChanged.listen(_authChanged);
  }

  @override
  Future<void> close() async {
    await super.close();
    _listener?.cancel();
  }

  FirebaseUser get currentUser {
    if (state is AuthenticationLoggedIn) {
      return (state as AuthenticationLoggedIn).user;
    }
    return null;
  }

  AuthenticationState _updateWithUser(FirebaseUser user) {
    if (user.isEmailVerified) {
      print("Verified user ${user.providerId ?? "frog"}");
      analyticsSubsystem.setUserId(user.uid);
      if (currentUser != null) {
        if (user == currentUser) {
          return null;
        }
      }
      return AuthenticationLoggedIn(user: user);
    } else {
      return AuthenticationLoggedInUnverified(user: user);
    }
  }

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is _AuthenticationLogIn) {
      _AuthenticationLogIn loggedInEvent = event;
      var state = _updateWithUser(loggedInEvent.user);
      if (state != null) {
        yield state;
      }
    }

    if (event is _AuthenticationLogOut) {
      try {
        if (await FirebaseAuth.instance.currentUser() != null) {
          await FirebaseAuth.instance
              .signOut()
              .timeout(Duration(milliseconds: 1000));
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
      }
      // Finished logging out.
      yield AuthenticationLoggedOut();
    }
  }

  void _authChanged(FirebaseUser user) async {
    print("Auth $user");
    if (user != null) {
      add(_AuthenticationLogIn(user: user));
    } else {
      if (state is AuthenticationLoggedIn ||
          state is AuthenticationLoggedInUnverified ||
          (kIsWeb && state is AuthenticationUninitialized)) {
        add(_AuthenticationLogOut());
      }
    }
  }
}
