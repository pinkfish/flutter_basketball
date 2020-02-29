import 'package:basketballdata/data/gamesummary.dart';
import 'package:basketballdata/data/playersummary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'game.g.dart';

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

  static void _initializeBuilder(GameBuilder b) => b
    ..summary = GameSummaryBuilder()
    ..playerSummaery = PlayerSummaryBuilder()
    ..opponentSummary = PlayerSummaryBuilder()
    ..opponentName = "unknown"
    ..opponents.putIfAbsent("default", () => PlayerSummary());

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
