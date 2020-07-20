import 'package:basketballstats/screens/addmediafromurl.dart';
import 'package:basketballstats/screens/addmediaphoto.dart';
import 'package:basketballstats/screens/addmediastream.dart';
import 'package:basketballstats/screens/gamevideoplayer.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'screens/addgame.dart';
import 'screens/addteam.dart';
import 'screens/editplayer.dart';
import 'screens/gamedetails.dart';
import 'screens/gameplayerdetails.dart';
import 'screens/gamestats.dart';
import 'screens/gamevideo.dart';
import 'screens/invites/acceptinvitetoteam.dart';
import 'screens/invites/invitelist.dart';
import 'screens/login/forgotpassword.dart';
import 'screens/login/loginform.dart';
import 'screens/login/signup.dart';
import 'screens/login/verifyemail.dart';
import 'screens/playerdetails.dart';
import 'screens/splashscreen.dart';
import 'screens/teamdetails.dart';
import 'screens/teamedit.dart';
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
    router.define("/Home/Splash",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SplashScreen()));
    router.define("/Team/List",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamsScreen()));
    router.define("/Team/Add",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddTeamScreen()));
    router.define("/Game/Add/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddGameScreen(seasonUid: vals["id"][0].toString())));
    router.define("/Team/View/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamDetailsScreen(teamUid: vals["id"][0].toString())));
    router.define("/Team/Edit/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamEditScreen(teamUid: vals["id"][0].toString())));
    router.define("/Game/View/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameDetailsScreen(vals["id"][0].toString())));
    router.define("/Game/Video/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameVideoListScreen(vals["id"][0].toString())));
    router.define("/Player/View/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                PlayerDetailsScreen(vals["id"][0].toString())));
    router.define("/Player/Edit/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditPlayerScreen(vals["id"][0].toString())));
    router.define("/Game/Stats/:id/:season/:team",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameStatsScreen(vals["id"][0].toString(),
                    vals["season"][0].toString(), vals["team"][0].toString())));
    router.define("/Game/Player/:game/:player",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GamePlayerDetailsScreen(
                    vals["game"][0].toString(), vals["player"][0].toString())));
    router.define("/Media/Add/Url/:game",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMediaFromUrlGameScreen(vals["game"][0].toString())));
    router.define("/Media/Add/Photo/:game",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMediaPhotoGameScreen(vals["game"][0].toString())));
    router.define("/Media/Add/Stream/:game",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMediaStreamGameScreen(vals["game"][0].toString())));
    router.define("/Game/Media/:game/:media",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameVideoPlayerScreen(
                    vals["game"][0].toString(), vals["media"][0].toString())));
    router.define("/Invite/List",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                InviteListScreen()));
    router.define("/Invite/AcceptInviteToTeam/:invite",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToTeamScreen(vals["invite"][0].toString())));
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
