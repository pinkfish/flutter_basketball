import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/services/validations.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:basketballstats/widgets/team/teamwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  GlobalKey<FormState> _form;
  String _email;
  bool _autoValidate = false;
  Validations validations = new Validations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addUserButton),
      ),
      body: BlocProvider(
        create: (BuildContext context) => AddInviteBloc(
            db: RepositoryProvider.of<BasketballDatabase>(context)),
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
                    TeamWidget(
                      teamUid: widget.teamUid,
                    ),
                    TextFormField(
                      initialValue: _email,
                      onSaved: (String str) => setState(() => _email = str),
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: Messages.of(context).email,
                        labelText: Messages.of(context).email,
                      ),
                    ),
                    ButtonBar(
                      children: [
                        FlatButton(
                          child: Text(
                              MaterialLocalizations.of(context).okButtonLabel),
                          onPressed: () => _saveForm(context),
                        ),
                        FlatButton(
                          child: Text(MaterialLocalizations.of(context)
                              .cancelButtonLabel),
                          onPressed: () => Navigator.pop(context),
                        )
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

  void _saveForm(BuildContext context) {
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
      ..email = BlocProvider.of<AuthenticationBloc>(context).state.user.email);
    BlocProvider.of<AddInviteBloc>(context)
        .add(AddInviteCommit(newInvite: invite));
  }

  String _validateEmail(String str) {
    return validations.validateEmail(context, str);
  }
}
