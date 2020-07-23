import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// A tile to show information about the user.
///
class UserTile extends StatelessWidget {
  final String userUid;
  static Map<String, User> _userCache = {};

  UserTile({@required this.userUid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: Key("user$userUid"),
      create: (BuildContext context) => SingleUserBloc(
          userUid: this.userUid, db: BlocProvider.of<TeamsBloc>(context).db),
      child: Builder(
        builder: (BuildContext context) {
          return BlocBuilder(
            bloc: BlocProvider.of<SingleUserBloc>(context),
            builder: (BuildContext context, SingleUserState state) {
              print("$userUid $state");
              if (_userCache.containsKey(userUid) &&
                  !(state is SingleUserLoaded)) {
                return ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text(
                    _userCache[userUid].name,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(_userCache[userUid].email),
                );
              }
              if (state is SingleUserDeleted) {
                return ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text(
                    Messages.of(context).unknown,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.start,
                  ),
                );
              }
              if (state is SingleUserUninitialized) {
                return ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text(
                    Messages.of(context).loadingText,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.start,
                  ),
                );
              }
              if (state is SingleUserLoaded) {
                _userCache[userUid] = state.user;
                return ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text(
                    _userCache[userUid].name,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(_userCache[userUid].email),
                );
              }
              return ListTile(
                leading: Icon(Icons.verified_user),
                title: Text(
                  Messages.of(context).unknown,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
