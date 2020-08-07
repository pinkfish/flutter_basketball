import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';

///
/// Shows the invite the team screen.
///
class AcceptInviteToTeamScreen extends StatefulWidget {
  AcceptInviteToTeamScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToTeamScreenState createState() {
    return new _AcceptInviteToTeamScreenState();
  }
}

class _AcceptInviteToTeamScreenState extends State<AcceptInviteToTeamScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  SingleInviteBloc _singleInviteBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _singleInviteBloc = SingleInviteBloc(
        db: RepositoryProvider.of<BasketballDatabase>(context),
        inviteUid: widget._inviteUid,
        crashes: RepositoryProvider.of<CrashReporting>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc.close();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _singleInviteBloc.add(SingleInviteEventAcceptInviteToTeam());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: _singleInviteBloc,
      listener: (BuildContext context, SingleInviteBlocState state) {
        if (state is SingleInviteDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocProvider<SingleInviteBloc>.value(
        value: _singleInviteBloc,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text(Messages.of(context).titleOfApp),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  _savePressed();
                },
                child: new Text(
                  Messages.of(context).saveButtonText,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          body: new Scrollbar(
            child: new SingleChildScrollView(
              child: BlocConsumer(
                cubit: _singleInviteBloc,
                listener: (BuildContext context, SingleInviteBlocState state) {
                  if (state is SingleInviteDeleted) {
                    // go back!
                    Navigator.pop(context);
                  }
                },
                builder: (BuildContext context, SingleInviteBlocState state) {
                  if (state is SingleInviteDeleted) {
                    // Go back!
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (state is SingleInviteSaveFailed) {
                      _showInSnackBar(Messages.of(context).formerror);
                    }
                    InviteToTeam invite = state.invite as InviteToTeam;
                    return SavingOverlay(
                      saving: !(state is SingleInviteLoaded),
                      child: Form(
                        key: _formKey,
                        child: new Column(
                          children: <Widget>[
                            new ListTile(
                              leading: const Icon(MdiIcons.accountGroup),
                              title: new Text(invite.teamName),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
