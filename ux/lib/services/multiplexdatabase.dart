import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/firestoredatabase.dart';
import 'package:basketballstats/services/sqflitedatabase.dart';
import 'package:built_collection/built_collection.dart';

class MultiplexDatabase extends BasketballDatabase {
  FirestoreDatabase _fs;
  SqlfliteDatabase _sql;
  bool useSql = true;

  Future<void> open() async {
    _fs = new FirestoreDatabase();
    _sql = SqlfliteDatabase();
    await _sql.open();
  }

  @override
  Future<String> addGame({String teamUid, Game game}) {
    if (useSql)
      return _sql.addGame(teamUid: teamUid, game: game);
    else
      return _fs.addGame(teamUid: teamUid, game: game);
  }

  @override
  Future<void> addGameEvent({String gameUid, GameEvent event}) {
    if (useSql)
      return _sql.addGameEvent(gameUid: gameUid, event: event);
    else
      return _fs.addGameEvent(gameUid: gameUid, event: event);
  }

  @override
  Future<String> addGamePlayer({String gameUid, Player player}) {
    if (useSql)
      return _sql.addGamePlayer(gameUid: gameUid, player: player);
    else
      return _fs.addGamePlayer(gameUid: gameUid, player: player);
  }

  @override
  Future<String> addTeam({Team team}) {
    if (useSql)
      return _sql.addTeam(team: team);
    else
      return _fs.addTeam(team: team);
  }

  @override
  Future<String> addTeamPlayer({String teamUid, Player player}) {
    if (useSql)
      return _sql.addTeamPlayer(teamUid: teamUid, player: player);
    else
      return _fs.addTeamPlayer(teamUid: teamUid, player: player);
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
  Future<void> deleteGamePlayer({String gameUid, String playerUid}) {
    if (useSql)
      return _sql.deleteGamePlayer(gameUid: gameUid, playerUid: playerUid);
    else
      return _fs.deleteGamePlayer(gameUid: gameUid, playerUid: playerUid);
  }

  @override
  Future<void> deleteTeam({String teamUid}) {
    if (useSql)
      return _sql.deleteTeam(teamUid: teamUid);
    else
      return _fs.deleteTeam(teamUid: teamUid);
  }

  @override
  Future<void> deleteTeamPlayer({String teamUid, String playerUid}) {
    if (useSql)
      return _sql.deleteTeamPlayer(teamUid: teamUid, playerUid: playerUid);
    else
      return _fs.deleteTeamPlayer(teamUid: teamUid, playerUid: playerUid);
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
  Stream<BuiltList<Team>> getTeams() {
    if (useSql)
      return _sql.getTeams();
    else
      return _fs.getTeams();
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
  Stream<BuiltList<Game>> getTeamGames({String teamUid}) {
    if (useSql)
      return _sql.getTeamGames(teamUid: teamUid);
    else
      return _fs.getTeamGames(teamUid: teamUid);
  }
}
