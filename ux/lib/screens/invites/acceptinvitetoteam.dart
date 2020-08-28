import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/invites/deleteinvitedialog.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  bool _popped = false;

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

  void _deleteInvite() async {
    await deleteInviteDialog(context, _singleInviteBloc);
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
            title: new Text(Messages.of(context).joinTeamTitle),
          ),
          body: new Scrollbar(
            child: new SingleChildScrollView(
              child: BlocConsumer(
                cubit: _singleInviteBloc,
                listener: (BuildContext context, SingleInviteBlocState state) {
                  if (state is SingleInviteDeleted ||
                      state is SingleInviteSaveSuccessful) {
                    // go back!
                    if (!_popped) {
                      Navigator.pop(context);
                    }
                    _popped = true;
                  }
                  if (state is SingleInviteSaveFailed) {
                    _showInSnackBar(Messages.of(context).formerror);
                  }
                },
                builder: (BuildContext context, SingleInviteBlocState state) {
                  if (state is SingleInviteDeleted ||
                      state is SingleInviteUninitialized) {
                    // Go back!
                    return Center(child: CircularProgressIndicator());
                  } else {
                    InviteToTeam invite = state.invite as InviteToTeam;
                    return SavingOverlay(
                      saving: !(state is SingleInviteLoaded),
                      child: Form(
                        key: _formKey,
                        child: new Column(
                          children: <Widget>[
                            SizedBox(height: 10.0),
                            new ListTile(
                              leading:
                                  Image.asset("assets/images/basketball.png"),
                              title: new Text(
                                invite.teamName,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: RichText(
                                text: TextSpan(
                                  text: Messages.of(context).joinDescription,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ),
                            ButtonBar(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteInvite();
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                    Messages.of(context).joinButton,
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: () => _savePressed(),
                                )
                              ],
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
