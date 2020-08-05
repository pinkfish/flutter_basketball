import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// Splash screen to show nice splashing while we startup.
///
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Splash!");
    if (kIsWeb &&
        !(BlocProvider.of<AuthenticationBloc>(context).state
            is AuthenticationLoggedIn)) {
      print("Listen! ${BlocProvider.of<AuthenticationBloc>(context).state}");
      return BlocListener(
        cubit: BlocProvider.of<AuthenticationBloc>(context),
        listener: (BuildContext context, AuthenticationState state) {
          print("Blocs of stuff $state");
          if (state is AuthenticationLoggedInUnverified) {
            Navigator.popAndPushNamed(context, "/Login/Verify");
          }
          if (state is AuthenticationLoggedOut) {
            Navigator.popAndPushNamed(context, "/Login/Home");
          }
          if (state is AuthenticationLoggedIn) {
            print("Team list");
            Navigator.popAndPushNamed(context, "/Team/List");
          }
        },
        listenWhen: (AuthenticationState old, AuthenticationState fluff) {
          print("listenWhen $old $fluff");
        },
        child: _buildScaffold(context),
      );
    } else {
      print("Wait for teams");
      return BlocListener(
        cubit: BlocProvider.of<TeamsBloc>(context),
        listener: (BuildContext context, TeamsBlocState state) {
          if (state is TeamsBlocLoaded) {
            Navigator.popAndPushNamed(context, "/Team/List");
          }
        },
        child: _buildScaffold(context),
      );
    }
  }

  Widget _buildScaffold(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).titleOfApp),
      ),
      body: Container(
        padding: new EdgeInsets.all(16.0),
        //decoration: new BoxDecoration(image: backgroundImage),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                      child: new Image(
                    image:
                        new ExactAssetImage("assets/images/abstractsport.png"),
                    width: (screenSize.width < 500)
                        ? 120.0
                        : (screenSize.width / 4) + 12.0,
                    height: screenSize.height / 4 + 20,
                  ))
                ],
              ),
            ),
            new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(),
                  new Text(Messages.of(context).loadingText),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
