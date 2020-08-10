library serializers;

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game/attendance.dart';
import 'package:basketballdata/data/leagueortournament/leagueortournamentdivision.dart';
import 'package:basketballdata/data/leagueortournament/leagueortournamentseason.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'bloc/data/singleplayerstate.dart';
import 'bloc/data/singleseasonstate.dart';
import 'bloc/data/singleteamstate.dart';
import 'bloc/data/teamsblocstate.dart';
import 'data/ant/broadcast.dart';
import 'data/ant/broadcaststatus.dart';
import 'data/ant/broadcasttype.dart';
import 'data/game/game.dart';
import 'data/game/gameevent.dart';
import 'data/game/gameeventtype.dart';
import 'data/game/gameofficalresults.dart';
import 'data/game/gameperiod.dart';
import 'data/game/gameplace.dart';
import 'data/game/gameshareddata.dart';
import 'data/game/gamesummary.dart';
import 'data/game/playergamesummary.dart';
import 'data/invites/invitetoteam.dart';
import 'data/invites/invitetype.dart';
import 'data/leagueortournament/leagueortournament.dart';
import 'data/media/mediainfo.dart';
import 'data/media/mediatype.dart';
import 'data/player/player.dart';
import 'data/player/playersummarydata.dart';
import 'data/season/playerseasonsummary.dart';
import 'data/season/season.dart';
import 'data/season/seasonsummary.dart';
import 'data/team/opponent.dart';
import 'data/team/team.dart';
import 'data/team/teamuser.dart';
import 'data/team/winrecord.dart';
import 'data/timestampserializer.dart';
import 'data/uploaddata.dart';
import 'data/user.dart';

part 'serializers.g.dart';

///
/// Collection of generated serializers for the built_value chat example.
///
@SerializersFor([
  Attendance,
  Broadcast,
  BroadcastType,
  BroadcastStatus,
  Game,
  GameEvent,
  GameEventType,
  GameEventLocation,
  GameOfficalResults,
  GamePeriod,
  GamePlace,
  GameSharedData,
  GameSummary,
  InviteToTeam,
  InviteType,
  LeagueOrTournament,
  LeagueOrTournamentDivison,
  LeagueOrTournamentSeason,
  MadeAttempt,
  MediaInfo,
  MediaType,
  Opponent,
  PlayerGameSummary,
  PlayerSummaryData,
  PlayerSeasonSummary,
  Player,
  Season,
  SeasonSummary,
  Team,
  TeamUser,
  TeamsBlocState,
  TeamsBlocUninitialized,
  TeamsBlocLoaded,
  TeamsBlocStateType,
  SinglePlayerState,
  SinglePlayerStateType,
  SinglePlayerLoaded,
  SinglePlayerDeleted,
  SinglePlayerUninitialized,
  SinglePlayerSaveSuccessful,
  SinglePlayerSaveFailed,
  SinglePlayerSaving,
  SingleTeamState,
  SingleTeamStateType,
  SingleTeamLoaded,
  SingleTeamDeleted,
  SingleTeamUninitialized,
  SingleTeamSaveSuccessful,
  SingleTeamSaveFailed,
  SingleTeamSaving,
  SingleSeasonState,
  SingleSeasonStateType,
  SingleSeasonLoaded,
  SingleSeasonDeleted,
  SingleSeasonUninitialized,
  SingleSeasonSaveSuccessful,
  SingleSeasonSaveFailed,
  SingleSeasonSaving,
  UploadData,
  User,
  WinRecord,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(TimestampSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
