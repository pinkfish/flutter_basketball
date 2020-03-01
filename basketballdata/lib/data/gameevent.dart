import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'serializers.dart';

part 'gameevent.g.dart';

enum GameEventType {
  Made,
  Missed,
  Foul,
  Sub,
  OffsensiveRebound,
  DefensiveRebound,
  Block,
  Assist,
  Steal,
  Turnover,
  PeriodStart,
}

abstract class GameEvent implements Built<GameEvent, GameEventBuilder> {
  @nullable
  String get uid;
  DateTime get timestamp;
  GameEventType get type;
  int get points;
  String get gameUid;
  String get playerUid;
  bool get opponent;
  GamePeriod get period;
  @nullable
  String get replacementPlayerUid;

  GameEvent._();
  factory GameEvent([updates(GameEventBuilder b)]) = _$GameEvent;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameEvent.serializer, this);
  }

  static GameEvent fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameEvent.serializer, jsonData);
  }

  static Serializer<GameEvent> get serializer => _$gameEventSerializer;
}
