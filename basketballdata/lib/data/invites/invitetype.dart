import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invitetype.g.dart';

///
/// The types of invites that exist.
///
class InviteType extends EnumClass {
  static Serializer<InviteType> get serializer => _$inviteTypeSerializer;

  static const InviteType Team = _$team;

  const InviteType._(String name) : super(name);

  static BuiltSet<InviteType> get values => _$values;

  static InviteType valueOf(String name) => _$valueOf(name);
}
