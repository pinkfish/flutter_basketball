import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'gameperiod.dart';
import 'gamesummary.dart';
import 'playergamesummary.dart';
import 'serializers.dart';

part 'game.g.dart';

enum GameResult { Win, Tie, Loss }

///
/// Data about the game itself.
///
abstract class Game implements Built<Game, GameBuilder> {
  @nullable
  String get uid;

  String get seasonUid;

  DateTime get eventTime;

  String get location;

  String get opponentName;

  String get teamUid;

  String get playbackUrl;

  String get streamingUrl;

  /// Summary for this specific player.
  BuiltMap<String, PlayerGameSummary> get players;

  /// Summary for this specific opponent.
  BuiltMap<String, PlayerGameSummary> get opponents;

  /// Summary for the overall game (this is only pts for vs against).
  GameSummary get summary;

  /// Total summary for the game for this players.
  PlayerGameSummary get playerSummaery;

  /// Total summary for the game for the opponents.
  PlayerGameSummary get opponentSummary;

  GamePeriod get currentPeriod;

  /// Tracks when this game is running from.  This is used when the
  /// game starts to track the current position in the game.
  @nullable
  DateTime get runningFrom;

  /// How long into the game we are currently.
  Duration get gameTime;

  /// Works out what the result of the game is based on the summary
  /// data.
  @memoized
  GameResult get result => summary.pointsFor > summary.pointsAgainst
      ? GameResult.Win
      : summary.pointsFor == summary.pointsAgainst
          ? GameResult.Tie
          : GameResult.Loss;

  /// The current time of the game, used when making events.
  Duration get currentGameTime {
    int diff = 0;
    if (runningFrom != null) {
      diff += DateTime.now().difference(runningFrom).inSeconds;
    }
    diff += gameTime.inSeconds;
    return Duration(seconds: diff);
  }

  static void _initializeBuilder(GameBuilder b) => b
    ..summary = GameSummaryBuilder()
    ..playerSummaery = PlayerGameSummaryBuilder()
    ..opponentSummary = PlayerGameSummaryBuilder()
    ..opponentName = "unknown"
    ..seasonUid = ""
    ..currentPeriod = GamePeriod.NotStarted
    ..gameTime = Duration(milliseconds: 0);

  Game._();
  factory Game([updates(GameBuilder b)]) = _$Game;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Game.serializer, this);
  }

  static Game fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Game.serializer, jsonData);
  }

  static Serializer<Game> get serializer => _$gameSerializer;
}
