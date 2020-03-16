import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../deleted.dart';
import '../game/gametile.dart';
import '../loading.dart';

typedef void OnGameCallback(String gameUid);

class SeasonExpansionPanel extends ExpansionPanel {
  final Season season;
  final OnGameCallback onGameTapped;
  final bool initiallyExpanded;
  final bool loadGames;

  SeasonExpansionPanel(
      {@required this.season,
      this.onGameTapped,
      this.loadGames = false,
      this.initiallyExpanded = false})
      : super(
          headerBuilder: (BuildContext context, bool expanded) {
            return ListTile(
                leading: Icon(Icons.people),
                title: Text(
                  season.name,
                  textScaleFactor: 1.2,
                ));
          },
          body: BlocProvider(
            create: (BuildContext context) => SingleSeasonBloc(
              seasonUid: season.uid,
              db: RepositoryProvider.of<BasketballDatabase>(context),
            ),
            child: Builder(
              builder: (BuildContext context) => AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: BlocBuilder(
                    bloc: BlocProvider.of<SingleSeasonBloc>(context),
                    builder:
                        (BuildContext context, SingleSeasonBlocState state) {
                      if (state is SingleSeasonDeleted) {
                        return Center(
                          child: DeletedWidget(),
                        );
                      }
                      if (state is SingleSeasonLoaded &&
                          !state.loadedGames &&
                          loadGames) {
                        BlocProvider.of<SingleSeasonBloc>(context)
                            .add(SingleSeasonLoadGames());
                      }
                      if (state is SingleSeasonUninitialized &&
                          !state.loadedGames) {
                        return Center(
                          child: LoadingWidget(),
                        );
                      }

                      return Column(
                          children: state.games
                              .map(
                                (Game g) => GameTile(game: g),
                              )
                              .toList());
                    }),
              ),
            ),
          ),
        );
}
