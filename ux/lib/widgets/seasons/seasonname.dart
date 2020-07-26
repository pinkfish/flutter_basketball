import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/bloc/singleseasonbloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../messages.dart';

///
/// Shows the details on the season by giving the name and jersey number.
///
class SeasonName extends StatelessWidget {
  final String seasonUid;
  final double textScaleFactor;
  final TextStyle style;

  static Map<String, String> _nameCache = {};

  SeasonName(
      {@required this.seasonUid, this.textScaleFactor = 1.0, this.style});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: Key("season$seasonUid"),
      create: (BuildContext context) => SingleSeasonBloc(
          seasonUid: this.seasonUid,
          db: BlocProvider.of<TeamsBloc>(context).db),
      child: Builder(
        builder: (BuildContext context) {
          return BlocBuilder(
            bloc: BlocProvider.of<SingleSeasonBloc>(context),
            builder: (BuildContext context, SingleSeasonBlocState state) {
              if (_nameCache.containsKey(seasonUid) &&
                  !(state is SingleSeasonLoaded)) {
                return Text(
                  _nameCache[seasonUid],
                  style: style ?? Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textScaleFactor: textScaleFactor,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SingleSeasonDeleted) {
                return Text(
                  Messages.of(context).unknown,
                  style: style ?? Theme.of(context).textTheme.headline6,
                  textScaleFactor: textScaleFactor,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SingleSeasonUninitialized) {
                return Text(
                  Messages.of(context).loadingText,
                  style: style ?? Theme.of(context).textTheme.headline6,
                  textScaleFactor: textScaleFactor,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.start,
                );
              }
              if (state is SingleSeasonLoaded) {
                _nameCache[seasonUid] = state.season.name;
                return Text(
                  state.season.name,
                  style: style ?? Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textScaleFactor: textScaleFactor,
                  textAlign: TextAlign.start,
                );
              }
              return Text(
                Messages.of(context).unknown,
                style: style ?? Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.start,
                textScaleFactor: textScaleFactor,
              );
            },
          );
        },
      ),
    );
  }
}
