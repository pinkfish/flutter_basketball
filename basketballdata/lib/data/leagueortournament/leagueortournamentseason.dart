import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';

part 'leagueortournamentseason.g.dart';

///
/// The season associated with this league or tournment.  The
/// games connect to the season, the season is part of the division
/// and the divison is part of the league.
///
abstract class LeagueOrTournamentSeason
    implements
        Built<LeagueOrTournamentSeason, LeagueOrTournamentSeasonBuilder> {
  String get name;
  String get uid;
  String get leagueOrTournmentUid;

  /// List of admin user ids. This is all user ids (not players)
  BuiltSet<String> get adminsUids;

  /// List of member user ids.  This is all user ids (not players)
  BuiltSet<String> get members;

  LeagueOrTournamentSeason._();
  factory LeagueOrTournamentSeason(
          [updates(LeagueOrTournamentSeasonBuilder b)]) =
      _$LeagueOrTournamentSeason;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(LeagueOrTournamentSeason.serializer, this);
  }

  static LeagueOrTournamentSeason fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        LeagueOrTournamentSeason.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentSeason> get serializer =>
      _$leagueOrTournamentSeasonSerializer;
}
