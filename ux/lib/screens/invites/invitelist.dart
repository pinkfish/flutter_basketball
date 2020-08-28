import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/authenticationbloc.dart';
import 'package:basketballstats/widgets/loading.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../messages.dart';

// Shows the current invites pending for this user.
class InviteListScreen extends StatefulWidget {
  @override
  _InviteListScreenState createState() {
    return new _InviteListScreenState();
  }
}

///
/// The internal state to track the invites.
///
class _InviteListScreenState extends State<InviteListScreen> {
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

  void _addInviteToTeam(Invite invite) {
    Navigator.pushNamed(context, "/Invite/AcceptInviteToTeam/" + invite.uid);
  }

  Widget _buildInviteToTeam(InviteToTeam inviteData) {
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);
    return BlocProvider(
      create: (BuildContext context) => SingleInviteBloc(
          db: RepositoryProvider.of<BasketballDatabase>(context),
          inviteUid: inviteData.uid,
          crashes: RepositoryProvider.of<CrashReporting>(context)),
      child: Builder(
        builder: (BuildContext context) => BlocBuilder(
          cubit: BlocProvider.of<SingleInviteBloc>(context),
          builder: (BuildContext context, SingleInviteBlocState state) {
            Widget child;
            // Deleted...
            if (state is SingleInviteDeleted) {
              child = Card(
                margin: EdgeInsets.all(10.0),
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
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(5.0),
                  leading: Image.asset("assets/images/basketball.png"),
                  title: Text(
                    messages.teamForInvite(invite.teamName),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  subtitle: Text(Messages.of(context).joinTeamTitle),
                  onTap: () {
                    _addInviteToTeam(invite);
                  },
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
            cubit: _invitesBloc,
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
                  children: state is InvitesBlocLoaded
                      ? _buildInviteList(state.invites)
                      : [
                          Center(
                            child: LoadingWidget(),
                          ),
                        ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
