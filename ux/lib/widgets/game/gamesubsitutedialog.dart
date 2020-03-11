import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

import 'dialogplayerlist.dart';

///
/// Shows the players as a nice grid to be able to select from
/// for doing a sub.
///
class GamePlayerSubsitutionDialog extends StatefulWidget {
  final Game game;

  GamePlayerSubsitutionDialog({@required this.game});

  @override
  State<StatefulWidget> createState() {
    return _GamePlayerSubsitutionDialogState();
  }
}

class _GamePlayerSubsitutionDialogState
    extends State<GamePlayerSubsitutionDialog> {
  int _currentTab = 0;
  String _selectedIncoming;

  bool _filterPlayer(String playerUid) {
    if (_currentTab == 1) {
      if (widget.game.opponents.containsKey(_selectedIncoming)) {
        return playerUid != _selectedIncoming &&
            widget.game.opponents.containsKey(playerUid);
      } else {
        return playerUid != _selectedIncoming &&
            widget.game.players.containsKey(playerUid);
      }
    }
    return true;
  }

  void _selectPlayer(BuildContext context, String playerUid) {
    if (_currentTab == 0) {
      setState(() {
        _currentTab = 1;
        _selectedIncoming = playerUid;
      });
    } else {
      Navigator.pop(context, Tuple2(_selectedIncoming, playerUid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Player"),
        automaticallyImplyLeading: false,
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation o) {
          return Column(
            children: [
              Expanded(
                child: DialogPlayerList(
                  game: widget.game,
                  onSelectPlayer: _selectPlayer,
                  orientation: o,
                  filterPlayer: _filterPlayer,
                ),
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                      textScaleFactor: 1.5,
                    ),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (p) => setState(() => _currentTab = p),
        items: [
          BottomNavigationBarItem(
            title: Text("Incoming"),
            icon: Icon(Icons.person_add),
          ),
          BottomNavigationBarItem(
            title: Text("Outgoing"),
            icon: Icon(MdiIcons.accountRemoveOutline),
          ),
        ],
      ),
    );
  }
}
