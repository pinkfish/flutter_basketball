import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';

///
/// Callback whenm the media is ready to save.
///
typedef void MediaEditCallback(Uri url, String description, DateTime start);

///
/// Class top handle editing the media, does a callback whemn the
/// media is ready to save.
///
class MediaEdit extends StatefulWidget {
  final MediaInfo media;
  final MediaEditCallback onSave;
  final Function onDelete;
  final DateTime start;

  MediaEdit({this.media, this.onSave, this.onDelete, this.start});

  @override
  State<StatefulWidget> createState() {
    return _MediaEditState();
  }
}

class _MediaEditState extends State<MediaEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uri _url;
  String _description;
  DateTime _start;

  void _saveForm() {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();
    widget.onSave(_url, _description, _start);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.local_library),
              hintText: Messages.of(context).urlTitle,
              labelText: Messages.of(context).urlTitle,
            ),
            onSaved: (String str) {
              _url = Uri.parse(str);
            },
            initialValue: widget.media?.url ?? "",
            autovalidate: false,
            validator: (String str) {
              try {
                if (str == null || str == '') {
                  return Messages.of(context).emptyText;
                }
                Uri url = Uri.parse(str);

                if (url == null) {
                  return Messages.of(context).invalidUrl;
                }
              } catch (FormatException) {
                return Messages.of(context).invalidUrl;
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(MdiIcons.text),
              hintText: Messages.of(context).descriptionTitle,
              labelText: Messages.of(context).descriptionTitle,
            ),
            onSaved: (String str) {
              _description = str;
            },
            initialValue: widget.media?.description ?? "",
            autovalidate: false,
          ),
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
