import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../messages.dart';

///
/// Shows a nifty loading message for bits of the app.
///
class LoadingWidget extends StatelessWidget {
  final bool showAppBar;
  final Game game;

  LoadingWidget({this.showAppBar = false, this.game});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      showAppBar
          ? AppBar(
              title: Text(game == null
                  ? Messages.of(context).loading
                  : "vs ${game.opponentName}"),
            )
          : SizedBox(
              height: 0,
            ),
      Text(Messages.of(context).loading,
          style: Theme.of(context).textTheme.display1),
      CircularProgressIndicator(),
    ]);
  }
}
