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

class SeasonExpansionPanel extends ExpansionPanel {
  final Season season;
  final OnGameCallback onGameTapped;
  final bool initiallyExpanded;
  final bool loadGames;
  final bool isExpanded;
  final String currentSeason;

  SeasonExpansionPanel(
      {@required this.season,
      this.onGameTapped,
      this.currentSeason,
      this.loadGames = false,
      this.isExpanded = false,
      this.initiallyExpanded = false})
      : super(
          headerBuilder: (BuildContext context, bool expanded) {
            return ListTile(
              leading: Icon(MdiIcons.calendar),
              title: season.uid == currentSeason
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          season.name,
                          textScaleFactor: 1.2,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          Messages.of(context).currentSeason,
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                  : Text(
                      season.name,
                      textScaleFactor: 1.2,
                      textAlign: TextAlign.end,
                    ),
              subtitle: Text(
                Messages.of(context)
                    .winLoss(season.summary.wins, season.summary.loses, 0),
              ),
            );
          },
          isExpanded: isExpanded,
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
                                (Game g) =>
                                GameTile(
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
