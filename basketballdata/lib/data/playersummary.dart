import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'playersummary.g.dart';

abstract class PlayerSummary
    implements Built<PlayerSummary, PlayerSummaryBuilder> {
  MadeAttempt get one;
  MadeAttempt get two;
  MadeAttempt get three;
  int get fouls;
  int get steals;
  int get offensiveRebounds;
  int get defensiveRebounds;
  int get turnovers;
  int get blocks;
  int get assists;

  static void _initializeBuilder(PlayerSummaryBuilder b) => b
    ..one = MadeAttemptBuilder()
    ..two = MadeAttemptBuilder()
    ..three = MadeAttemptBuilder()
    ..steals = 0
    ..offensiveRebounds = 0
    ..defensiveRebounds = 0
    ..fouls = 0
    ..turnovers = 0
    ..blocks = 0
    ..assists = 0;

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

abstract class MadeAttempt implements Built<MadeAttempt, MadeAttemptBuilder> {
  int get made;
  int get attempts;

  static void _initializeBuilder(MadeAttemptBuilder b) => b
    ..made = 0
    ..attempts = 0;

  MadeAttempt._();
  factory MadeAttempt([updates(MadeAttemptBuilder b)]) = _$MadeAttempt;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(MadeAttempt.serializer, this);
  }

  static MadeAttempt fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(MadeAttempt.serializer, jsonData);
  }

  static Serializer<MadeAttempt> get serializer => _$madeAttemptSerializer;
}
