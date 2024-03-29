import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';

///
/// Callback whenm the player is ready to save.
///
typedef void PlayerEditCallback(
    String name, String jerseyNumber, bool opponent);

///
/// Class top handle editing the player, does a callback whemn the
/// player is ready to save.
///
class PlayerEdit extends StatefulWidget {
  final Player player;
  final PlayerEditCallback onSave;
  final Function onDelete;
  final bool hasOpponentField;

  PlayerEdit(
      {this.player,
      this.onSave,
      this.onDelete,
      @required this.hasOpponentField});

  @override
  State<StatefulWidget> createState() {
    return _PlayerEditState();
  }
}

class _PlayerEditState extends State<PlayerEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name;
  String _jerseyNumber;
  bool opponent = false;

  void _saveForm() {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();
    widget.onSave(_name, _jerseyNumber, opponent);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: "playername",
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.people),
                hintText: Messages.of(context).playerName,
                labelText: Messages.of(context).playerName,
              ),
              onSaved: (String str) {
                _name = str;
              },
              initialValue: widget.player?.name ?? "",
              autovalidate: false,
              validator: (String str) {
                if (str == null || str == '') {
                  return Messages.of(context).emptyText;
                }
                return null;
              },
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(MdiIcons.tshirtCrew),
              hintText: Messages.of(context).jersyNumber,
              labelText: Messages.of(context).jersyNumber,
            ),
            onSaved: (String str) {
              _jerseyNumber = str;
            },
            initialValue: widget.player?.jerseyNumber ?? "",
            autovalidate: false,
          ),
          widget.hasOpponentField
              ? CheckboxListTile(
                  value: opponent,
                  onChanged: (bool result) => setState(() => opponent = result),
                  title: Text(Messages.of(context).opponent),
                )
              : SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ButtonBar(
              children: [
                FlatButton(
                  child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                      style: Theme.of(context).textTheme.button),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text(
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                      style: Theme.of(context).textTheme.button),
                  onPressed: () => _saveForm(),
                ),
                RaisedButton.icon(
                  textTheme: ButtonTextTheme.primary,
                  elevation: 2,
                  icon: Icon(Icons.save),
                  label: Text(Messages.of(context).saveButton,
                      style: Theme.of(context).textTheme.button),
                  onPressed: () => _saveForm(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
