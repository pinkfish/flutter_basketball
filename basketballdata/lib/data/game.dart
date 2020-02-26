import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameevent.dart';
import 'serializers.dart';

part 'game.g.dart';

abstract class Game implements Built<Game, GameBuilder> {
  @nullable
  String get uid;
  DateTime get eventTime;
  String get location;
  BuiltMap<String, GameEvent> get events;
  BuiltMap<String, bool> get playerUids;

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
