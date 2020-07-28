import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// Shows the details on the user by giving the name.
///
class UserName extends StatelessWidget {
  final String userUid;
  final double textScaleFactor;

  static Map<String, String> _nameCache = {};

  UserName({@required this.userUid, this.textScaleFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: Key("user$userUid"),
      create: (BuildContext context) => SingleUserBloc(
          userUid: this.userUid, db: BlocProvider.of<TeamsBloc>(context).db),
      child: Builder(
        builder: (BuildContext context) {
          return BlocBuilder(
            cubit: BlocProvider.of<SingleUserBloc>(context),
            builder: (BuildContext context, SingleUserState state) {
              if (_nameCache.containsKey(userUid) &&
                  !(state is SingleUserLoaded)) {
                return Text(
                  _nameCache[userUid],
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textScaleFactor: textScaleFactor,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SingleUserDeleted) {
                return Text(
                  Messages.of(context).unknown,
                  textScaleFactor: textScaleFactor,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SingleUserUninitialized) {
                return Text(
                  Messages.of(context).loadingText,
                  textScaleFactor: textScaleFactor,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SingleUserLoaded) {
                _nameCache[userUid] = state.user.name;
                return Text(
                  state.user.name,
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textScaleFactor: textScaleFactor,
                  textAlign: TextAlign.start,
                );
              }
              return Text(
                Messages.of(context).unknown,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.start,
                textScaleFactor: textScaleFactor,
              );
            },
          );
        },
      ),
    );
  }
}
