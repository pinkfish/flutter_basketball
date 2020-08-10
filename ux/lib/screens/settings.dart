import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:localstorage/localstorage.dart';
import 'package:settings_ui/settings_ui.dart';

import '../messages.dart';
import '../services/localstoragedata.dart';

///
/// Shows settings for the app.
///
class SettingsScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    var localstorage = RepositoryProvider.of<LocalStorage>(context);
    var mode = ThemeMode.values.firstWhere(
        (element) => element.toString() == localstorage.getItem("ThemeMode"),
        orElse: () => ThemeMode.dark);
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).settings),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Messages.of(context).uxSettingsSection,
            tiles: [
              SettingsTile.switchTile(
                title: Messages.of(context).lightMode,
                leading: Icon(Icons.lightbulb_outline),
                switchValue: mode == ThemeMode.light,
                onToggle: (bool value) {
                  Hive.box(LocalStorageData.settingsBox).put(
                      LocalStorageData.themeMode,
                      value
                          ? ThemeMode.light.toString()
                          : ThemeMode.dark.toString());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
