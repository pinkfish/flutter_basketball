import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../data/game/game.dart';
import '../data/game/gameevent.dart';
import '../data/game/playergamesummary.dart';
import '../data/invites/invite.dart';
import '../data/media/mediainfo.dart';
import '../data/player/player.dart';
import '../data/season/season.dart';
import '../data/team/team.dart';
import '../data/user.dart';

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

  /// Gets all the current invites for us.
  Stream<BuiltList<Invite>> getAllInvites(String email);

  /// Gets all the updates for this specific team.
  Stream<Team> getTeam({@required String teamUid});

  /// Gets all the updates for this speific game.
  Stream<Game> getGame({@required String gameUid});

  /// Gets all the updates for this speific season.
  Stream<Season> getSeason({@required String seasonUid});

  /// Gets all the updates for this speific user.
  Stream<User> getUser({@required String userUid});

  /// Gets all the updates for this speific media info blob.
  Stream<MediaInfo> getMediaInfo({@required String mediaInfoUid});

  /// Loads all the game events for this game.
  Stream<BuiltList<GameEvent>> getGameEvents({@required String gameUid});

  /// Loads all the media for this game.
  Stream<BuiltList<MediaInfo>> getMediaForGame({@required String gameUid});

  /// Loads all the game events for this game.
  Stream<BuiltList<Game>> getGamesForPlayer({@required String playerUid});

  /// Gets the stream associated with this specific player.
  Stream<Player> getPlayer({@required String playerUid});

  /// Gets the stream associated with this specific invite.
  Stream<Invite> getInvite({@required String inviteUid});

  /// Gets the UID for the game event to write out.
  Future<String> getGameEventId();

  /// Adds the game event into the database
  Future<void> setGameEvent({@required GameEvent event});

  /// Adds the game event into the database
  Future<String> addMedia({@required MediaInfo media});

  /// Adds a new team into the database
  Future<String> addTeam({@required Team team, @required Season season});

  /// Adds a new game into the database
  Future<String> addGame({@required Game game, BuiltList<Player> guestPlayers});

  /// Adds a new season into the database
  Future<String> addSeason({@required String teamUid, @required Season season});

  // Adds a user into the database
  Future<String> addUser({@required User user});

  // Adds an invite into the database
  Future<String> addInvite({@required Invite invite});

  /// Updates the team in the database.
  Future<void> updateTeam({@required Team team});

  /// Updates the game in the database.
  Future<void> updateGame({@required Game game});

  /// Updates the season in the database.
  Future<void> updateSeason({@required Season season});

  /// Updates the season in the database.
  Future<void> updateUser({@required User user});

  /// Updates the season in the database.
  Future<void> updateMediaInfoThumbnail(
      {@required MediaInfo mediaInfo, @required String thumbnailUrl});

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

  Future<void> deleteMedia({@required String mediaInfoUid});

  Future<void> deleteInvite({@required String inviteUid});

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

  /// The current user Uid.
  String get userUid;
}
