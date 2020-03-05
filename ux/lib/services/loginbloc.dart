import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

///
/// Basic login state
///
abstract class LoginState extends Equatable {
  LoginState();
}

///
/// Initial state (showing the login form)
///
class LoginInitial extends LoginState {
  @override
  String toString() {
    return 'LoginInitial{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Validating the login
///
class LoginValidating extends LoginState {
  @override
  String toString() {
    return 'LoginValidating{}';
  }

  @override
  List<Object> get props => [];
}

enum LoginFailedReason {
  BadPassword,
}

///
/// The login failed.
///
class LoginFailed extends LoginState {
  final FirebaseUser userData;
  final LoginFailedReason reason;

  LoginFailed({@required this.userData, @required this.reason});

  @override
  String toString() {
    return 'LoginFailed{}';
  }

  @override
  List<Object> get props => [userData, reason];
}

///
/// The login succeeded.
///
class LoginSucceeded extends LoginState {
  final FirebaseUser userData;

  LoginSucceeded({@required this.userData});

  @override
  String toString() {
    return 'LoginSucceeded{}';
  }

  @override
  List<Object> get props => [userData];
}

///
/// The login succeeded.
///
class LoginEmailNotValidated extends LoginState {
  final FirebaseUser userData;

  LoginEmailNotValidated({@required this.userData});

  @override
  String toString() {
    return 'LoginEmailNotValidated{}';
  }

  @override
  List<Object> get props => [userData];
}

///
/// Validating the forgot password request
///
class LoginValidatingForgotPassword extends LoginState {
  @override
  String toString() {
    return 'LoginValidatingForgotPassword{}';
  }

  @override
  List<Object> get props => [];
}

///
/// The forgot password flow is done.
///
class LoginForgotPasswordDone extends LoginState {
  @override
  String toString() {
    return 'LoginForgotPasswordDone{}';
  }

  @override
  List<Object> get props => [];
}

///
/// The forgot password attempt failed
///
class LoginForgotPasswordFailed extends LoginState {
  final Error error;

  LoginForgotPasswordFailed({@required this.error});

  @override
  String toString() {
    return 'LoginForgotPasswordDone{}';
  }

  @override
  List<Object> get props => [error];
}

///
/// The forgot password flow is done.
///
class LoginVerificationDone extends LoginState {
  @override
  String toString() {
    return 'LoginVerificationDone{}';
  }

  @override
  List<Object> get props => [];
}

///
/// The forgot password attempt failed
///
class LoginVerificationFailed extends LoginState {
  final Error error;

  LoginVerificationFailed({@required this.error});

  @override
  String toString() {
    return 'LoginVerificationFailed{}';
  }

  @override
  List<Object> get props => [error];
}

///
/// Validating the signup flow.
///
class LoginValidatingSignup extends LoginState {
  @override
  String toString() {
    return 'LoginValidatingSignup{}';
  }

  @override
  List<Object> get props => [];
}

///
/// The signup attempt failed.
///
class LoginSignupFailed extends LoginState {
  final FirebaseUser userData;

  LoginSignupFailed({@required this.userData});

  @override
  String toString() {
    return 'LoginSignupFailed{}';
  }

  @override
  List<Object> get props => [userData];
}

///
/// The signup attempt was successeful
///
class LoginSignupSucceeded extends LoginState {
  final FirebaseUser userData;

  LoginSignupSucceeded({@required this.userData});

  @override
  String toString() {
    return 'LoginSignupSucceeded{}';
  }

  @override
  List<Object> get props => [userData];
}

abstract class LoginEvent extends Equatable {}

///
/// Reset the state of the login system
///
class LoginEventReset extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventReset{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Reloads the user to correct state
///
class LoginEventReload extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventReset{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Logs  the user to out
///
class LoginEventLogout extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventLogout{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Resends an email to the user.
///
class LoginEventResendEmail extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventResendEmail{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Sends a login attempt request.
///
class LoginEventAttempt extends LoginEvent {
  final String email;
  final String password;

  LoginEventAttempt({@required this.email, @required this.password});

  @override
  String toString() {
    return 'LoginEventAttempt{user: $email}';
  }

  @override
  List<Object> get props => [email, password];
}

///
/// Sends a forgot password request.
///
class LoginEventForgotPasswordSend extends LoginEvent {
  final String email;

  LoginEventForgotPasswordSend({@required this.email});

  @override
  String toString() {
    return 'LoginEventForgotPassword{user: $email}';
  }

  @override
  List<Object> get props => [email];
}

///
/// Requests signing up the user.
///
class LoginEventSignupUser extends LoginEvent {
  final String email;
  final String password;
  final String displayName;
  final String phoneNumber;

  LoginEventSignupUser(
      {@required this.email,
      @required this.password,
      @required this.displayName,
      @required this.phoneNumber});

  @override
  String toString() {
    return 'LoginEventSignupUser{user: $email}';
  }

  @override
  List<Object> get props => [email, password, displayName, phoneNumber];
}

///
/// Login bloc handles the login flow.  Password, reset, etc,
///
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseUser userAuth;
  final FirebaseAnalytics analyticsSubsystem;

  LoginBloc({@required this.userAuth, @required this.analyticsSubsystem});

  @override
  LoginState get initialState {
    return new LoginInitial();
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEventReset) {
      yield LoginInitial();
    }
    if (event is LoginEventReload) {
      userAuth.reload();
    }
    if (event is LoginEventLogout) {
      FirebaseAuth.instance.signOut();
    }
    if (event is LoginEventResendEmail) {
      userAuth.sendEmailVerification();
    }
    if (event is LoginEventAttempt) {
      yield LoginValidating();
      LoginEventAttempt attempt = event;
      FirebaseUser signedIn;
      try {
        var result = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: attempt.email, password: attempt.password);
        print(result);
        if (result.user != null) {
          signedIn = result.user;
        }
      } catch (error) {
        print('Error: ${error}');
        // Failed to login, probably bad password.
        yield LoginFailed(
            userData: signedIn, reason: LoginFailedReason.BadPassword);
      }

      if (signedIn != null) {
        analyticsSubsystem.logLogin();
        // Reload the user.
        userAuth.reload();
        yield LoginSucceeded(userData: signedIn);
      }
    }
    if (event is LoginEventForgotPasswordSend) {
      yield LoginValidatingForgotPassword();

      LoginEventForgotPasswordSend forgot = event;
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: forgot.email);
        yield LoginForgotPasswordDone();
      } catch (error) {
        yield LoginForgotPasswordFailed(error: error);
      }
    }
    if (event is LoginEventSignupUser) {
      yield LoginValidatingSignup();
      LoginEventSignupUser signup = event;
      /*
       FusedUserProfile profile = new FusedUserProfile((b) => b
        ..displayName = signup.displayName
        ..phoneNumber = signup.phoneNumber
        ..email = signup.email
        ..emailOnUpdates = true
        ..emailUpcomingGame = true
        ..notifyOnlyForGames = true);
      UserData data = await userAuth.createUser(user, profile);*/
      var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signup.email, password: signup.password);
      if (result.user == null) {
        yield LoginSignupFailed(userData: result.user);
      } else {
        var update = UserUpdateInfo();
        update.displayName = signup.displayName;
        result.user.updateProfile(update);
        yield LoginSignupSucceeded(userData: result.user);
      }
    }
  }
}
