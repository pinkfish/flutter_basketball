import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/services/loginbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';

///
/// Shows a nice drawer for the app.  Yay!
///
class StatsDrawer extends StatelessWidget {
  StatsDrawer();

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.body1;
    final List<Widget> aboutBoxChildren = <Widget>[
      SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: 'Basketball stats is an exciting sapp to show stats'
                    'about basketball games.  It shows nifty graphs and fun stuff'),
            TextSpan(
                style: textStyle.copyWith(color: Theme.of(context).accentColor),
                text: 'https://flutter.dev'),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          BlocBuilder(
            bloc: BlocProvider.of<AuthenticationBloc>(context),
            builder: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationLoggedIn ||
                  state is AuthenticationLoggedInUnverified) {
                return UserAccountsDrawerHeader(
                  accountEmail: Text(state.user.email),
                  accountName: Text(state.user.displayName),
                  currentAccountPicture:
                      Image.asset("assets/images/basketball.png"),
                );
              }
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                ),
                child: Text(Messages.of(context).title),
              );
            },
          ),
          BlocBuilder(
            bloc: BlocProvider.of<AuthenticationBloc>(context),
            builder: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationLoggedIn ||
                  state is AuthenticationLoggedInUnverified) {
                return ListTile(
                  leading: Icon(MdiIcons.logout),
                  title: Text(Messages.of(context).logout),
                  onTap: () {
                    BlocProvider.of<LoginBloc>(context).add(LoginEventLogout());
                  },
                );
              }
              return ListTile(
                leading: Icon(MdiIcons.login),
                title: Text(Messages.of(context).login),
                onTap: () {
                  Navigator.popAndPushNamed(context, "/Login/Home");
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(Messages.of(context).settings),
            onTap: () {
              Navigator.popAndPushNamed(context, "/Settings");
            },
          ),
          AboutListTile(
            icon: Icon(Icons.info),
            applicationIcon: FlutterLogo(),
            applicationName: Messages.of(context).title,
            applicationVersion: 'August 2019',
            applicationLegalese: '© 2020 The Whelksoft Authors',
            aboutBoxChildren: aboutBoxChildren,
          ),
        ],
      ),
    );
  }
}
