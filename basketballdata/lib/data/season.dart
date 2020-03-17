import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'playerseasonsummary.dart';
import 'serializers.dart';

part 'season.g.dart';

///
/// Data class representing a season.
///
abstract class Season implements Built<Season, SeasonBuilder> {
  @nullable
  String get uid;

  String get name;

  String get teamUid;

  BuiltMap<String, PlayerSeasonSummary> get playerUids;

  Season._();

  factory Season([updates(SeasonBuilder b)]) = _$Season;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Season.serializer, this);
  }

  static Season fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Season.serializer, jsonData);
  }

  static Serializer<Season> get serializer => _$seasonSerializer;
}
