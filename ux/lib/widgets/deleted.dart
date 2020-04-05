import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../messages.dart';

///
/// Shows a nifty deleted message for bits of the app.
///
class DeletedWidget extends StatelessWidget {
  final bool showAppBar;
  final Game game;

  DeletedWidget({this.showAppBar = false, this.game});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      showAppBar
          ? AppBar(
              title: Text("vs ${game.opponentName}"),
            )
          : SizedBox(
              height: 0,
            ),
      Text(Messages.of(context).unknown,
          style: Theme.of(context).textTheme.headline4),
      Icon(Icons.error, size: 40.0, color: Theme.of(context).errorColor),
    ]);
  }
}
