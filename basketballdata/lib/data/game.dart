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
  String get opponent;
  String get teamUid;
  BuiltMap<String, PlayerSummary> get playerUids;
  BuiltMap<String, PlayerSummary> get opponentUids;
  GameSummary get summary;
  PlayerSummary get allPlayers;
  PlayerSummary get opponentPlayers;

  static void _initializeBuilder(GameBuilder b) => b
    ..summary = GameSummaryBuilder()
    ..allPlayers = PlayerSummaryBuilder()
    ..opponentPlayers = PlayerSummaryBuilder()
    ..opponent = "unknown"
    ..opponentUids.putIfAbsent("default", () => PlayerSummary());

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
