import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';
import 'playersummarydata.dart';

part 'playerseasonsummary.g.dart';

///
/// This is the player summary for the game.  Tracks per period
/// details about the game.
///
abstract class PlayerSeasonSummary
    implements Built<PlayerSeasonSummary, PlayerSeasonSummaryBuilder> {
  PlayerSummaryData get summary;

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
}
