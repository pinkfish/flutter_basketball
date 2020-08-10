import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';
import '../team/winrecord.dart';

part 'leagueortournamentteam.g.dart';

///
/// Team associated with a league or tournament.  A single team can
/// be associated with multiple divisons/seasons.
///
abstract class LeagueOrTournamentTeam
    implements Built<LeagueOrTournamentTeam, LeagueOrTournamentTeamBuilder> {
  String get uid;

  /// The uid of the season of the team associated with this league.
  /// This will only be set if there is a team associated.  At this point
  /// the inviteEmail will be cleared.
  String get seasonUid;

  /// The UID for the real team this is associated with.
  String get teamUid;

  /// The uid of the league/tourment divison the team is in.
  String get leagueOrTournamentDivisonUid;

  /// Name of the team in respect to this tournament/league.
  String get name;

  /// The win record of this team indexed by the divison.
  BuiltMap<String, WinRecord> get record;

  LeagueOrTournamentTeam._();
  factory LeagueOrTournamentTeam([updates(LeagueOrTournamentTeamBuilder b)]) =
      _$LeagueOrTournamentTeam;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(LeagueOrTournamentTeam.serializer, this);
  }

  static LeagueOrTournamentTeam fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        LeagueOrTournamentTeam.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentTeam> get serializer =>
      _$leagueOrTournamentTeamSerializer;

  @override
  String toString() {
    return 'LeagueOrTournamentTeam{uid: $uid, seasonUid: $seasonUid, teamUid: $teamUid, leagueOrTournamentDivisonUid: $leagueOrTournamentDivisonUid, name: $name, record: $record}';
  }
}
