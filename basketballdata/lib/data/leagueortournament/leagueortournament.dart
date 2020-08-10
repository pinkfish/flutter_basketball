import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';
import '../team/gender.dart';

part 'leagueortournament.g.dart';

///
/// The type of the league or tournment.
///
enum LeagueOrTournamentType {
  Tournament,
  League,
}

///
/// Keeps track of the league details.
///
abstract class LeagueOrTournament
    implements Built<LeagueOrTournament, LeagueOrTournamentBuilder> {
  String get uid;
  String get name;
  String get photoUrl;
  String get currentSeason;
  String get shortDescription;
  String get longDescription;
  LeagueOrTournamentType get type;
  Gender get gender;
  Sport get sport;
  String get userUid;

  /// List of admin user ids. This is all user ids (not players)
  BuiltSet<String> get adminsUids;

  /// List of member user ids.  This is all user ids (not players)
  BuiltSet<String> get members;

  LeagueOrTournament._();
  factory LeagueOrTournament([updates(LeagueOrTournamentBuilder b)]) =
      _$LeagueOrTournament;

  bool isUserMember(String myUid) {
    return adminsUids.contains(myUid) || members.contains(myUid);
  }

  /// Is the current user a member (or admin)?
  bool isMember() {
    return isUserMember(userUid);
  }

  bool isUserAdmin(String myUid) {
    return adminsUids.contains(myUid);
  }

  /// Is the current user an admin?
  bool isAdmin() {
    return isUserAdmin(userUid);
  }

  @override
  String toString() {
    return 'LeagueOrTournament{uid: $uid, name: $name, photoUrl: '
        '$photoUrl, currentSeason: $currentSeason, shortDescription: $shortDescription, '
        'longDescription: $longDescription, type: $type, adminsUids: $adminsUids, '
        'members: $members, sport: $sport, gender: $gender}';
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(LeagueOrTournament.serializer, this);
  }

  static LeagueOrTournament fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(LeagueOrTournament.serializer, jsonData);
  }

  static Serializer<LeagueOrTournament> get serializer =>
      _$leagueOrTournamentSerializer;
}
