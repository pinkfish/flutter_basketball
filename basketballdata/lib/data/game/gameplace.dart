import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';

part 'gameplace.g.dart';

abstract class GamePlace implements Built<GamePlace, GamePlaceBuilder> {
  String get name;
  String get placeId;
  String get address;
  String get notes;
  num get latitude;
  num get longitude;
  bool get unknown;

  GamePlace._();
  factory GamePlace([updates(GamePlaceBuilder b)]) = _$GamePlace;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GamePlace.serializer, this);
  }

  static GamePlace fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GamePlace.serializer, jsonData);
  }

  static Serializer<GamePlace> get serializer => _$gamePlaceSerializer;
}
