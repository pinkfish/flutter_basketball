import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'playersummarydata.dart';
import 'serializers.dart';

part 'playerseasonsummary.g.dart';

///
/// This is the player summary for the game.  Tracks per period
/// details about the game.
///
abstract class PlayerSeasonSummary
    implements Built<PlayerSeasonSummary, PlayerSeasonSummaryBuilder> {
  BuiltMap<GamePeriod, PlayerSummaryData> get perSeason;

  bool get playing;

  static void _initializeBuilder(PlayerSeasonSummaryBuilder b) =>
      b..playing = true;

  PlayerSeasonSummary._();

  factory PlayerSeasonSummary([updates(PlayerSeasonSummaryBuilder b)]) =
      _$PlayerSeasonSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerSeasonSummary.serializer, this);
  }

  static PlayerSeasonSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        PlayerSeasonSummary.serializer, jsonData);
  }

  static Serializer<PlayerSeasonSummary> get serializer =>
      _$playerSeasonSummarySerializer;

  @memoized
  PlayerSummaryData get fullData {
    PlayerSummaryDataBuilder b = PlayerSummaryDataBuilder();
    for (var s in perSeason.values) {
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
