import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class GameTile extends StatelessWidget {
  final Game game;
  final Function onTap;

  GameTile({@required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.subhead;
    switch (game.result) {
      case GameResult.Win:
        style = style.copyWith(
            fontSize: style.fontSize * 1, color: Theme.of(context).accentColor);
        break;
      case GameResult.Tie:
        style = style.copyWith(fontSize: style.fontSize * 1);
        style = style.copyWith(
            fontSize: style.fontSize * 1,
            color: Theme.of(context).indicatorColor);
        break;
      case GameResult.Loss:
        style = style.copyWith(
            fontSize: style.fontSize * 1,
            color: Theme.of(context).indicatorColor);
        break;
    }
    return Card(
      child: ListTile(
        leading: Icon(MdiIcons.basketball),
        title: Text("vs " + game.opponentName + " at " + game.location,
            style: Theme.of(context).textTheme.title),
        subtitle: Text(
            DateFormat("dd MMM hh:mm").format(game.eventTime.toLocal()),
            style: Theme.of(context).textTheme.subtitle),
        onTap: this.onTap,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(game.summary.pointsFor.toString(), style: style),
            Text(game.summary.pointsAgainst.toString(), style: style)
          ],
        ),
      ),
    );
  }
}
