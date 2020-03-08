import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'serializers.dart';

part 'playersummary.g.dart';

abstract class PlayerSummary
    implements Built<PlayerSummary, PlayerSummaryBuilder> {
  BuiltMap<GamePeriod, PlayerSummaryData> get perPeriod;

  bool get currentlyPlaying;

  bool get playing;

  static void _initializeBuilder(PlayerSummaryBuilder b) => b
    ..currentlyPlaying = false
    ..playing = true;

  PlayerSummary._();

  factory PlayerSummary([updates(PlayerSummaryBuilder b)]) = _$PlayerSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerSummary.serializer, this);
  }

  static PlayerSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(PlayerSummary.serializer, jsonData);
  }

  static Serializer<PlayerSummary> get serializer => _$playerSummarySerializer;

  @memoized
  PlayerSummaryData get fullData {
    PlayerSummaryDataBuilder b = PlayerSummaryDataBuilder();
    for (var s in perPeriod.values) {
      b.steals += s.steals;
      b.turnovers += s.turnovers;
      b.assists += s.assists;
      b.blocks += s.blocks;
      b.defensiveRebounds += s.defensiveRebounds;
      b.offensiveRebounds += s.offensiveRebounds;
      b.fouls += s.fouls;
      b.one.made += s.one.made;
      b.one.attempts += s.one.attempts;
      b.two.made += s.two.made;
      b.two.attempts += s.two.attempts;
      b.three.made += s.three.made;
      b.three.attempts += s.three.attempts;
    }
    return b.build();
  }
}

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
    ..assists = 0;

  PlayerSummaryData._();
  factory PlayerSummaryData([updates(PlayerSummaryDataBuilder b)]) =
      _$PlayerSummaryData;

  static Serializer<PlayerSummaryData> get serializer =>
      _$playerSummaryDataSerializer;
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
