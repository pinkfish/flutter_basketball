import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameeventtype.dart';
import 'gameperiod.dart';
import 'serializers.dart';

part 'gameevent.g.dart';

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

  Duration get eventTimeline;

  @nullable
  GameEventLocation get courtLocation;

  @nullable
  String get replacementPlayerUid;

  static void _initializeBuilder(GameEventBuilder b) =>
      b..eventTimeline = Duration(seconds: 0);

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

abstract class GameEventLocation
    implements Built<GameEventLocation, GameEventLocationBuilder> {
  double get x;

  double get y;

  GameEventLocation._();

  factory GameEventLocation([updates(GameEventLocationBuilder b)]) =
      _$GameEventLocation;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameEventLocation.serializer, this);
  }

  static GameEventLocation fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameEventLocation.serializer, jsonData);
  }

  static Serializer<GameEventLocation> get serializer =>
      _$gameEventLocationSerializer;
}
