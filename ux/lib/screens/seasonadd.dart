import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

///
/// Adds a season to a specific team.
///
class AddSeasonScreen extends StatelessWidget {
  final String teamUid;

  AddSeasonScreen(this.teamUid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addSeasonTooltip),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => AddSeasonBloc(
                db: BlocProvider.of<TeamsBloc>(context).db,
                crashes: RepositoryProvider.of<CrashReporting>(context)),
          ),
          BlocProvider(
            create: (BuildContext context) => SingleTeamBloc(
              db: RepositoryProvider.of<BasketballDatabase>(context),
              teamUid: this.teamUid,
              crashes: RepositoryProvider.of<CrashReporting>(context),
              loadSeasons: true,
            ),
          ),
        ],
        child: _AddSeasonForm(teamUid),
      ),
    );
  }
}

class _AddSeasonForm extends StatefulWidget {
  final String teamUid;

  _AddSeasonForm(this.teamUid);

  @override
  State<StatefulWidget> createState() {
    return _AddSeasonFormState();
  }
}

class _AddSeasonFormState extends State<_AddSeasonForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _seasonName = "";
  String _copyFromUid = "none";

  void _saveForm(AddSeasonBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();

    bloc.add(
      AddSeasonEventCommit(
          teamUid: widget.teamUid,
          newSeason: Season((b) => b
            ..teamUid = widget.teamUid
            ..name = _seasonName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<SingleTeamBloc>(context),
      builder: (BuildContext context, SingleTeamState teamState) =>
          BlocConsumer(
        cubit: BlocProvider.of<AddSeasonBloc>(context),
        listener: (BuildContext context, AddItemState state) {
          if (state is AddItemDone) {
            print("Pop add done");
            Navigator.pop(context);
          }
          if (state is AddItemSaveFailed) {
            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text(Messages.of(context).saveFailed)));
          }
        },
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
            saving: state is AddItemSaving,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Text(
                          "Copy players from",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        IconButton(
                          icon: Icon(Icons.help),
                          onPressed: _showHelpOnCopy,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 10.0),
                        teamState.loadedSeasons
                            ? DropdownButton<String>(
                                value: _copyFromUid,
                                items: [
                                  DropdownMenuItem(
                                    child: Text(
                                      "No season",
                                      textScaleFactor: 1.25,
                                    ),
                                    value: "none",
                                  ),
                                  ...teamState.seasons.map(
                                    (Season s) => DropdownMenuItem(
                                      child: Text(s.name),
                                      value: s.uid,
                                    ),
                                  ),
                                ],
                                onChanged: (String str) =>
                                    setState(() => _copyFromUid = str),
                              )
                            : Text(Messages.of(context).loadingText),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      key: Key("seasonFormField"),
                      decoration: InputDecoration(
                        icon: Icon(Icons.people),
                        hintText: Messages.of(context).seasonName,
                        labelText: Messages.of(context).seasonName,
                      ),
                      onSaved: (String str) {
                        _seasonName = str;
                      },
                      initialValue: _seasonName,
                      autovalidate: false,
                      validator: (String str) {
                        if (str == null || str == '') {
                          return Messages.of(context).emptyText;
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ButtonBar(
                        children: [
                          FlatButton(
                            key: Key("cancelButtonTeam"),
                            child: Text(
                                MaterialLocalizations.of(context)
                                    .cancelButtonLabel,
                                style: Theme.of(context).textTheme.button),
                            onPressed: () => Navigator.pop(context),
                          ),
                          RaisedButton.icon(
                            key: Key("saveButtonTeam"),
                            textTheme: ButtonTextTheme.primary,
                            elevation: 2,
                            icon: Icon(Icons.save),
                            label: Text(Messages.of(context).saveButton,
                                style: Theme.of(context).textTheme.button),
                            onPressed: () => _saveForm(
                                BlocProvider.of<AddSeasonBloc>(context)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHelpOnCopy() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Copy Players'),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText1,
                  text: 'Copies players from the specific season to the new '
                      'season so that the new season starts with the same players '
                      'as copied season.'),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
