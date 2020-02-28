import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/bloc/singleplayerbloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../messages.dart';

///
/// Shows the details on the player by giving the name and jersey number.
///
class PlayerTile extends StatelessWidget {
  final String playerUid;
  final Function onTap;

  PlayerTile({@required this.playerUid, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SinglePlayerBloc(
          playerUid: this.playerUid,
          db: BlocProvider.of<TeamsBloc>(context).db),
      child: Builder(
        builder: (BuildContext context) {
          return BlocBuilder(
            bloc: BlocProvider.of<SinglePlayerBloc>(context),
            builder: (BuildContext context, SinglePlayerState state) {
              if (state is SinglePlayerDeleted) {
                return ListTile(
                  title: Text(Messages.of(context).unknown),
                  leading: Stack(
                    children: <Widget>[
                      Icon(MdiIcons.tshirtCrewOutline),
                      Text(""),
                    ],
                  ),
                );
              }
              if (state is SinglePlayerUninitialized) {
                return ListTile(
                  title: Text(Messages.of(context).loading),
                  leading: Stack(
                    children: <Widget>[
                      Icon(MdiIcons.tshirtCrewOutline),
                      Text(""),
                    ],
                  ),
                );
              }
              if (state is SinglePlayerLoaded) {
                return ListTile(
                  onTap: this.onTap,
                  title: Text(
                    state.player.name,
                    style: Theme.of(context).textTheme.title,
                  ),
                  leading: ConstrainedBox(
                    constraints:
                        BoxConstraints.tightFor(height: 40.0, width: 40.0),
                    child: Container(
                      child: Center(
                        child: Text(
                          state.player.jerseyNumber,
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                );
              }
              return ListTile(
                title: Text(Messages.of(context).unknown),
                leading: Stack(
                  children: <Widget>[
                    Icon(MdiIcons.tshirtCrewOutline),
                    Text(""),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
