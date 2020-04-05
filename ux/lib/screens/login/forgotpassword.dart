import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';
import '../../services/loginbloc.dart';
import '../../services/validations.dart';
import '../../widgets/loginheader.dart';
import '../../widgets/savingoverlay.dart';

///
/// Page to request a new password :)
///
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => new _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  Validations validations = new Validations();
  String email = '';
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

  void _handleSubmitted() {
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      _loginBloc.add(LoginEventForgotPasswordSend(email: email));
    }
  }

  Widget _buildForgotPasswordForm() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: formKey,
            autovalidate: autovalidate,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    hintText: Messages.of(context).email,
                    labelText: Messages.of(context).email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  onSaved: (String value) {
                    email = value;
                  },
                ),
                Container(
                  child: RaisedButton(
                      child: Text(Messages.of(context).forgotPasswordButton),
                      color: Theme.of(context).primaryColor,
                      onPressed: _handleSubmitted),
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text(Messages.of(context).createaccountButton),
                textColor: Theme.of(context).accentColor,
                onPressed: () {
                  _loginBloc.add(LoginEventReset());
                  onPressed("/Login/SignUp");
                },
              ),
              FlatButton(
                child: Text(Messages.of(context).loginButton),
                textColor: Theme.of(context).accentColor,
                onPressed: () {
                  _loginBloc.add(LoginEventReset());
                  onPressed("/Login/Home");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordDone() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text(Messages.of(context).forgotPasswordSent)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text(Messages
                    .of(context)
                    .createaccountButton),
                textColor: Theme
                    .of(context)
                    .accentColor,
                onPressed: () {
                  _loginBloc.add(LoginEventReset());
                  onPressed("/Login/SignUp");
                },
              ),
              FlatButton(
                  child: Text(Messages
                      .of(context)
                      .loginButton),
                  textColor: Theme
                      .of(context)
                      .accentColor,
                  onPressed: () {
                    _loginBloc.add(LoginEventReset());
                    // Go back to the initial state.
                    onPressed("/Login/Home");
                  }),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              LoginHeader(),
              BlocBuilder(
                  bloc: _loginBloc,
                  builder: (BuildContext context, LoginState state) {
                    bool loading = LoginState is LoginValidatingForgotPassword;
                    if (state is LoginForgotPasswordFailed) {
                      showInSnackBar(state.error.toString());
                      return SavingOverlay(
                        saving: false,
                        child: _buildForgotPasswordDone(),
                      );
                    }
                    return SavingOverlay(
                      saving: loading,
                      child: _buildForgotPasswordForm(),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
