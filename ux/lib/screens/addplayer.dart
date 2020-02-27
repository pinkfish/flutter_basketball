import 'package:basketballdata/basketballdata.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

class AddPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: BlocProvider(
        create: (BuildContext context) =>
            AddPlayerBloc(db: BlocProvider.of<TeamsBloc>(context).db),
        child: _AddPlayerForm(),
      ),
    );
  }
}

class _AddPlayerForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPlayerFormState();
  }
}

class _AddPlayerFormState extends State<_AddPlayerForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name;
  String _jerseyNumber;

  void _saveForm(AddPlayerBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();
    bloc.add(AddPlayerEventCommit(
        newPlayer: Player((b) => b
          ..name = _name
          ..jerseyNumber = _jerseyNumber ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: BlocProvider.of<AddPlayerBloc>(context),
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          // Pass back the player uid.
          Navigator.pop(context, state.uid);
        }
        if (state is AddItemSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
      },
      child: BlocBuilder(
        bloc: BlocProvider.of<AddPlayerBloc>(context),
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
                      hintText: Messages.of(context).playerName,
                      labelText: Messages.of(context).playerName,
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
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.people),
                      hintText: Messages.of(context).jersyNumber,
                      labelText: Messages.of(context).jersyNumber,
                    ),
                    onSaved: (String str) {
                      _jerseyNumber = str;
                    },
                    autovalidate: false,
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
                          textTheme: ButtonTextTheme.primary,
                          elevation: 2,
                          icon: Icon(Icons.save),
                          label: Text(Messages.of(context).saveButton,
                              style: Theme.of(context).textTheme.button),
                          onPressed: () => _saveForm(
                              BlocProvider.of<AddPlayerBloc>(context)),
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
