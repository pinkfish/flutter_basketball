import 'package:basketballdata/data/user.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../data/game.dart';
import '../data/gameevent.dart';
import '../data/player.dart';
import '../data/playergamesummary.dart';
import '../data/season.dart';
import '../data/team.dart';

///
/// Interface to load all the data from the database.
///
abstract class BasketballDatabase {
  /// Gets all the currently known teams.
  Stream<BuiltList<Team>> getAllTeams();

  /// Gets all the currently known games for this season.
  Stream<BuiltList<Game>> getSeasonGames({@required String seasonUid});

  /// Gets all the currently known seasons for this team.
  Stream<BuiltList<Season>> getTeamSeasons({@required String teamUid});

  /// Gets all the updates for this specific team.
  Stream<Team> getTeam({@required String teamUid});

  /// Gets all the updates for this speific game.
  Stream<Game> getGame({@required String gameUid});

  /// Gets all the updates for this speific season.
  Stream<Season> getSeason({@required String seasonUid});

  /// Gets all the updates for this speific user.
  Stream<User> getUser({@required String userUid});

  /// Loads all the game events for this game.
  Stream<BuiltList<GameEvent>> getGameEvents({@required String gameUid});

  /// Loads all the game events for this game.
  Stream<BuiltList<Game>> getGamesForPlayer({@required String playerUid});

  /// Gets the stream associated with this specific player.
  Stream<Player> getPlayer({@required String playerUid});

  /// Adds the game event into the database
  Future<void> addGameEvent({@required GameEvent event});

  /// Adds a new team into the database
  Future<String> addTeam({@required Team team, @required Season season});

  /// Adds a new game into the database
  Future<String> addGame({@required Game game});

  /// Adds a new season into the database
  Future<String> addSeason({@required String teamUid, @required Season season});

  // Adds a user into the database
  Future<String> addUser({@required User user});

  /// Updates the team in the database.
  Future<void> updateTeam({@required Team team});

  /// Updates the game in the database.
  Future<void> updateGame({@required Game game});

  /// Updates the season in the database.
  Future<void> updateSeason({@required Season season});

  /// Updates the season in the database.
  Future<void> updateUser({@required User user});

  /// Updates the game in the database.
  Future<void> updateGamePlayerData(
      {@required String gameUid,
      @required String playerUid,
      @required bool opponent,
      @required PlayerGameSummary summary});

  /// Updates the player in the database.
  Future<void> updatePlayer({@required Player player});

  Future<void> deletePlayer({@required String playerUid});

  Future<void> deleteGame({@required String gameUid});

  Future<void> deleteTeam({@required String teamUid});

  Future<void> deleteSeason({@required String seasonUid});

  Future<void> deleteGameEvent({@required String gameEventUid});

  Future<void> deleteGamePlayer(
      {@required String gameUid,
      @required String playerUid,
      @required bool opponent});

  Future<void> deleteSeasonPlayer(
      {@required String seasonUid, @required String playerUid});

  Future<void> addGamePlayer(
      {@required String gameUid,
      @required String playerUid,
      @required bool opponent});

  Future<void> addSeasonPlayer(
      {@required String seasonUid, @required String playerUid});

  Future<String> addPlayer({@required Player player});

  ///
  /// Returns a stream that says if the underlying database
  /// changed for some reason.
  ///
  Stream<bool> get onDatabaseChange;
}
