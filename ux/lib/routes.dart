import 'package:basketballstats/screens/settings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'screens/gameadd.dart';
import 'screens/gamedetails.dart';
import 'screens/gamemediafromurladd.dart';
import 'screens/gamemediaphotoadd.dart';
import 'screens/gamemediastreamadd.dart';
import 'screens/gameplayerdetails.dart';
import 'screens/gamestats.dart';
import 'screens/gamevideo.dart';
import 'screens/gamevideoplayer.dart';
import 'screens/invites/acceptinvitetoteam.dart';
import 'screens/invites/invitelist.dart';
import 'screens/login/forgotpassword.dart';
import 'screens/login/loginform.dart';
import 'screens/login/signup.dart';
import 'screens/login/verifyemail.dart';
import 'screens/playerdetails.dart';
import 'screens/playeredit.dart';
import 'screens/seasonadd.dart';
import 'screens/splashscreen.dart';
import 'screens/teamadd.dart';
import 'screens/teamdetails.dart';
import 'screens/teamedit.dart';
import 'screens/teaminvite.dart';
import 'screens/teams.dart';
import 'screens/teamusers.dart';

///
/// Router for all the exciting routers in the app.
///
class BasketballAppRouter {
  static Router createRouter(Trace startTrace, FirebaseAnalytics analytics) {
    Router router = Router();
    router.define("/Home/Splash",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SplashScreen()));
    router.define("/Team/List", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Team/List");
      return TeamsScreen(startTrace);
    }));
    router.define("/Team/Add", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Team/Add");
      return AddTeamScreen();
    }));
    router.define("/Game/Add/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Team/Add", parameters: {"teamUid": vals["id"][0].toString()});
      return GameAddScreen(teamUid: vals["id"][0].toString());
    }));
    router.define("/Team/View/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Team/View",
          parameters: {"teamUid": vals["id"][0].toString()});
      return TeamDetailsScreen(teamUid: vals["id"][0].toString());
    }));
    router.define("/Team/Edit/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Team/Edit",
          parameters: {"teamUid": vals["id"][0].toString()});
      return TeamEditScreen(teamUid: vals["id"][0].toString());
    }));
    router.define("/Team/Invite/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Team/Invite",
          parameters: {"teamUid": vals["id"][0].toString()});
      return TeamInviteScreen(teamUid: vals["id"][0].toString());
    }));
    router.define("/Team/Users/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Team/Users",
          parameters: {"teamUid": vals["id"][0].toString()});
      return TeamUsersScreen(teamUid: vals["id"][0].toString());
    }));
    router.define("/Season/Add/:teamUid", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Season/Add",
          parameters: {"teamUid": vals["teamUid"][0].toString()});
      return AddSeasonScreen(vals["teamUid"][0].toString());
    }));
    router.define("/Game/View/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Game/View",
          parameters: {"gameUid": vals["id"][0].toString()});
      return GameDetailsScreen(vals["id"][0].toString());
    }));
    router.define("/Game/Video/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Game/Video",
          parameters: {"gameUid": vals["id"][0].toString()});
      return GameVideoListScreen(vals["id"][0].toString());
    }));
    router.define("/Player/View/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Player/View",
          parameters: {"playerUid": vals["id"][0].toString()});
      return PlayerDetailsScreen(vals["id"][0].toString());
    }));
    router.define("/Player/Edit/:id", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(
          name: "/Player/Edit",
          parameters: {"playerUid": vals["id"][0].toString()});
      return PlayerEditScreen(vals["id"][0].toString());
    }));
    router.define("/Game/Stats/:id/:season/:team", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Game/Stats", parameters: {
        "gameUid": vals["id"][0].toString(),
        "seasonUid": vals["season"][0].toString(),
        "teamUid": vals["team"][0].toString()
      });
      return GameStatsScreen(vals["id"][0].toString(),
          vals["season"][0].toString(), vals["team"][0].toString());
    }));
    router.define("/Game/Player/:game/:player", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Game/Player", parameters: {
        "gameUid": vals["game"][0].toString(),
        "playerUid": vals["player"][0].toString(),
      });
      return GamePlayerDetailsScreen(
          vals["game"][0].toString(), vals["player"][0].toString());
    }));
    router.define("/Media/Add/Url/:game", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Media/Add/Url", parameters: {
        "gameUid": vals["game"][0].toString(),
      });
      return AddMediaFromUrlGameScreen(vals["game"][0].toString());
    }));
    router.define("/Media/Add/Photo/:game", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Media/Add/Photo", parameters: {
        "gameUid": vals["game"][0].toString(),
      });
      return AddMediaPhotoGameScreen(vals["game"][0].toString());
    }));
    router.define("/Media/Add/Stream/:game", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Media/Add/Stream", parameters: {
        "gameUid": vals["game"][0].toString(),
      });
      return AddMediaStreamGameScreen(vals["game"][0].toString());
    }));
    router.define("/Game/Media/:game/:media", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Game/Media", parameters: {
        "gameUid": vals["game"][0].toString(),
        "mediaUid": vals["media"][0].toString(),
      });
      return GameVideoPlayerScreen(
          vals["game"][0].toString(), vals["media"][0].toString());
    }));
    router.define("/Invite/List", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Invite/List", parameters: {});
      return InviteListScreen();
    }));
    router.define("/Invite/AcceptInviteToTeam/:invite", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Invite/AcceptInviteToTeam", parameters: {
        "inviteUid": vals["invite"][0].toString(),
      });
      return AcceptInviteToTeamScreen(vals["invite"][0].toString());
    }));
    router.define("/Login/Home", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Login/Home", parameters: {});
      return LoginScreen();
    }));
    router.define("/Login/ForgotPassword", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Login/ForgotPassword", parameters: {});
      return ForgotPasswordScreen();
    }));
    router.define("/Login/SignUp", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Login/SignUp", parameters: {});
      return SignupScreen();
    }));
    router.define("/Login/Verify", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Login/Verify", parameters: {});
      return VerifyEmailScreen();
    }));

    router.define("/Settings", handler:
        Handler(handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      analytics.logEvent(name: "/Settings", parameters: {});
      return SettingsScreen();
    }));

    //router.notFoundHandler = Handler(
    //    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    //  analytics.logEvent(name: "RouteNotFound", parameters: params);
    //  print("ROUTE WAS NOT FOUND !!! $params");
    //  return null;
    //});

    return router;
  }
}
