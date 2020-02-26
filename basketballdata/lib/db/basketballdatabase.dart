import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../data/game.dart';
import '../data/gameevent.dart';
import '../data/player.dart';
import '../data/team.dart';

///
/// Interface to load all the data from the database.
///
abstract class BasketballDatabase {
  /// Gets all the currently known teams.
  Stream<BuiltList<Team>> getTeams();

  /// Gets all the currently known games for this team.
  Stream<BuiltList<Game>> getTeamGames({@required String teamUid});

  /// Gets all the updates for this speific game.
  Stream<Game> getGame({@required String gameUid});

  /// Gets the stream associated with this specific player.
  Stream<Player> getPlayer({@required String playerUid});

  /// Adds the game event into the database
  Future<void> addGameEvent(
      {@required String gameUid, @required GameEvent event});

  /// Adds a new team into the database
  Future<String> addTeam({@required Team team});

  /// Adds a new game into the database
  Future<String> addGame({@required String teamUid, @required Game game});

  /// Updates the team in the database.
  Future<void> updateTeam({@required Team team});

  /// Updates the game in the database.
  Future<void> updateGame({@required Game game});

  /// Updates the player in the database.
  Future<void> updatePlayer({@required Player player});

  Future<void> deleteGame({@required String gameUid});

  Future<void> deleteTeam({@required String teamUid});

  Future<void> deleteGameEvent({@required String gameEventUid});

  Future<void> deleteGamePlayer(
      {@required String gameUid, @required String playerUid});

  Future<void> deleteTeamPlayer(
      {@required String teamUid, @required String playerUid});

  Future<String> addGamePlayer(
      {@required String gameUid, @required Player player});

  Future<String> addTeamPlayer(
      {@required String teamUid, @required Player player});
}
