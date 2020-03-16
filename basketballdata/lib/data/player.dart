import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'playergamesummary.dart';
import 'serializers.dart';

part 'player.g.dart';

abstract class Player implements Built<Player, PlayerBuilder> {
  @nullable
  String get uid;

  @nullable
  String get photoUid;

  String get jerseyNumber;

  String get name;

  BuiltMap<String, PlayerGameSummary> get perSeason;

  Player._();

  factory Player([updates(PlayerBuilder b)]) = _$Player;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Player.serializer, this);
  }

  static Player fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Player.serializer, jsonData);
  }

  static Serializer<Player> get serializer => _$playerSerializer;
}
