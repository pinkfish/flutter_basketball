import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

class AddTeamScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).addTeamTooltip),
      ),
      body: BlocProvider(
        create: (BuildContext context) => AddTeamBloc(
            db: BlocProvider.of<TeamsBloc>(context).db,
            crashes: RepositoryProvider.of<CrashReporting>(context)),
        child: _AddTeamForm(),
      ),
    );
  }
}

class _AddTeamForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTeamFormState();
  }
}

class _AddTeamFormState extends State<_AddTeamForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = "";
  String _seasonName = "";

  void _saveForm(AddTeamBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();

    bloc.add(AddTeamEventCommit(
        newTeam: Team((b) => b..name = _name),
        firstSeason: Season((b) => b
          ..name = _seasonName
          ..teamUid = "")));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: BlocProvider.of<AddTeamBloc>(context),
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
      child: BlocBuilder(
        cubit: BlocProvider.of<AddTeamBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
            saving: state is AddItemSaving,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    key: Key("teamFormField"),
                    decoration: InputDecoration(
                      icon: Icon(Icons.people),
                      hintText: Messages.of(context).teamName,
                      labelText: Messages.of(context).teamName,
                    ),
                    onSaved: (String str) {
                      _name = str;
                    },
                    initialValue: _name,
                    autovalidate: false,
                    validator: (String str) {
                      if (str == null || str == '') {
                        return Messages.of(context).emptyText;
                      }
                      return null;
                    },
                  ),
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
                          onPressed: () =>
                              _saveForm(BlocProvider.of<AddTeamBloc>(context)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
