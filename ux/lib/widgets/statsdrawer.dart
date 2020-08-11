import '../services/authenticationbloc.dart';
import '../services/localutilities.dart';
import '../services/loginbloc.dart';
import '../widgets/util/gfdrawerheader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';
import 'util/gfavatar.dart';

///
/// Shows a nice drawer for the app.  Yay!
///
class StatsDrawer extends StatelessWidget {
  StatsDrawer();

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.bodyText2;
    final List<Widget> aboutBoxChildren = <Widget>[
      SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: Messages.of(context).aboutstatsappdescription),
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
            cubit: BlocProvider.of<AuthenticationBloc>(context),
            builder: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationLoggedIn ||
                  state is AuthenticationLoggedInUnverified) {
                return GFDrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      //begin: Alignment.bottomLeft,
                      //end: Alignment.topRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        LocalUtilities.brighten(
                            Theme.of(context).primaryColor, 60),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Messages.of(context).getUnverified(
                            state.user.displayName ??
                                Messages.of(context).unknown,
                            state is AuthenticationLoggedInUnverified),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        state.user.email,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                  currentAccountPicture: GFAvatar(
                      backgroundImage: AssetImage(
                    "assets/images/basketball.png",
                  )),
                );
              }
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                ),
                child: Text(Messages.of(context).titleOfApp),
              );
            },
          ),
          BlocBuilder(
            cubit: BlocProvider.of<AuthenticationBloc>(context),
            builder: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationLoggedInUnverified) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(MdiIcons.email),
                      title: Text(Messages.of(context).resendverifyButton),
                      onTap: () {
                        BlocProvider.of<LoginBloc>(context)
                            .add(LoginEventResendEmail());
                      },
                    ),
                    ListTile(
                      leading: Icon(MdiIcons.logout),
                      title: Text(Messages.of(context).logoutButton),
                      onTap: () {
                        BlocProvider.of<LoginBloc>(context)
                            .add(LoginEventLogout());
                      },
                    ),
                  ],
                );
              }

              if (state is AuthenticationLoggedIn) {
                return ListTile(
                  leading: Icon(MdiIcons.logout),
                  title: Text(Messages.of(context).logoutButton),
                  onTap: () {
                    BlocProvider.of<LoginBloc>(context).add(LoginEventLogout());
                  },
                );
              }
              return ListTile(
                leading: Icon(MdiIcons.login),
                title: Text(Messages.of(context).loginButton),
                onTap: () {
                  Navigator.pushNamed(context, "/Login/Home");
                },
              );
            },
          ),
          ListTile(
            leading: Icon(MaterialIcons.insert_invitation),
            title: Text(Messages.of(context).invite),
            onTap: () {
              Navigator.pushNamed(context, "/Invite/List");
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(Messages.of(context).settings),
            onTap: () {
              Navigator.pushNamed(context, "/Settings");
            },
          ),
          AboutListTile(
            icon: Icon(Icons.info),
            applicationIcon: FlutterLogo(),
            applicationName: Messages.of(context).titleOfApp,
            applicationVersion: 'July 2020',
            applicationLegalese: '© 2020 The Whelksoft Authors',
            aboutBoxChildren: aboutBoxChildren,
          ),
        ],
      ),
    );
  }
}
