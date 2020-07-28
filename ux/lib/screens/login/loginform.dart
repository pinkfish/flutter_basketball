import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';
import '../../services/loginbloc.dart';
import '../../services/validations.dart';
import '../../widgets/loginheader.dart';
import '../../widgets/savingoverlay.dart';

///
/// Basic login setup.
///
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  Validations validations = new Validations();
  String email;
  String password;
  String errorText = '';
  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() async {
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      autovalidate = true; // Start validating on every change.
      setState(() {
        errorText = Messages.of(context).formerror;
      });
      showInSnackBar(errorText);
    } else {
      // Save the data and login.
      form.save();
      _loginBloc
          .add(LoginEventAttempt(email: email.trim(), password: password));
    }
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        padding: EdgeInsets.all(16.0),
        //decoration: new BoxDecoration(image: backgroundImage),
        child: Column(
          children: <Widget>[
            LoginHeader(),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: formKey,
                    autovalidate: autovalidate,
                    child: Column(
                      children: <Widget>[
                        Text(errorText),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.email),
                            hintText: 'Your email address',
                            labelText: 'E-mail',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          onSaved: (String value) {
                            email = value;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.lock_open),
                            hintText: 'Password',
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          onSaved: (String pass) {
                            password = pass;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      child: Text(Messages.of(context).loginButton,
                          style: Theme.of(context).primaryTextTheme.button),
                      color: Theme.of(context).primaryColor,
                      // textColor:
                      //   Theme.of(context).primaryTextTheme.button.color,
                      onPressed: () => _handleSubmitted(),
                    ),
                    margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text(Messages.of(context).createaccountButton),
                        textColor: Theme.of(context).accentColor,
                        onPressed: () => onPressed("/Login/SignUp"),
                      ),
                      FlatButton(
                        child: Text(Messages.of(context).forgotPasswordButton),
                        textColor: Theme.of(context).accentColor,
                        onPressed: () => onPressed("/Login/ForgotPassword"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  _signInButton(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _signInButton() {
    return RaisedButton(
      splashColor: Theme.of(context).splashColor,
      onPressed: () =>
          BlocProvider.of<LoginBloc>(context).add(LoginAsGoogleUser()),
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      //  borderSide: BorderSide(color: Theme.of(context).buttonColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/images/google_logo.png"),
                height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: Theme.of(context).primaryTextTheme.button,
              ),
            )
          ],
        ),
      ),
      color: Theme.of(context).primaryColor,
      // textColor: Theme.of(context).primaryTextTheme.button.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Messages.of(context).loginButton),
      ),
      body: BlocListener(
        cubit: _loginBloc,
        listener: (BuildContext context, LoginState state) {
          if (state is LoginFailed) {
            errorText = Messages.of(context).loginFailureReason(state.reason);
            showInSnackBar(errorText);
          } else if (state is LoginSucceeded) {
            Navigator.pop(context);
          } else if (state is LoginEmailNotValidated) {
            Navigator.popAndPushNamed(context, "/Login/Verify");
          }
        },
        child: BlocBuilder(
          cubit: _loginBloc,
          builder: (BuildContext context, LoginState state) {
            return SavingOverlay(
                saving: state is LoginValidating, child: _buildLoginForm());
          },
        ),
      ),
    );
  }
}
