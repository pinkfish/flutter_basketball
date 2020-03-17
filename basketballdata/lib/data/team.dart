import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'team.g.dart';

///
/// Data class associated with a team.
///
abstract class Team implements Built<Team, TeamBuilder> {
  @nullable
  String get uid;

  @nullable
  String get photoUid;

  String get name;

  @nullable
  String get currentSeasonUid;

  Team._();
  factory Team([updates(TeamBuilder b)]) = _$Team;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Team.serializer, this);
  }

  static Team fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Team.serializer, jsonData);
  }

  static Serializer<Team> get serializer => _$teamSerializer;
}
