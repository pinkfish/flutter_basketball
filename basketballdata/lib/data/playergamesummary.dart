import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'playersummarydata.dart';
import 'serializers.dart';

part 'playergamesummary.g.dart';

///
/// This is the player summary for the game.  Tracks per period
/// details about the game.
///
abstract class PlayerGameSummary
    implements Built<PlayerGameSummary, PlayerGameSummaryBuilder> {
  BuiltMap<GamePeriod, PlayerSummaryData> get perPeriod;

  bool get currentlyPlaying;

  bool get playing;

  static void _initializeBuilder(PlayerGameSummaryBuilder b) => b
    ..currentlyPlaying = false
    ..playing = true;

  PlayerGameSummary._();

  factory PlayerGameSummary([updates(PlayerGameSummaryBuilder b)]) =
      _$PlayerGameSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerGameSummary.serializer, this);
  }

  static PlayerGameSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(PlayerGameSummary.serializer, jsonData);
  }

  static Serializer<PlayerGameSummary> get serializer =>
      _$playerGameSummarySerializer;

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
