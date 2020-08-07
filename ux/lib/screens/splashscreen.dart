import 'dart:async';

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
      return BlocBuilder(
        cubit: BlocProvider.of<AuthenticationBloc>(context),
        builder: (BuildContext context, AuthenticationState state) {
          print("Blocs of stuff $state");
          if (state is AuthenticationLoggedInUnverified) {
            Timer(Duration(milliseconds: 50),
                () => Navigator.popAndPushNamed(context, "/Login/Verify"));
          }
          if (state is AuthenticationLoggedOut) {
            Timer(Duration(milliseconds: 50),
                () => Navigator.popAndPushNamed(context, "/Login/Home"));
          }
          if (state is AuthenticationLoggedIn) {
            print("Team list");
            Timer(Duration(milliseconds: 50),
                () => Navigator.popAndPushNamed(context, "/Team/List"));
          }
          return _buildScaffold(context);
        },
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
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).titleOfApp),
      ),
      body: Container(
        padding: new EdgeInsets.all(16.0),
        //decoration: new BoxDecoration(image: backgroundImage),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
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
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text(Messages.of(context).loadingText),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Text(buildDateOfDart.toString(),
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
