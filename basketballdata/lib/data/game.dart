import 'package:basketballdata/data/gamesummary.dart';
import 'package:basketballdata/data/playersummary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'serializers.dart';

part 'game.g.dart';

enum GameResult { Win, Tie, Loss }

abstract class Game implements Built<Game, GameBuilder> {
  @nullable
  String get uid;
  DateTime get eventTime;
  String get location;
  String get opponentName;
  String get teamUid;
  BuiltMap<String, PlayerSummary> get players;
  BuiltMap<String, PlayerSummary> get opponents;
  GameSummary get summary;
  PlayerSummary get playerSummaery;
  PlayerSummary get opponentSummary;
  GamePeriod get currentPeriod;

  @memoized
  GameResult get result => summary.pointsFor > summary.pointsAgainst
      ? GameResult.Win
      : summary.pointsFor == summary.pointsAgainst
          ? GameResult.Tie
          : GameResult.Loss;

  static void _initializeBuilder(GameBuilder b) => b
    ..summary = GameSummaryBuilder()
    ..playerSummaery = PlayerSummaryBuilder()
    ..opponentSummary = PlayerSummaryBuilder()
    ..opponentName = "unknown"
    ..currentPeriod = GamePeriod.NotStarted;

  Game._();
  factory Game([updates(GameBuilder b)]) = _$Game;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Game.serializer, this);
  }

  static Game fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Game.serializer, jsonData);
  }

  static Serializer<Game> get serializer => _$gameSerializer;
}
