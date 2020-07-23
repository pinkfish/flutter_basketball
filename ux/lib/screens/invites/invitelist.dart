import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/widgets/invites/deleteinvitedialog.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../messages.dart';

// Shows the current invites pending for this user.
class InviteListScreen extends StatefulWidget {
  static void deletePressed(BuildContext context, SingleInviteBloc bloc) async {
    Messages mess = Messages.of(context);

    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(mess.deleteInvite),
            content: new Scrollbar(
              child: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(mess.confirmdelete(bloc.state.invite)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  // Do the delete.
                  Navigator.of(context).pop(true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
    if (result) {
      bloc.add(SingleInviteDelete());
    }
  }

  @override
  InviteListScreenState createState() {
    return new InviteListScreenState();
  }
}

class InviteListScreenState extends State<InviteListScreen> {
  InvitesBloc _invitesBloc;
  @override
  void initState() {
    super.initState();
    _invitesBloc = InvitesBloc(
        db: RepositoryProvider.of<BasketballDatabase>(context),
        email: BlocProvider.of<AuthenticationBloc>(context).state.user.email);
  }

  @override
  void dispose() {
    super.dispose();
    _invitesBloc.close();
  }

  void onInviteUpdate() {
    setState(() {});
  }

  void _deleteInvite(SingleInviteBloc bloc) async {
    await deleteInviteDialog(context, bloc);
  }

  void _addInviteToTeam(Invite invite) {
    Navigator.pushNamed(context, "/Invite/AcceptInviteToTeam/" + invite.uid);
  }

  Widget _buildInviteToTeam(InviteToTeam inviteData) {
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);
    return BlocProvider(
      create: (BuildContext context) => SingleInviteBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          inviteUid: inviteData.uid),
      child: Builder(
        builder: (BuildContext context) => BlocBuilder(
          bloc: BlocProvider.of<SingleInviteBloc>(context),
          builder: (BuildContext context, SingleInviteBlocState state) {
            Widget child;
            // Deleted...
            if (state is SingleInviteDeleted) {
              child = Card(
                child: ListTile(
                  leading: Icon(MaterialIcons.error),
                  title: Text(Messages.of(context).errorForm),
                ),
              );
            } else {
              // Not deleted.
              InviteToTeam invite;
              if (state is SingleInviteUninitialized) {
                invite = inviteData;
              } else {
                invite = state.invite;
              }
              child = Card(
                child: ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.add),
                    color: theme.accentColor,
                    onPressed: () {
                      _addInviteToTeam(invite);
                    },
                  ),
                  title: Text(
                    messages.teamForInvite(invite.teamName),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteInvite(BlocProvider.of<SingleInviteBloc>(context));
                    },
                  ),
                ),
              );
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: child,
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildInviteList(BuiltList<Invite> invites) {
    List<Widget> inviteWidgets = <Widget>[];
    if (invites.length == 0) {
      inviteWidgets.add(SizedBox(height: 50.0));
      inviteWidgets.add(
        Center(
          child: Text(
            Messages.of(context).noinvites,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      );
    } else {
      for (var i in invites) {
        if (i is InviteToTeam) {
          inviteWidgets.add(_buildInviteToTeam(i));
        }
      }
    }
    return inviteWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).invite),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: BlocConsumer(
            bloc: _invitesBloc,
            listener: (BuildContext context, InvitesBlocState state) {
              if (state is SingleInviteDeleted) {
                Navigator.pop(context);
                return;
              }
              if (state is SingleInviteSaveFailed) {
                Navigator.pop(context);
                return;
              }
            },
            builder: (BuildContext context, InvitesBlocState state) {
              return SavingOverlay(
                saving: state is SingleInviteSaving,
                child: Column(
                  children:
                  state is SingleInviteLoaded ? _buildInviteList(state.invites) : LoadingWidget(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
