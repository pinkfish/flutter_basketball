// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library serializers;

import 'package:basketballdata/data/leagueortournament/leagueortournamentdivision.dart';
import 'package:basketballdata/data/leagueortournament/leagueortournamentseason.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'ant/broadcast.dart';
import 'ant/broadcaststatus.dart';
import 'ant/broadcasttype.dart';
import 'game/game.dart';
import 'game/gameevent.dart';
import 'game/gameeventtype.dart';
import 'game/gameofficalresults.dart';
import 'game/gameperiod.dart';
import 'game/gameplace.dart';
import 'game/gameshareddata.dart';
import 'game/gamesummary.dart';
import 'game/playergamesummary.dart';
import 'invites/invitetoteam.dart';
import 'invites/invitetype.dart';
import 'leagueortournament/leagueortournament.dart';
import 'media/mediainfo.dart';
import 'media/mediatype.dart';
import 'player/player.dart';
import 'player/playersummarydata.dart';
import 'season/playerseasonsummary.dart';
import 'season/season.dart';
import 'season/seasonsummary.dart';
import 'team/opponent.dart';
import 'team/team.dart';
import 'team/winrecord.dart';
import 'teamuser.dart';
import 'timestampserializer.dart';
import 'uploaddata.dart';
import 'user.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the built_value chat example.
@SerializersFor([
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
  UploadData,
  User,
  WinRecord,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(TimestampSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
