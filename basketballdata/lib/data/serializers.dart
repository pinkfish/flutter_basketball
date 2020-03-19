// Copyright (c) 2016, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'game.dart';
import 'gameevent.dart';
import 'gameeventtype.dart';
import 'gameperiod.dart';
import 'gamesummary.dart';
import 'player.dart';
import 'playergamesummary.dart';
import 'playersummarydata.dart';
import 'playerseasonsummary.dart';
import 'season.dart';
import 'seasonsummary.dart';
import 'team.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the built_value chat example.
@SerializersFor([
  Game,
  GameEvent,
  GameEventType,
  GameEventLocation,
  GamePeriod,
  GameSummary,
  MadeAttempt,
  PlayerGameSummary,
  PlayerSummaryData,
  PlayerSeasonSummary,
  Player,
  Season,
  SeasonSummary,
  Team,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
