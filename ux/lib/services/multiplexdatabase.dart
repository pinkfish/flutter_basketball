import 'dart:async';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/invites/invite.dart';
import 'package:basketballdata/data/user.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/firestoredatabase.dart';
import 'package:basketballstats/services/sqflitedatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'sqldbraw.dart';

class MultiplexDatabase extends BasketballDatabase {
  final FirestoreDatabase _fs;
  final SqlfliteDatabase _sql;
  final StreamController<bool> _controller = StreamController<bool>();
  final FirebaseAnalytics _analyticsSubsystem;
  final SQLDBRaw _sqldbRaw;

  Stream<bool> _stream;
  bool useSql = true;

  MultiplexDatabase(bool forceSql, this._analyticsSubsystem, this._sqldbRaw)
      : _fs = FirestoreDatabase(_analyticsSubsystem),
        _sql = SqlfliteDatabase(_sqldbRaw) {
    _stream = _controller.stream.asBroadcastStream();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      bool oldSql = useSql;
      if (user != null) {
        _fs.userUid = user.uid;
        _fs.userEmail = user.email;
        useSql = false || forceSql;
      } else {
        useSql = true;
      }
      if (oldSql != useSql) {
        _analyticsSubsystem
            .logEvent(name: "FirestoreDB", parameters: {"enabled": useSql});
        _controller.add(useSql);
      }
    });
    FirebaseAuth.instance.onAuthStateChanged.listen((FirebaseUser user) {
      bool oldSql = useSql;
      if (user != null) {
        _fs.userUid = user.uid;
        useSql = false || forceSql;
      } else {
        useSql = true;
      }
      if (oldSql != useSql) {
        _analyticsSubsystem
            .logEvent(name: "FirestoreDB", parameters: {"enabled": useSql});
        _controller.add(useSql);
      }
    });
    _sqldbRaw.open().catchError((e, trace) {
      Crashlytics.instance.recordError(e, trace);
    });
  }

  Future<void> waitTillOpen() async {
    await _sqldbRaw.getDatabase();
    return;
  }

  @override
  Future<String> addGame({Game game, BuiltList<Player> guestPlayers}) {
    if (useSql)
      return _sql.addGame(game: game, guestPlayers: guestPlayers);
    else
      return _fs.addGame(game: game, guestPlayers: guestPlayers);
  }

  @override
  Future<void> addGameEvent({GameEvent event}) {
    if (useSql)
      return _sql.addGameEvent(event: event);
    else
      return _fs.addGameEvent(event: event);
  }

  @override
  Future<void> addGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    if (useSql)
      return _sql.addGamePlayer(
          gameUid: gameUid, playerUid: playerUid, opponent: opponent);
    else
      return _fs.addGamePlayer(
          gameUid: gameUid, playerUid: playerUid, opponent: opponent);
  }

  @override
  Future<String> addTeam({Team team, Season season}) {
    if (useSql)
      return _sql.addTeam(team: team, season: season);
    else
      return _fs.addTeam(team: team, season: season);
  }

  @override
  Future<void> addSeasonPlayer({String seasonUid, String playerUid}) {
    if (useSql)
      return _sql.addSeasonPlayer(seasonUid: seasonUid, playerUid: playerUid);
    else
      return _fs.addSeasonPlayer(seasonUid: seasonUid, playerUid: playerUid);
  }

  @override
  Future<void> deleteGame({String gameUid}) {
    if (useSql)
      return _sql.deleteGame(gameUid: gameUid);
    else
      return _fs.deleteGame(gameUid: gameUid);
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) {
    if (useSql)
      return _sql.deleteGameEvent(gameEventUid: gameEventUid);
    else
      return _fs.deleteGameEvent(gameEventUid: gameEventUid);
  }

  @override
  Future<void> deleteGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    if (useSql)
      return _sql.deleteGamePlayer(
          gameUid: gameUid, playerUid: playerUid, opponent: opponent);
    else
      return _fs.deleteGamePlayer(
          gameUid: gameUid, playerUid: playerUid, opponent: opponent);
  }

  @override
  Future<void> deleteTeam({String teamUid}) {
    if (useSql)
      return _sql.deleteTeam(teamUid: teamUid);
    else
      return _fs.deleteTeam(teamUid: teamUid);
  }

  @override
  Future<void> deleteSeasonPlayer({String seasonUid, String playerUid}) {
    if (useSql)
      return _sql.deleteSeasonPlayer(
          seasonUid: seasonUid, playerUid: playerUid);
    else
      return _fs.deleteSeasonPlayer(seasonUid: seasonUid, playerUid: playerUid);
  }

  @override
  Stream<Player> getPlayer({String playerUid}) {
    if (useSql)
      return _sql.getPlayer(playerUid: playerUid);
    else
      return _fs.getPlayer(playerUid: playerUid);
  }

  @override
  Stream<Game> getGame({String gameUid}) {
    if (useSql)
      return _sql.getGame(gameUid: gameUid);
    else
      return _fs.getGame(gameUid: gameUid);
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() {
    if (useSql)
      return _sql.getAllTeams();
    else
      return _fs.getAllTeams();
  }

  @override
  Stream<BuiltList<Invite>> getAllInvites(String email) {
    if (useSql)
      return _sql.getAllInvites(email);
    else
      return _fs.getAllInvites(email);
  }

  @override
  Future<void> updateGame({Game game}) {
    if (useSql)
      return _sql.updateGame(game: game);
    else
      return _fs.updateGame(game: game);
  }

  @override
  Future<void> updateTeam({Team team}) {
    if (useSql)
      return _sql.updateTeam(team: team);
    else
      return _fs.updateTeam(team: team);
  }

  @override
  Future<void> updatePlayer({Player player}) {
    if (useSql)
      return _sql.updatePlayer(player: player);
    else
      return _fs.updatePlayer(player: player);
  }

  @override
  Stream<BuiltList<Season>> getTeamSeasons({String teamUid}) {
    if (useSql)
      return _sql.getTeamSeasons(teamUid: teamUid);
    else
      return _fs.getTeamSeasons(teamUid: teamUid);
  }

  @override
  Future<String> addPlayer({Player player}) {
    if (useSql)
      return _sql.addPlayer(player: player);
    else
      return _fs.addPlayer(player: player);
  }

  @override
  Stream<Team> getTeam({String teamUid}) {
    if (useSql)
      return _sql.getTeam(teamUid: teamUid);
    else
      return _fs.getTeam(teamUid: teamUid);
  }

  @override
  Future<void> deletePlayer({String playerUid}) {
    if (useSql)
      return _sql.deletePlayer(playerUid: playerUid);
    else
      return _fs.deletePlayer(playerUid: playerUid);
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) {
    if (useSql)
      return _sql.getGameEvents(gameUid: gameUid);
    else
      return _fs.getGameEvents(gameUid: gameUid);
  }

  @override
  Stream<bool> get onDatabaseChange => _stream;

  @override
  Stream<BuiltList<Game>> getGamesForPlayer({String playerUid}) {
    if (useSql)
      return _sql.getGamesForPlayer(playerUid: playerUid);
    else
      return _fs.getGamesForPlayer(playerUid: playerUid);
  }

  @override
  Future<void> updateGamePlayerData(
      {String gameUid,
      String playerUid,
      bool opponent,
      PlayerGameSummary summary}) {
    if (useSql)
      return _sql.updateGamePlayerData(
          playerUid: playerUid,
          gameUid: gameUid,
          opponent: opponent,
          summary: summary);
    else
      return _fs.updateGamePlayerData(
          playerUid: playerUid,
          gameUid: gameUid,
          opponent: opponent,
          summary: summary);
  }

  @override
  Future<String> addSeason({String teamUid, Season season}) {
    if (useSql)
      return _sql.addSeason(teamUid: teamUid, season: season);
    else
      return _fs.addSeason(teamUid: teamUid, season: season);
  }

  @override
  Future<void> deleteSeason({String seasonUid}) {
    if (useSql)
      return _sql.deleteSeason(seasonUid: seasonUid);
    else
      return _fs.deleteSeason(seasonUid: seasonUid);
  }

  @override
  Future<void> updateSeason({Season season}) {
    if (useSql)
      return _sql.updateSeason(season: season);
    else
      return _fs.updateSeason(season: season);
  }

  @override
  Stream<Season> getSeason({String seasonUid}) {
    if (useSql)
      return _sql.getSeason(seasonUid: seasonUid);
    else
      return _fs.getSeason(seasonUid: seasonUid);
  }

  @override
  Stream<BuiltList<Game>> getSeasonGames({String seasonUid}) {
    if (useSql)
      return _sql.getSeasonGames(seasonUid: seasonUid);
    else
      return _fs.getSeasonGames(seasonUid: seasonUid);
  }

  @override
  Future<String> addUser({User user}) {
    if (useSql)
      return _sql.addUser(user: user);
    else
      return _fs.addUser(user: user);
  }

  @override
  Stream<User> getUser({String userUid}) {
    if (useSql)
      return _sql.getUser(userUid: userUid);
    else
      return _fs.getUser(userUid: userUid);
  }

  @override
  Future<void> updateUser({User user}) {
    if (useSql)
      return _sql.updateUser(user: user);
    else
      return _fs.updateUser(user: user);
  }

  @override
  Future<String> addMedia({MediaInfo media}) {
    if (useSql)
      return _sql.addMedia(media: media);
    else
      return _fs.addMedia(media: media);
  }

  @override
  Future<void> deleteMedia({String mediaInfoUid}) {
    if (useSql)
      return _sql.deleteMedia(mediaInfoUid: mediaInfoUid);
    else
      return _fs.deleteMedia(mediaInfoUid: mediaInfoUid);
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForGame({String gameUid}) {
    if (useSql)
      return _sql.getMediaForGame(gameUid: gameUid);
    else
      return _fs.getMediaForGame(gameUid: gameUid);
  }

  @override
  Stream<MediaInfo> getMediaInfo({String mediaInfoUid}) {
    if (useSql)
      return _sql.getMediaInfo(mediaInfoUid: mediaInfoUid);
    else
      return _fs.getMediaInfo(mediaInfoUid: mediaInfoUid);
  }

  @override
  Future<void> updateMediaInfoThumbnail(
      {MediaInfo mediaInfo, String thumbnailUrl}) {
    if (useSql)
      return _sql.updateMediaInfoThumbnail(
          mediaInfo: mediaInfo, thumbnailUrl: thumbnailUrl);
    else
      return _fs.updateMediaInfoThumbnail(
          mediaInfo: mediaInfo, thumbnailUrl: thumbnailUrl);
  }

  @override
  Future<void> deleteInvite({String inviteUid}) {
    if (useSql)
      return _sql.deleteInvite(inviteUid: inviteUid);
    else
      return _fs.deleteInvite(inviteUid: inviteUid);
  }

  @override
  Stream<Invite> getInvite({String inviteUid}) {
    if (useSql)
      return _sql.getInvite(inviteUid: inviteUid);
    else
      return _fs.getInvite(inviteUid: inviteUid);
  }

  @override
  Future<String> addInvite({Invite invite}) {
    if (useSql)
      return _sql.addInvite(invite: invite);
    else
      return _fs.addInvite(invite: invite);
  }

  @override
  String get userUid {
    if (useSql)
      return _sql.userUid;
    else
      return _fs.userUid;
  }
}
