import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'playersummarydata.dart';
import 'serializers.dart';

part 'playerteamsummary.g.dart';

///
/// This is the player summary for the game.  Tracks per period
/// details about the game.
///
abstract class PlayerTeamSummary
    implements Built<PlayerTeamSummary, PlayerTeamSummaryBuilder> {
  BuiltMap<GamePeriod, PlayerSummaryData> get perSeason;

  bool get playing;

  static void _initializeBuilder(PlayerTeamSummaryBuilder b) =>
      b..playing = true;

  PlayerTeamSummary._();

  factory PlayerTeamSummary([updates(PlayerTeamSummaryBuilder b)]) =
      _$PlayerTeamSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerTeamSummary.serializer, this);
  }

  static PlayerTeamSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(PlayerTeamSummary.serializer, jsonData);
  }

  static Serializer<PlayerTeamSummary> get serializer =>
      _$playerTeamSummarySerializer;

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
