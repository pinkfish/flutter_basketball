import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

///
/// Shows a widget for the team.
///
class TeamWidget extends StatelessWidget {
  final Team team;
  final GestureTapCallback onTap;

  TeamWidget(this.team, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(team.name),
      leading: team.photoUid != null
          ? Image.network(team.photoUid)
          : Icon(Icons.people),
      onTap: () => _onTap(context),
    );
  }

  void _onTap(BuildContext context) {
    Navigator.pushNamed(context, "/TeamDetails/" + team.uid);
  }
}
