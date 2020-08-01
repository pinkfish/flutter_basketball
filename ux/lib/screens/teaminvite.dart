import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/services/validations.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:basketballstats/widgets/team/teamwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

import '../messages.dart';

///
/// Shows and invite to the team.
///
class TeamInviteScreen extends StatefulWidget {
  final String teamUid;

  TeamInviteScreen({this.teamUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamInviteState();
  }
}

class _TeamInviteState extends State<TeamInviteScreen> {
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  String _email;
  bool _autoValidate = false;
  Validations validations = new Validations();
  bool _keyboardVisible = false;

  void initState() {
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() => _keyboardVisible = visible);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).viewInsets.bottom);
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addUserButton),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => AddInviteBloc(
                db: RepositoryProvider.of<BasketballDatabase>(context)),
          ),
          BlocProvider(
            create: (BuildContext context) => SingleTeamBloc(
                db: RepositoryProvider.of<BasketballDatabase>(context),
                teamUid: widget.teamUid),
          ),
        ],
        child: Builder(
          builder: (BuildContext context) => BlocConsumer(
            cubit: BlocProvider.of<AddInviteBloc>(context),
            listener: (BuildContext context, AddItemState state) {
              if (state is AddItemDone) {
                Navigator.pop(context);
              } else if (state is AddItemSaveFailed) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(Messages.of(context).formerror)));
              }
            },
            builder: (BuildContext context, AddItemState state) =>
                SavingOverlay(
              saving: state is AddItemSaving,
              child: Form(
                autovalidate: _autoValidate,
                key: _form,
                child: Column(
                  children: <Widget>[
                    _keyboardVisible
                        ? SizedBox(height: 0)
                        : TeamWidget(
                            teamUid: widget.teamUid,
                            showGameButton: false,
                          ),
                    TextFormField(
                      initialValue: _email,
                      onSaved: (String str) => _email = str,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: Messages.of(context).email,
                        labelText: Messages.of(context).email,
                      ),
                    ),
                    ButtonBar(
                      children: [
                        BlocBuilder(
                          cubit: BlocProvider.of<SingleTeamBloc>(context),
                          builder: (BuildContext context,
                              SingleTeamBlocState state) {
                            return FlatButton(
                              child: Text(MaterialLocalizations.of(context)
                                  .okButtonLabel),
                              onPressed: state is SingleTeamLoaded
                                  ? () => _saveForm(context, state)
                                  : null,
                            );
                          },
                        ),
                        FlatButton(
                          child: Text(MaterialLocalizations.of(context)
                              .cancelButtonLabel),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveForm(BuildContext context, SingleTeamBlocState state) {
    if (!_form.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).invalidemail)));
      setState(() => _autoValidate = true);
      return;
    }
    _form.currentState.save();
    InviteToTeam invite = InviteToTeam((b) => b
      ..email = _email
      ..teamUid = widget.teamUid
      ..teamName = state.team.name
      ..email = BlocProvider.of<AuthenticationBloc>(context).state.user.email);

    BlocProvider.of<AddInviteBloc>(context)
        .add(AddInviteCommit(newInvite: invite));
  }

  String _validateEmail(String str) {
    return validations.validateEmail(context, str);
  }
}
