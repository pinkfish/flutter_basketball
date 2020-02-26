import 'package:basketballstats/screens/addteam.dart';
import 'package:basketballstats/screens/teamdetails.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'screens/splashscreen.dart';
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
    router.define("/Team/:id",
        handler: Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamDetailsScreen(teamUid: vals["id"][0].toString())));

    return router;
  }
}
