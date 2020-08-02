import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';
import 'invite.dart';
import 'invitetype.dart';

part 'invitetoteam.g.dart';

///
/// This is used in parts of the api to handle an invite to the team without
/// everything that is needed for it.
///
abstract class InviteTeamData
    implements Built<InviteTeamData, InviteTeamDataBuilder> {
  String get email;
  String get playerName;

  factory InviteTeamData([void Function(InviteTeamDataBuilder) updates]) =
      _$InviteTeamData;
  InviteTeamData._();
}

///
/// Invited to the team.
///
abstract class InviteToTeam
    implements Invite, Built<InviteToTeam, InviteToTeamBuilder> {
  String get teamName;
  String get teamUid;

  InviteType getType() => InviteType.Team;

  factory InviteToTeam([void Function(InviteToTeamBuilder) updates]) =
      _$InviteToTeam;
  InviteToTeam._();

  static void _initializeBuilder(InviteToTeamBuilder b) =>
      b..invite = InviteType.Team;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(InviteToTeam.serializer, this);
  }

  static InviteToTeam fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(InviteToTeam.serializer, jsonData);
  }

  static Serializer<InviteToTeam> get serializer => _$inviteToTeamSerializer;
}
