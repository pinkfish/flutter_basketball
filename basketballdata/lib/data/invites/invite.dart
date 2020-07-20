import 'package:built_value/built_value.dart';

part 'invite.g.dart';

/// The type of the invite.
enum InviteType {
  Team,
}

///
/// Base class for all invites.
///
@BuiltValue(instantiable: false)
abstract class Invite {
  /// email invites.
  String get email;

  /// uid of the invite itself
  String get uid;

  // Who sent the invite.
  String get sentByUid;

  InviteType get invite;
}
