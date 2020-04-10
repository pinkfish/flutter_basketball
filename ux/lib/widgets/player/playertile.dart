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
  final PlayerCallbackFunc onTap;
  final bool editButton;
  final Color color;
  final ShapeBorder shape;
  final bool compactDisplay;
  final PlayerExtraFunc extra;
  final PlayerSeasonSummary summary;

  PlayerTile(
      {@required this.playerUid,
      this.onTap,
      this.editButton = true,
      this.color,
      this.summary,
      this.shape,
      this.extra,
      this.compactDisplay = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SinglePlayerBloc(
          playerUid: this.playerUid,
          db: RepositoryProvider.of<BasketballDatabase>(context)),
      child: Builder(
        builder: (BuildContext context) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: BlocBuilder(
              bloc: BlocProvider.of<SinglePlayerBloc>(context),
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
                    return Text(Messages.of(context).loading);
                  }
                  return Card(
                    color: color,
                    shape: shape,
                    child: ListTile(
                      title: Text(Messages.of(context).loading,
                          style: Theme.of(context).textTheme.caption),
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
                  if (compactDisplay) {
                    return GestureDetector(
                      onTap: () => onTap != null ? onTap(playerUid) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          border: shape,
                        ),
                        child: Row(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                  height: 40.0, width: 40.0),
                              child: Container(
                                child: Center(
                                  child: Text(
                                    state.player.jerseyNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            Text(
                              state.player.name,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            (this.extra != null
                                ? extra(playerUid)
                                : SizedBox(width: 0)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    color: color,
                    shape: shape,
                    child: ListTile(
                      onTap: onTap != null ? () => onTap(playerUid) : null,
                      title: Text(
                        state.player.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      leading: ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(height: 40.0, width: 40.0),
                        child: Container(
                          child: Center(
                            child: Text(
                              state.player.jerseyNumber,
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
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
                                  context, "/EditPlayer/" + state.player.uid),
                            )
                          : null,
                    ),
                  );
                }
                return Card(
                  color: color,
                  shape: shape,
                  child: ListTile(
                    title: Text(Messages.of(context).unknown),
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
}
