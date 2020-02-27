import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'screens/addgame.dart';
import 'screens/addplayer.dart';
import 'screens/addteam.dart';
import 'screens/gamedetails.dart';
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
                AddGameScreen(teamUid: vals["id"][0].toString())));
    router.define("/AddPlayer",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddPlayerScreen()));
    router.define("/Team/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamDetailsScreen(teamUid: vals["id"][0].toString())));
    router.define("/Game/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                GameDetailsScreen(vals["id"][0].toString())));

    return router;
  }
}
