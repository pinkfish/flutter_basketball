import 'package:flutter/material.dart';

import '../messages.dart';

class StatsDrawer extends Drawer {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
          ),
          child: Text(Messages.of(context).title),
        ),
        ListTile(
          title: Text(Messages.of(context).about),
          leading: const Icon(Icons.help),
          onTap: () {
            Navigator.popAndPushNamed(context, "/About");
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    );
  }
}
