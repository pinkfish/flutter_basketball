import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';

part 'playersummarydata.g.dart';

///
/// This is data about the player per season/per period depending on where
/// the data is stored.
///
abstract class PlayerSummaryData
    implements Built<PlayerSummaryData, PlayerSummaryDataBuilder> {
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

  bool get onCourt;

  bool get playing;

  @memoized
  int get points => one.made + two.made * 2 + three.made * 3;

  static void _initializeBuilder(PlayerSummaryDataBuilder b) => b
    ..one = MadeAttemptBuilder()
    ..two = MadeAttemptBuilder()
    ..three = MadeAttemptBuilder()
    ..steals = 0
    ..offensiveRebounds = 0
    ..defensiveRebounds = 0
    ..fouls = 0
    ..turnovers = 0
    ..blocks = 0
    ..onCourt = false
    ..playing = true
    ..assists = 0;

  PlayerSummaryData._();

  factory PlayerSummaryData([updates(PlayerSummaryDataBuilder b)]) =
      _$PlayerSummaryData;

  static Serializer<PlayerSummaryData> get serializer =>
      _$playerSummaryDataSerializer;
}

///
/// Keeps track of the total made vs attempts.
///
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
