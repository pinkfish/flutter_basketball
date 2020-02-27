import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'playersummary.g.dart';

abstract class PlayerSummary
    implements Built<PlayerSummary, PlayerSummaryBuilder> {
  int get twoMade;
  int get twoAttempts;
  int get oneMade;
  int get oneAttempts;
  int get threeMade;
  int get threeAttempts;
  int get fouls;
  int get steals;
  int get offensiveRebounds;
  int get defensiveRebounds;

  PlayerSummary._();
  factory PlayerSummary([updates(PlayerSummaryBuilder b)]) = _$PlayerSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerSummary.serializer, this);
  }

  static PlayerSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(PlayerSummary.serializer, jsonData);
  }

  static Serializer<PlayerSummary> get serializer => _$playerSummarySerializer;
}
