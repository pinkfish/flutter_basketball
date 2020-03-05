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
        create: (BuildContext context) =>
            AddTeamBloc(db: BlocProvider.of<TeamsBloc>(context).db),
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
  String _name;

  void _saveForm(AddTeamBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();
    bloc.add(AddTeamEventCommit(newTeam: Team((b) => b..name = _name)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<AddTeamBloc>(context),
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          Navigator.pop(context);
        }
        if (state is AddItemSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<AddTeamBloc>(context),
        builder: (BuildContext context, AddItemState state) {
          return SavingOverlay(
            saving: state is AddItemSaving,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.people),
                      hintText: Messages.of(context).teamName,
                      labelText: Messages.of(context).teamName,
                    ),
                    onSaved: (String str) {
                      _name = str;
                    },
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
                          child: Text(
                              MaterialLocalizations.of(context)
                                  .cancelButtonLabel,
                              style: Theme.of(context).textTheme.button),
                          onPressed: () => Navigator.pop(context),
                        ),
                        RaisedButton.icon(
                          key: Key("saveButton"),
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
