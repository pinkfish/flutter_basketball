import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';
import '../player/playersummarydata.dart';

part 'playerseasonsummary.g.dart';

///
/// This is the player summary for the season.
///
abstract class PlayerSeasonSummary
    implements Built<PlayerSeasonSummary, PlayerSeasonSummaryBuilder> {
  PlayerSummaryData get summary;

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
}
