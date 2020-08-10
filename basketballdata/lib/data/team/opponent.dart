import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';
import 'winrecord.dart';

part 'opponent.g.dart';

///
/// An opponent for a team with all the opponent metadata associated with it.
///
abstract class Opponent implements Built<Opponent, OpponentBuilder> {
  String get name;
  String get teamUid;
  @nullable
  String get contact;
  String get uid;
  BuiltList<String> get leagueTeamUid;
  BuiltMap<String, WinRecord> get record;

  Opponent._();
  factory Opponent([updates(OpponentBuilder b)]) = _$Opponent;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Opponent.serializer, this);
  }

  static Opponent fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Opponent.serializer, jsonData);
  }

  static Serializer<Opponent> get serializer => _$opponentSerializer;
}
