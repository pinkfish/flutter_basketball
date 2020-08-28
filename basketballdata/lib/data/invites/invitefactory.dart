import 'invite.dart';
import 'invitetoteam.dart';
import 'invitetype.dart';

///
/// Base class for all invites.
///
class InviteFactory {
  static Invite makeInviteFromJSON(String uid, Map<String, dynamic> data) {
    assert(uid != null);
    InviteType type = InviteType.values
        .firstWhere((InviteType ty) => ty.toString() == data["invite"]);
    switch (type) {
      case InviteType.Team:
        InviteToTeam ret = InviteToTeam.fromMap(data);
        return ret;
      default:
        throw new FormatException();
    }
  }
}
