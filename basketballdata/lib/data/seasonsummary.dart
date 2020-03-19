import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'seasonsummary.g.dart';

///
/// Data class representing a season.
///
abstract class SeasonSummary
    implements Built<SeasonSummary, SeasonSummaryBuilder> {
  int get wins;

  int get loses;

  int get pointsFor;

  int get pointsAgainst;

  SeasonSummary._();

  static void _initializeBuilder(SeasonSummaryBuilder b) => b
    ..pointsFor = 0
    ..pointsAgainst = 0
    ..wins = 0
    ..loses = 0;

  factory SeasonSummary([void Function(SeasonSummaryBuilder) updates]) =
      _$SeasonSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SeasonSummary.serializer, this);
  }

  static SeasonSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SeasonSummary.serializer, jsonData);
  }

  static Serializer<SeasonSummary> get serializer => _$seasonSummarySerializer;
}
