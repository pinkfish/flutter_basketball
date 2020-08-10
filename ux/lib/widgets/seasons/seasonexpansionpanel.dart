import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../messages.dart';
import '../deleted.dart';
import '../game/gametile.dart';
import '../loading.dart';

typedef void OnGameCallback(String gameUid);

///
/// SHows the season in the current team with all the exviting games
///
class SeasonExpansionPanel extends ExpansionPanel {
  final Season season;
  final OnGameCallback onGameTapped;
  final bool initiallyExpanded;
  final bool loadGames;
  final bool isExpanded;
  final String currentSeason;
  final Widget buttonBar;

  SeasonExpansionPanel(
      {@required this.season,
      this.onGameTapped,
      this.currentSeason,
      this.buttonBar,
      this.loadGames = false,
      this.isExpanded = false,
      this.initiallyExpanded = false})
      : super(
          headerBuilder: (BuildContext context, bool expanded) {
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: season.uid == currentSeason
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                season.name,
                                style: Theme.of(context).textTheme.headline4,
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                Messages.of(context).currentSeason,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context).accentColor),
                              ),
                            ],
                          )
                        : Text(
                            season.name,
                            style: Theme.of(context).textTheme.headline4,
                            textAlign: TextAlign.end,
                          ),
                    subtitle: Text(
                        Messages.of(context).winLoss(
                            season.summary.wins, season.summary.losses, 0),
                        style: Theme.of(context).textTheme.subtitle2),
                  ),
                  buttonBar ?? SizedBox(height: 0),
                ],
              ),
            );
          },
          isExpanded: isExpanded,
          body: BlocProvider(
            create: (BuildContext context) => SingleSeasonBloc(
              seasonUid: season.uid,
              db: RepositoryProvider.of<BasketballDatabase>(context),
              crashes: RepositoryProvider.of<CrashReporting>(context),
            ),
            child: Builder(
              builder: (BuildContext context) => AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: BlocBuilder(
                    cubit: BlocProvider.of<SingleSeasonBloc>(context),
                    builder: (BuildContext context, SingleSeasonState state) {
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
                      if (state is SingleSeasonUninitialized) {
                        return Center(
                          child: LoadingWidget(),
                        );
                      }

                      if (!state.loadedGames) {
                        return ListTile(
                          leading: Icon(MdiIcons.loading),
                          title: Text(Messages.of(context).loadingText),
                        );
                      }

                      return Column(
                          children: state.games
                              .map(
                                (Game g) => GameTile(
                                  game: g,
                                  onTap: () => onGameTapped(g.uid),
                                ),
                              )
                              .toList());
                    }),
              ),
            ),
          ),
        );
}
