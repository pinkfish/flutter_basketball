import 'dart:math';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/bloc/singleplayerbloc.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';

typedef void PlayerCallbackFunc(String playerUid);
typedef Widget PlayerExtraFunc(String playerUid);

///
/// Shows the details on the player by giving the name and jersey number.
///
class PlayerTile extends StatelessWidget {
  final String playerUid;
  final Player player;
  final PlayerCallbackFunc onTap;
  final bool editButton;
  final Color color;
  final ShapeBorder shape;
  final bool compactDisplay;
  final PlayerExtraFunc extra;
  final PlayerSeasonSummary summary;
  final double scale;

  PlayerTile(
      {this.playerUid,
      this.player,
      this.onTap,
      this.editButton = true,
      this.color,
      this.summary,
      this.shape,
      this.extra,
      this.compactDisplay = false,
      this.scale = 1.0})
      : assert(player != null || playerUid != null);

  @override
  Widget build(BuildContext context) {
    return _innerBuild(context);
  }

  Widget _innerBuild(BuildContext context) {
    if (player != null) {
      return _loadedData(context, player);
    }
    return BlocProvider(
      create: (BuildContext context) => SinglePlayerBloc(
          playerUid: this.playerUid,
          db: RepositoryProvider.of<BasketballDatabase>(context),
          crashes: RepositoryProvider.of<CrashReporting>(context)),
      child: Builder(
        builder: (BuildContext context) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: BlocBuilder(
              cubit: BlocProvider.of<SinglePlayerBloc>(context),
              builder: (BuildContext context, SinglePlayerState state) {
                if (state is SinglePlayerDeleted) {
                  if (compactDisplay) {
                    return Text(Messages.of(context).unknown);
                  }
                  return Card(
                    color: color,
                    shape: shape,
                    child: ListTile(
                      title: Text(Messages.of(context).unknown),
                      subtitle: summary != null
                          ? Text(
                              Messages.of(context).seasonSummary(summary),
                            )
                          : null,
                      leading: Stack(
                        children: <Widget>[
                          Icon(MdiIcons.tshirtCrewOutline),
                          Text(""),
                        ],
                      ),
                    ),
                  );
                }
                if (state is SinglePlayerUninitialized) {
                  if (compactDisplay) {
                    return Text(Messages.of(context).loadingText);
                  }
                  return Card(
                    color: color,
                    shape: shape,
                    child: ListTile(
                      title: Text(Messages.of(context).loadingText,
                          style: Theme.of(context).textTheme.caption),
                      subtitle: summary != null
                          ? Text(
                              Messages.of(context).seasonSummary(summary),
                            )
                          : null,
                      leading: Stack(
                        children: <Widget>[
                          Icon(MdiIcons.tshirtCrewOutline),
                          Text(""),
                        ],
                      ),
                    ),
                  );
                }
                if (state is SinglePlayerLoaded) {
                  return _loadedData(context, state.player);
                }
                return Card(
                  color: color,
                  shape: shape,
                  child: ListTile(
                    title: Text(Messages.of(context).unknown),
                    subtitle: summary != null
                        ? Text(
                            Messages.of(context).seasonSummary(summary),
                          )
                        : null,
                    leading: Stack(
                      children: <Widget>[
                        Icon(MdiIcons.tshirtCrewOutline),
                        Text(""),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _loadedData(BuildContext context, Player player) {
    if (compactDisplay) {
      return GestureDetector(
        onTap: () => onTap != null ? onTap(player.uid) : null,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: shape,
          ),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(height: 40.0, width: 40.0),
                child: Container(
                  child: Center(
                    child: Text(
                      player.jerseyNumber,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              Text(
                player.name,
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
              ),
              (this.extra != null ? extra(player.uid) : SizedBox(width: 0)),
            ],
          ),
        ),
      );
    }

    return Card(
      color: color,
      shape: shape,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
        return ListTile(
          visualDensity: box.maxHeight < 40.0
              ? VisualDensity.compact
              : VisualDensity.standard,
          contentPadding: box.maxHeight < 40.0 ? EdgeInsets.all(1.0) : null,
          onTap: onTap != null ? () => onTap(player.uid) : null,
          title: Text(
            player.name,
            style: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: min(box.maxHeight - 3,
                    Theme.of(context).textTheme.headline6.fontSize)),
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1.0,
          ),
          leading: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                height: min(40.0, box.maxHeight - 4),
                width: min(40.0, box.maxHeight - 4)),
            child: Container(
              child: Center(
                child: Text(
                  player.jerseyNumber,
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: min(20.0, box.maxHeight - 10),
                      ),
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          subtitle: summary != null
              ? Text(
                  Messages.of(context).seasonSummary(summary),
                )
              : null,
          trailing: editButton
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.pushNamed(
                      context, "/Player/Edit/" + player.uid),
                )
              : null,
        );
      }),
    );
  }
}
