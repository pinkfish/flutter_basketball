import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/savingoverlay.dart';
import 'package:basketballstats/widgets/usertile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../messages.dart';

class TeamEditScreen extends StatelessWidget {
  final String teamUid;

  TeamEditScreen({@required this.teamUid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SingleTeamBloc(
          teamUid: teamUid,
          db: RepositoryProvider.of<BasketballDatabase>(context)),
      child: Builder(
        builder: (BuildContext context) => BlocBuilder(
          cubit: BlocProvider.of<SingleTeamBloc>(context),
          builder: (BuildContext context, SingleTeamBlocState state) =>
              Scaffold(
            appBar: AppBar(
                title: Text(state.team?.name ?? Messages.of(context).unknown)),
            body: _EditTeamForm(),
          ),
        ),
      ),
    );
  }
}

class _EditTeamForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditTeamFormState();
  }
}

class _EditTeamFormState extends State<_EditTeamForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = "";
  bool saving = false;
  bool usersIsExpanded = false;

  void initState() {
    super.initState();
  }

  void _saveForm(SingleTeamBloc bloc) {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(Messages.of(context).errorForm)));

      return;
    }
    _formKey.currentState.save();

    bloc.add(SingleTeamUpdate(
      team: Team((b) => b..name = _name),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      cubit: BlocProvider.of<SingleTeamBloc>(context),
      listener: (BuildContext context, SingleTeamBlocState state) {
        if (state is SingleTeamSaveSuccessful) {
          print("Pop add done");
          Navigator.pop(context);
        }
        if (state is SingleTeamSaveFailed) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(Messages.of(context).saveFailed)));
        }
        if (state is SingleTeamLoaded) {
          if (_name.isEmpty) {
            _name = state.team.name;
          }
        }
      },
      builder: (BuildContext context, SingleTeamBlocState state) {
        if (state is SingleTeamUninitialized) {
          return SavingOverlay(
            saving: true,
            child: Text(Messages.of(context).loadingText),
          );
        }
        return SavingOverlay(
          saving: state is SingleTeamSaving,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ButtonBar(
                    children: [
                      FlatButton(
                        key: Key("cancelButtonTeam"),
                        child: Text(
                            MaterialLocalizations.of(context).cancelButtonLabel,
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
                            _saveForm(BlocProvider.of<SingleTeamBloc>(context)),
                      ),
                      RaisedButton.icon(
                        key: Key("addUserButtonTeam"),
                        textTheme: ButtonTextTheme.primary,
                        elevation: 2,
                        icon: Icon(Icons.person_add),
                        label: Text(Messages.of(context).addUserButton,
                            style: Theme.of(context).textTheme.button),
                        onPressed: () =>
                            _saveForm(BlocProvider.of<SingleTeamBloc>(context)),
                      ),
                    ],
                  ),
                ),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      usersIsExpanded = !isExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      isExpanded: usersIsExpanded,
                      headerBuilder: (BuildContext context, bool expanded) =>
                          Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(Messages.of(context).usersTitle,
                            style: Theme.of(context).textTheme.headline6),
                      ),
                      body: Column(
                        children: state.team.users.keys
                            .map((u) => UserTile(userUid: u))
                            .toList(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
