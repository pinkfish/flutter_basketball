// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'ant/broadcast.dart';
import 'game.dart';
import 'gameevent.dart';
import 'gameeventtype.dart';
import 'gameperiod.dart';
import 'gamesummary.dart';
import 'mediainfo.dart';
import 'mediatype.dart';
import 'player.dart';
import 'playergamesummary.dart';
import 'playerseasonsummary.dart';
import 'playersummarydata.dart';
import 'season.dart';
import 'seasonsummary.dart';
import 'team.dart';
import 'teamuser.dart';
import 'timestampserializer.dart';
import 'user.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the built_value chat example.
@SerializersFor([
  Broadcast,
  Game,
  GameEvent,
  GameEventType,
  GameEventLocation,
  GamePeriod,
  GameSummary,
  MadeAttempt,
  MediaInfo,
  MediaType,
  PlayerGameSummary,
  PlayerSummaryData,
  PlayerSeasonSummary,
  Player,
  Season,
  SeasonSummary,
  Team,
  TeamUser,
  User,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(TimestampSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
