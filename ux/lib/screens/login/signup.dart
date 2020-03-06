import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';
import '../../services/loginbloc.dart';
import '../../services/validations.dart';
import '../../widgets/savingoverlay.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  SignupScreenState createState() => new SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      new GlobalKey<FormFieldState<String>>();
  ScrollController _scrollController = new ScrollController();
  bool _autovalidate = false;

  // Profile details.
  String _displayName;
  String _phoneNumber;
  String _email;
  String _password;
  FocusNode _focusNodeDisplayName = new FocusNode();
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodePassword = new FocusNode();
  FocusNode _focusNodePasswordVerify = new FocusNode();
  LoginBloc _loginBloc;

  @override
  void initState() {
    //_person.profile = new FusedUserProfile(null);
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  void _onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar(Messages.of(context).formerror);
    } else {
      form.save();
      //email = _email;
      //password = _password;
      _loginBloc.add(LoginEventSignupUser(
          email: _email,
          password: _password,
          displayName: _displayName,
          phoneNumber: _phoneNumber));
    }
  }

  String _validatePassword(String value) {
    String old = _passwordFieldKey.currentState.value;
    if (value != old) {
      return Messages.of(context).passwordsnotmatching;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    //print(context.widget.toString());
    Validations validations = new Validations();

    return Scaffold(
      key: _scaffoldKey,
      body: BlocListener(
        bloc: _loginBloc,
        listener: (BuildContext context, LoginState state) {
          if (state is LoginSignupFailed) {
            showInSnackBar(Messages.of(context).errorcreatinguser);
          } else if (state is LoginSignupSucceeded) {
            showDialog<bool>(
              context: context,
              builder: (BuildContext context) => new AlertDialog(
                content: new Text(Messages.of(context).createdaccount),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: new Text(
                          MaterialLocalizations.of(context).okButtonLabel))
                ],
              ),
            ).then((bool ok) {
              Navigator.pushNamed(context, "/Login/Verify");
            });
          }
        },
        child: BlocBuilder(
          bloc: _loginBloc,
          builder: (BuildContext context, LoginState state) => SavingOverlay(
            saving: state is LoginValidatingSignup,
            child: new SingleChildScrollView(
              controller: _scrollController,
              child: new Container(
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
                            image: new ExactAssetImage(
                                "assets/images/abstractsport.png"),
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
                          new Form(
                            key: _formKey,
                            autovalidate: _autovalidate,
                            child: new Column(
                              children: <Widget>[
                                new TextFormField(
                                  decoration: new InputDecoration(
                                      icon: const Icon(Icons.account_box),
                                      hintText:
                                          Messages.of(context).displaynamehint,
                                      labelText:
                                          Messages.of(context).displayname),
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                  focusNode: _focusNodeDisplayName,
                                  validator: (String str) {
                                    return validations.validateName(
                                        context, str);
                                  },
                                  onSaved: (String value) {
                                    _displayName = value;
                                  },
                                ),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.email),
                                    hintText:
                                        Messages.of(context).youremailHint,
                                    labelText: Messages.of(context).email,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: false,
                                  focusNode: _focusNodeEmail,
                                  validator: (String str) {
                                    return validations.validateEmail(
                                        context, str);
                                  },
                                  onSaved: (String value) {
                                    _email = value;
                                  },
                                ),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: Messages.of(context).password,
                                    labelText: Messages.of(context).password,
                                  ),
                                  obscureText: true,
                                  focusNode: _focusNodePassword,
                                  validator: (String str) {
                                    return validations.validatePassword(
                                        context, str);
                                  },
                                  key: _passwordFieldKey,
                                  onSaved: (String password) {
                                    _password = password;
                                  },
                                ),
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText:
                                        Messages.of(context).verifypassword,
                                    labelText:
                                        Messages.of(context).verifypassword,
                                  ),
                                  focusNode: _focusNodePasswordVerify,
                                  obscureText: true,
                                  validator: _validatePassword,
                                  onSaved: (String password) {},
                                ),
                                new Container(
                                  child: new RaisedButton(
                                      child: new Text(
                                          Messages.of(context).createaccount),
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      onPressed: _handleSubmitted),
                                  margin: new EdgeInsets.only(
                                      top: 20.0, bottom: 20.0),
                                ),
                              ],
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new FlatButton(
                                child: new Text(Messages.of(context).login),
                                textColor: Theme.of(context).accentColor,
                                onPressed: () => _onPressed("/Login/Home"),
                              ),
                              new FlatButton(
                                child: new Text(
                                    Messages.of(context).forgotPasswordButton),
                                textColor: Theme.of(context).accentColor,
                                onPressed: () =>
                                    _onPressed("/Login/ForgotPassword"),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
