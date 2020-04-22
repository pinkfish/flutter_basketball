import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  InternalError,
  Cancelled,
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
/// Login as a google user with the google login process.
///
class LoginAsGoogleUser extends LoginEvent {
  @override
  List<Object> get props => [];
}

///
/// Login bloc handles the login flow.  Password, reset, etc,
///
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAnalytics analyticsSubsystem;
  final BasketballDatabase db;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
  );

  LoginBloc({@required this.analyticsSubsystem, @required this.db});

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
      var user = await FirebaseAuth.instance.currentUser();
      user.reload();
    }
    if (event is LoginEventLogout) {
      FirebaseAuth.instance.signOut();
    }
    if (event is LoginEventResendEmail) {
      var user = await FirebaseAuth.instance.currentUser();
      user.sendEmailVerification();
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
      } catch (error, stack) {
        print('Error: $error');
        Crashlytics.instance.recordError(error, stack);
        // Failed to login, probably bad password.
        yield LoginFailed(
            userData: signedIn, reason: LoginFailedReason.BadPassword);
      }

      if (signedIn != null) {
        analyticsSubsystem.logLogin(loginMethod: "UserPassword");
        var user = await FirebaseAuth.instance.currentUser();
        // Reload the user.
        user.reload();
        await db.addUser(
            user: User((b) => b
              ..uid = user.uid
              ..email = user.email
              ..name = user.displayName));
        if (!signedIn.isEmailVerified) {
          yield LoginEmailNotValidated(userData: signedIn);
        } else {
          yield LoginSucceeded(userData: signedIn);
        }
      }
    }

    if (event is LoginAsGoogleUser) {
      print("LOgin as google usder");
      yield LoginValidating();
      try {
        final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          AuthResult result =
              await FirebaseAuth.instance.signInWithCredential(credential);
          var user = result.user;
          assert(!user.isAnonymous);
          if (user != null) {
            assert(await user.getIdToken() != null);

            final FirebaseUser currentUser =
                await FirebaseAuth.instance.currentUser();
            assert(user.uid == currentUser.uid);
            await db.addUser(
                user: User((b) => b
                  ..uid = user.uid
                  ..email = user.email
                  ..name = user.displayName));

            print("Logged in as $user");
            analyticsSubsystem.logLogin(loginMethod: "GoogleUser");
            yield LoginSucceeded(userData: user);
          } else {
            print('Error: null usders...');

            yield LoginFailed(
                userData: null, reason: LoginFailedReason.BadPassword);
          }
        } else {
          yield LoginFailed(
              userData: null, reason: LoginFailedReason.Cancelled);
        }
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        print('Error: $error');
        if (error is PlatformException) {
          switch (error.code) {
            case 'concurrent-requests':
              _googleSignIn.disconnect();
              yield LoginFailed(
                  userData: null, reason: LoginFailedReason.InternalError);
              break;
            case 'sign_in_cancelled':
              yield LoginFailed(
                  userData: null, reason: LoginFailedReason.Cancelled);
              break;
            default:
              yield LoginFailed(
                  userData: null, reason: LoginFailedReason.InternalError);
              break;
          }
        } else {
          // Failed to login, probably bad password.
          yield LoginFailed(
              userData: null, reason: LoginFailedReason.InternalError);
        }
      }
    }

    if (event is LoginEventForgotPasswordSend) {
      yield LoginValidatingForgotPassword();
      analyticsSubsystem.logEvent(name: "ForgotPassword");
      LoginEventForgotPasswordSend forgot = event;
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: forgot.email);
        yield LoginForgotPasswordDone();
      } catch (error, stack) {
        Crashlytics.instance.recordError(error, stack);
        yield LoginForgotPasswordFailed(error: error);
      }
    }

    if (event is LoginEventSignupUser) {
      yield LoginValidatingSignup();
      LoginEventSignupUser signup = event;
      try {
        var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: signup.email, password: signup.password);
        if (result.user == null) {
          yield LoginSignupFailed(userData: result.user);
        } else {
          var update = UserUpdateInfo();
          update.displayName = signup.displayName;
          await result.user.updateProfile(update);
          await result.user.sendEmailVerification();
          yield LoginSignupSucceeded(userData: result.user);
          AuthResult newResult = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: signup.email, password: signup.password);
          // Put in the data into the basketball db too.
          await db.addUser(
              user: User((b) => b
                ..uid = newResult.user.uid
                ..email = newResult.user.email
                ..name = newResult.user.displayName));
          if (!newResult.user.isEmailVerified) {
            // Send a password verify email
            newResult.user.sendEmailVerification();
            yield LoginEmailNotValidated(userData: newResult.user);
          } else {
            yield LoginSucceeded(userData: newResult.user);
          }
        }
      } catch (error, stack) {
        print("Error $error");
        Crashlytics.instance.recordError(error, stack);
        yield LoginSignupFailed(userData: null);
      }
    }
  }
}
