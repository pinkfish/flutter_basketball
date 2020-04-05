import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';
import '../../services/loginbloc.dart';

///
/// Screen to verify the users email.
///
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key key}) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => new _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _loginBloc.add(LoginEventReload());
  }

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() {
    _loginBloc.add(LoginEventResendEmail());
  }

  void _onLogout(BuildContext context) async {
    _loginBloc.add(LoginEventLogout());
    // Now navigate back to the login screen.
    Navigator.pushNamed(context, "/Login/Home");
  }

  void _onSignup(BuildContext context) async {
    _loginBloc.add(LoginEventLogout());
    // Now navigate back to the signup screen.
    Navigator.pushNamed(context, "/Login/SignUp");
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    // Reload the user when the page loads.
    //UserDatabaseData.instance.userAuth.reloadUser();

    final Size screenSize = MediaQuery.of(context).size;
    double width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    double height = screenSize.height / 4 + 20;
    if (width > height) {
      width = height;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new SingleChildScrollView(
        controller: scrollController,
        child: BlocConsumer(
          bloc: _loginBloc,
          listener: (BuildContext context, LoginState state) {
            if (state is LoginVerificationDone) {
              showDialog<bool>(
                context: context,
                builder: (BuildContext context) => new AlertDialog(
                  content: new Text(Messages.of(context).verifyemailsent),
                  actions: <Widget>[
                    new FlatButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: new Text(
                            MaterialLocalizations.of(context).okButtonLabel))
                  ],
                ),
              ).then((bool res) {
                Navigator.pushNamed(context, "/");
              });
            } else if (state is LoginVerificationFailed) {
              showInSnackBar(Messages
                  .of(context)
                  .verifyemailerror);
            } else if (!(state is LoginEmailNotValidated)) {
              Navigator.popAndPushNamed(context, "/Login/Home");
            }
          },
          builder: (BuildContext context, LoginState state) {
            if (state is LoginEmailNotValidated ||
                state is LoginSignupSucceeded) {
              return new Container(
                padding: new EdgeInsets.all(16.0),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Show a circle avatar just to make it clear that this is signed in page.
                          new Center(
                            child: new CircleAvatar(
                              radius: width / 2,
                              child: new Text((state is LoginEmailNotValidated
                                  ? state.userData.displayName
                                  : state is LoginSignupSucceeded
                                  ? state.userData.displayName
                                  : null) ??
                                  Messages
                                      .of(context)
                                      .unknown),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Container(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(messages.verifyexplanation(
                              (state is LoginEmailNotValidated
                                  ? state.userData.email
                                  : state is LoginSignupSucceeded
                                  ? state.userData.email
                                  : null) ??
                                  Messages
                                      .of(context)
                                      .unknown)),
                          new Container(
                            child: RaisedButton(
                                child: new Text(messages.resendverifyButton),
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                textColor: Colors.white,
                                onPressed: _handleSubmitted),
                            margin:
                            new EdgeInsets.only(top: 20.0, bottom: 20.0),
                          ),
                        ],
                      ),
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new FlatButton(
                          child: new Text(messages.createaccountButton),
                          textColor: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () => _onSignup(context),
                        ),
                        new FlatButton(
                          child: new Text(messages.logoutButton),
                          textColor: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () => _onLogout(context),
                        ),
                      ],
                    )
                  ],
                ),
              );
            } else {
              return Text(Messages
                  .of(context)
                  .loading);
            }
          },
        ),
      ),
    );
  }
}
