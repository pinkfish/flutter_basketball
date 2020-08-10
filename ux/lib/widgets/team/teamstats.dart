import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/widgets/player/playerdropdown.dart';
import 'package:basketballstats/widgets/seasons/seasondropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../deleted.dart';
import '../loading.dart';
import 'teamseasonstats.dart';

///
/// Shows statistics for the overall team, showing trends over
/// a season.
///
class TeamStatsWidget extends StatefulWidget {
  final String teamUid;

  TeamStatsWidget({@required this.teamUid});

  @override
  State<StatefulWidget> createState() {
    return _TeamStatsWidgetState();
  }
}

class _TeamStatsWidgetState extends State<TeamStatsWidget> {
  String _currentSeasonUid;
  String _playerUid = PlayerDropDown.allValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<SingleTeamBloc>(context),
      builder: (BuildContext context, SingleTeamState state) {
        if (state is SingleTeamLoaded && !state.loadedSeasons) {
          BlocProvider.of<SingleTeamBloc>(context).add(SingleTeamLoadSeasons());
        }
        if (state is SingleTeamUninitialized) {
          return LoadingWidget();
        }
        if (state is SingleTeamDeleted) {
          return DeletedWidget();
        }
        if (_currentSeasonUid == null) {
          _currentSeasonUid = state.team.currentSeasonUid;
        }
        return BlocProvider(
          create: (BuildContext context) => SingleSeasonBloc(
              db: RepositoryProvider.of<BasketballDatabase>(context),
              seasonUid: _currentSeasonUid,
              crashes: RepositoryProvider.of<CrashReporting>(context)),
          child: Builder(
            builder: (BuildContext context) => Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Season drop down.
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: SeasonDropDown(
                          value: _currentSeasonUid,
                          isExpanded: true,
                          onChanged: (v) =>
                              setState(() => _currentSeasonUid = v),
                        ),
                      ),
                    ),
                    // Player-multi-select button.
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: PlayerDropDown(
                          value: _playerUid,
                          isExpanded: true,
                          onChanged: (s) => setState(() => _playerUid = s),
                          includeAll: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: BlocConsumer(
                      cubit: BlocProvider.of<SingleSeasonBloc>(context),
                      listener:
                          (BuildContext context, SingleSeasonState state) {
                        if (state is SingleSeasonLoaded && !state.loadedGames) {
                          BlocProvider.of<SingleSeasonBloc>(context)
                              .add(SingleSeasonLoadGames());
                        }
                      },
                      builder: (BuildContext context, SingleSeasonState state) {
                        if (state is SingleSeasonUninitialized) {
                          return LoadingWidget();
                        }
                        if (state is SingleSeasonDeleted) {
                          return DeletedWidget();
                        }
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: TeamSeasonStats(
                            state: state,
                            gameData: ShowGameData.All,
                            playerUid: _playerUid,
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
