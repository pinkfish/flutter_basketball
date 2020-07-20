import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import '../serializers.dart';
import 'gameofficalresults.dart';
import 'gameplace.dart';

part 'gameshareddata.g.dart';

enum EventType { Game, Practice, Event }

///
/// In the case of league games, this is the bit that is shared across all
/// the games.
///
abstract class GameSharedData
    implements Built<GameSharedData, GameSharedDataBuilder> {
  // This is only valid in a special event.
  String get name;
  String get uid;
  num get time;
  String get timezone;
  num get endTime;
  EventType get type;
  GamePlace get place;
  GameOfficalResults get officialResults;

  /// The league associated with this game, null if there is none.
  @nullable
  String get leagueUid;

  /// The divison in the league assocoiated with this game, null if there is none.
  @nullable
  String get leagueDivisionUid;

  GameSharedData._();
  factory GameSharedData([updates(GameSharedDataBuilder b)]) = _$GameSharedData;

  Location get location {
    return getLocation(this.timezone);
  }

  TZDateTime get tzTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, time);
  TZDateTime get tzEndTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, endTime);

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameSharedData.serializer, this);
  }

  static GameSharedData fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameSharedData.serializer, jsonData);
  }

  static Serializer<GameSharedData> get serializer =>
      _$gameSharedDataSerializer;
}
