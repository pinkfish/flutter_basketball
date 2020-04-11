import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'teamuser.g.dart';

abstract class TeamUser implements Built<TeamUser, TeamUserBuilder> {
  bool get enabled;

  static void _initializeBuilder(TeamUserBuilder b) => b..enabled = true;

  TeamUser._();

  factory TeamUser([void Function(TeamUserBuilder) updates]) = _$TeamUser;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(TeamUser.serializer, this);
  }

  static TeamUser fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(TeamUser.serializer, json);
  }

  static Serializer<TeamUser> get serializer => _$teamUserSerializer;
}
