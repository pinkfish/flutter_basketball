import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'screens/addgame.dart';
import 'screens/addteam.dart';
import 'screens/editplayer.dart';
import 'screens/gamedetails.dart';
import 'screens/gameplayerdetails.dart';
import 'screens/gamestats.dart';
import 'screens/login/forgotpassword.dart';
import 'screens/login/loginform.dart';
import 'screens/login/signup.dart';
import 'screens/login/verifyemail.dart';
import 'screens/playerdetails.dart';
import 'screens/splashscreen.dart';
import 'screens/teamdetails.dart';
import 'screens/teams.dart';

///
/// Router for all the exciting routers in the app.
///
class AppRouter {
  static Router myRouter;

  static Router get instance {
    if (myRouter == null) {
      myRouter = _setupRoutes();
    }
    return myRouter;
  }

  static Router _setupRoutes() {
    Router router = Router();
    router.define("/Home",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SplashScreen()));
    router.define("/Teams",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamsScreen()));
    router.define("/AddTeam",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddTeamScreen()));
    router.define("/AddGame/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddGameScreen(seasonUid: vals["id"][0].toString())));
    router.define("/Team/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamDetailsScreen(teamUid: vals["id"][0].toString())));
    router.define("/Game/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameDetailsScreen(vals["id"][0].toString())));
    router.define("/Player/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                PlayerDetailsScreen(vals["id"][0].toString())));
    router.define("/EditPlayer/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditPlayerScreen(vals["id"][0].toString())));
    router.define("/GameStats/:id/:season/:team",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameStatsScreen(vals["id"][0].toString(),
                    vals["season"][0].toString(), vals["team"][0].toString())));
    router.define("/GamePlayer/:game/:player",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GamePlayerDetailsScreen(
                    vals["game"][0].toString(), vals["player"][0].toString())));
    router.define("/Login/Home",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                LoginScreen()));
    router.define("/Login/ForgotPassword",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                ForgotPasswordScreen()));
    router.define("/Login/SignUp",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SignupScreen()));
    router.define("/Login/Verify",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                VerifyEmailScreen()));

    return router;
  }
}
