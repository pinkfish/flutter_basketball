import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializers.dart';
import 'gameperiod.dart';
import 'gamesummary.dart';

part 'gameofficalresults.g.dart';

enum OfficialResult { HomeTeamWon, AwayTeamWon, Tie, NotStarted, InProgress }

///
/// The offical results we have for this game.  This only exists when the
/// game is in a tournament or a league.
///
abstract class GameOfficalResults
    implements Built<GameOfficalResults, GameOfficalResultsBuilder> {
  BuiltMap<GamePeriod, GameSummary> get scores;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  @nullable
  String get homeTeamLeagueUid;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  @nullable
  String get awayTeamLeagueUid;

  OfficialResult get result;

  GameOfficalResults._();
  factory GameOfficalResults([updates(GameOfficalResultsBuilder b)]) =
      _$GameOfficalResults;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameOfficalResults.serializer, this);
  }

  static GameOfficalResults fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameOfficalResults.serializer, jsonData);
  }

  static Serializer<GameOfficalResults> get serializer =>
      _$gameOfficalResultsSerializer;
}
