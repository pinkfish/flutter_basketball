import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../../messages.dart';

///
/// Shows a delete dialog to delete the invite.
///
Future<bool> deleteInviteDialog(
    BuildContext context, SingleInviteBloc bloc) async {
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
            child: new Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              // Do the delete.
              Navigator.of(context).pop(true);
            },
          ),
          new FlatButton(
            child:
                new Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
  if (result) {
    bloc.add(SingleInviteDelete());
  }
  return result;
}
