import 'dart:async';
import 'dart:convert';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/invites/invite.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/sqldbraw.dart';
import 'package:built_collection/built_collection.dart';
import 'package:event/event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

///
/// Interface to get all the data from the local sql database.
///
class SqlfliteDatabase extends BasketballDatabase {
  final Uuid uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});
  final SQLDBRaw _sqldbRaw;
  final Map<String, _TableChanger> _changers = {};

  SqlfliteDatabase(this._sqldbRaw);

  @override
  Future<String> addGame({Game game}) async {
    Database db = await _sqldbRaw.getDatabase();
    String uid = uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.gamesTable);
    Game newG = game.rebuild((b) => b..uid = uid);
    print('Inserting ${json.encode(newG.toMap())}');
    await db.insert(SQLDBRaw.gamesTable, {
      SQLDBRaw.indexColumn: uid,
      SQLDBRaw.secondaryIndexColumn: game.seasonUid,
      SQLDBRaw.dataColumn: json.encode(newG.toMap()),
    });
    _changeTableNotification(SQLDBRaw.gamesTable,
        uid: uid, secondaryUid: game.seasonUid);
    return uid;
  }

  @override
  Future<void> addGameEvent({GameEvent event}) async {
    Database db = await _sqldbRaw.getDatabase();

    String uid =
        event.uid ?? uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.gameEventsTable);
    GameEvent newEv = event.rebuild((b) => b..uid = uid);
    db.insert(SQLDBRaw.gameEventsTable, {
      SQLDBRaw.indexColumn: uid,
      SQLDBRaw.secondaryIndexColumn: event.gameUid,
      SQLDBRaw.dataColumn: json.encode(newEv.toMap())
    });
    _changeTableNotification(SQLDBRaw.gameEventsTable,
        uid: uid, secondaryUid: event.gameUid);
    return uid;
  }

  @override
  Future<void> addGamePlayer(
      {String gameUid, String playerUid, bool opponent}) async {
    Game t = await _getGame(gameUid: gameUid);
    if (opponent) {
      t = t.rebuild((b) =>
          b..opponents.putIfAbsent(playerUid, () => PlayerGameSummary()));
    } else {
      t = t.rebuild(
          (b) => b..players.putIfAbsent(playerUid, () => PlayerGameSummary()));
    }
    await updateGame(game: t);
    _changeTableNotification(SQLDBRaw.gamesTable,
        uid: gameUid, secondaryUid: t.seasonUid);
    return playerUid;
  }

  @override
  Future<String> addTeam({Team team, Season season}) async {
    Database db = await _sqldbRaw.getDatabase();
    String uid = uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.teamsTable);
    String seasonUid = uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.seasonsTable);
    Team newT = team.rebuild((b) => b
      ..uid = uid
      ..currentSeasonUid = seasonUid);
    Season newS = season.rebuild((b) => b
      ..teamUid = uid
      ..uid = seasonUid);
    await db.insert(SQLDBRaw.teamsTable, {
      SQLDBRaw.indexColumn: uid,
      SQLDBRaw.dataColumn: json.encode(newT.toMap()),
    });
    await db.insert(SQLDBRaw.seasonsTable, {
      SQLDBRaw.indexColumn: seasonUid,
      SQLDBRaw.secondaryIndexColumn: uid,
      SQLDBRaw.dataColumn: json.encode(newS.toMap()),
    });
    _changeTableNotification(SQLDBRaw.teamsTable, uid: uid);
    return uid;
  }

  @override
  Future<void> addSeasonPlayer({String seasonUid, String playerUid}) async {
    Season t = await _getSeason(seasonUid: seasonUid);
    await updateSeason(
        season: t.rebuild((b) =>
            b..playerUids.putIfAbsent(playerUid, () => PlayerSeasonSummary())));
    _changeTableNotification(SQLDBRaw.seasonsTable, uid: seasonUid);
    return playerUid;
  }

  @override
  Future<void> deleteGame({String gameUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    await db
        .delete(SQLDBRaw.gamesTable, where: "uid = ?", whereArgs: [gameUid]);
    _changeTableNotification(SQLDBRaw.gamesTable, uid: gameUid);
    return null;
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    GameEvent ev = await _getGameEvent(gameEventUid: gameEventUid);
    await db.delete(SQLDBRaw.gameEventsTable,
        where: "uid = ?", whereArgs: [gameEventUid]);
    _changeTableNotification(SQLDBRaw.gameEventsTable,
        uid: gameEventUid, secondaryUid: ev.gameUid);
    return null;
  }

  @override
  Future<void> deleteGamePlayer(
      {String gameUid, String playerUid, bool opponent}) async {
    Game t = await _getGame(gameUid: gameUid);
    if (opponent) {
      t = t.rebuild((b) => b..opponents.remove(playerUid));
    } else {
      t = t.rebuild((b) => b..players.remove(playerUid));
    }
    return updateGame(game: t);
  }

  @override
  Future<void> deleteInvite({String inviteUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    await db.delete(SQLDBRaw.invitesTable,
        where: "uid = ?", whereArgs: [inviteUid]);
    _changeTableNotification(SQLDBRaw.gamesTable, uid: inviteUid);
    return null;
  }

  @override
  Future<void> updateGamePlayerData(
      {String gameUid,
      String playerUid,
      bool opponent,
      PlayerGameSummary summary}) async {
    Game t = await _getGame(gameUid: gameUid);
    if (opponent) {
      t = t.rebuild((b) => b..opponents.putIfAbsent(playerUid, () => summary));
    } else {
      t = t.rebuild((b) => b..players.putIfAbsent(playerUid, () => summary));
    }
    return updateGame(game: t);
  }

  @override
  Future<void> deleteTeam({String teamUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    await db
        .delete(SQLDBRaw.teamsTable, where: "uid = ?", whereArgs: [teamUid]);
    _changeTableNotification(SQLDBRaw.teamsTable, uid: teamUid);
    return null;
  }

  @override
  Future<void> deletePlayer({String playerUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    await db.delete(SQLDBRaw.playersTable,
        where: "uid = ?", whereArgs: [playerUid]);
    _changeTableNotification(SQLDBRaw.playersTable, uid: playerUid);
    // TODO: Delete from the other places it is referenced too.
    return null;
  }

  @override
  Future<void> deleteSeason({String seasonUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    await db.delete(SQLDBRaw.seasonsTable,
        where: "uid = ?", whereArgs: [seasonUid]);
    _changeTableNotification(SQLDBRaw.seasonsTable, uid: seasonUid);
    // TODO: Delete from the other places it is referenced too.
    return null;
  }

  @override
  Future<void> deleteSeasonPlayer({String seasonUid, String playerUid}) async {
    Season s = await _getSeason(seasonUid: seasonUid);
    return updateSeason(
        season: s.rebuild((b) => b..playerUids.remove(playerUid)));
  }

  Future<Team> _getTeam({String teamUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(SQLDBRaw.teamsTable, where: "uid = ?", whereArgs: [teamUid]);
    print("Query $maps");
    if (maps.isEmpty) {
      return null;
    }
    return maps
        .map((Map<String, dynamic> e) =>
            Team.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .first;
  }

  Future<Season> _getSeason({String seasonUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(SQLDBRaw.seasonsTable, where: "uid = ?", whereArgs: [seasonUid]);
    print("Query $maps");
    if (maps.isEmpty) {
      return null;
    }
    return maps
        .map((Map<String, dynamic> e) =>
            Season.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .first;
  }

  @override
  Stream<Player> getPlayer({String playerUid}) async* {
    Database db = await _sqldbRaw.getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(SQLDBRaw.playersTable, where: "uid = ?", whereArgs: [playerUid]);
    print("Query $maps");
    yield maps
        .map((Map<String, dynamic> e) =>
            Player.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .first;

    var controller = _setupController(SQLDBRaw.playersTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change getPlayer $table");
        if (!db.isOpen) {
          // Exit out of here.
          return;
        }
        if (table.uid == playerUid) {
          final List<Map<String, dynamic>> maps = await db.query(
              SQLDBRaw.playersTable,
              where: "uid = ?",
              whereArgs: [playerUid]);
          yield maps
              .map((Map<String, dynamic> e) =>
                  Player.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
              .first;
        }
      }
    } finally {
      controller.close();
    }
  }

  Future<Game> _getGame({String gameUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(SQLDBRaw.gamesTable, where: "uid = ?", whereArgs: [gameUid]);
    if (maps.isEmpty) {
      return null;
    }
    Game g = maps
        .map((Map<String, dynamic> e) =>
            Game.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .first;
    return g;
  }

  Future<GameEvent> _getGameEvent({String gameEventUid}) async {
    Database db = await _sqldbRaw.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        SQLDBRaw.gameEventsTable,
        where: "uid = ?",
        whereArgs: [gameEventUid]);
    if (maps.isEmpty) {
      return null;
    }
    GameEvent g = maps
        .map((Map<String, dynamic> e) =>
            GameEvent.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .first;
    return g;
  }

  @override
  Stream<Game> getGame({String gameUid}) async* {
    yield await _getGame(gameUid: gameUid);
    Database db = await _sqldbRaw.getDatabase();
    var controller = _setupController(SQLDBRaw.gamesTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change getGame $table");
        if (!db.isOpen) {
          // Exit out of here.
          return;
        }
        if (table.secondaryUid == gameUid || table.uid == gameUid) {
          yield await _getGame(gameUid: gameUid);
        }
      }
    } finally {
      controller.close();
    }
  }

  @override
  Stream<Team> getTeam({String teamUid}) async* {
    yield await _getTeam(teamUid: teamUid);
    Database db = await _sqldbRaw.getDatabase();
    var controller = _setupController(SQLDBRaw.teamsTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change getTeam $table");
        if (!db.isOpen) {
          print("db is not open");
          // Exit out of here.
          return;
        }
        if (table.uid == teamUid || table.secondaryUid == teamUid) {
          print("yay us");
          yield await _getTeam(teamUid: teamUid);
        } else {
          print("no us $teamUid ${table.uid}");
        }
      }
    } finally {
      controller.close();
    }
  }

  @override
  Stream<Season> getSeason({String seasonUid}) async* {
    yield await _getSeason(seasonUid: seasonUid);
    Database db = await _sqldbRaw.getDatabase();
    var controller = _setupController(SQLDBRaw.seasonsTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change getTeam $table");
        if (!db.isOpen) {
          print("db is not open");
          // Exit out of here.
          return;
        }
        if (table.uid == seasonUid || table.secondaryUid == seasonUid) {
          print("yay us");
          yield await _getSeason(seasonUid: seasonUid);
        } else {
          print("no us $seasonUid ${table.uid}");
        }
      }
    } finally {
      controller.close();
    }
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() async* {
    Database db = await _sqldbRaw.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(SQLDBRaw.teamsTable);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Team.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .toList());
    print("getTeams waiting for change");
    var controller = _setupController(SQLDBRaw.teamsTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change getTeams $table");
        if (!db.isOpen) {
          print("db is not open");
          // Exit out of here.
          return;
        }
        final List<Map<String, dynamic>> maps =
            await db.query(SQLDBRaw.teamsTable);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Team.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
            .where((Team t) => t.uid != null)
            .toList());
      }
    } finally {
      controller.close();
    }
    print("Exit getTeams");
  }

  @override
  Future<void> updateGame({Game game}) async {
    Database db = await _sqldbRaw.getDatabase();
    db.update(
        SQLDBRaw.gamesTable,
        {
          SQLDBRaw.indexColumn: game.uid,
          SQLDBRaw.dataColumn: json.encode(game.toMap()),
        },
        where: 'uid = ?',
        whereArgs: [game.uid]);
    _changeTableNotification(SQLDBRaw.gamesTable,
        uid: game.uid, secondaryUid: game.seasonUid);
    return null;
  }

  @override
  Future<void> updateTeam({Team team}) async {
    Database db = await _sqldbRaw.getDatabase();
    db.update(
        SQLDBRaw.teamsTable,
        {
          SQLDBRaw.indexColumn: team.uid,
          SQLDBRaw.dataColumn: json.encode(team.toMap()),
        },
        where: "uid = ?",
        whereArgs: [team.uid]);
    _changeTableNotification(SQLDBRaw.teamsTable, uid: team.uid);
    return null;
  }

  @override
  Future<void> updatePlayer({Player player}) async {
    Database db = await _sqldbRaw.getDatabase();
    db.update(
        SQLDBRaw.playersTable,
        {
          SQLDBRaw.indexColumn: player.uid,
          SQLDBRaw.dataColumn: json.encode(player.toMap()),
        },
        where: "uid = ?",
        whereArgs: [player.uid]);

    _changeTableNotification(SQLDBRaw.playersTable, uid: player.uid);
    return null;
  }

  @override
  Future<void> updateSeason({Season season}) async {
    Database db = await _sqldbRaw.getDatabase();
    db.update(
        SQLDBRaw.seasonsTable,
        {
          SQLDBRaw.indexColumn: season.uid,
          SQLDBRaw.dataColumn: json.encode(season.toMap()),
        },
        where: "uid = ?",
        whereArgs: [season.uid]);

    _changeTableNotification(SQLDBRaw.seasonsTable, uid: season.uid);
    return null;
  }

  @override
  Stream<BuiltList<Game>> getSeasonGames({String seasonUid}) async* {
    print("Waiting for database");
    Database db = await _sqldbRaw.getDatabase();
    print("Got  database " + seasonUid);
    final List<Map<String, dynamic>> maps = await db.query(SQLDBRaw.gamesTable,
        where: SQLDBRaw.secondaryIndexColumn + " = ?", whereArgs: [seasonUid]);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Game.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .toList());
    var controller = _setupController(SQLDBRaw.gamesTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change $table");
        if (!db.isOpen) {
          // Exit out of here.
          return;
        }
        if (table.secondaryUid == seasonUid) {
          final List<Map<String, dynamic>> maps = await db.query(
              SQLDBRaw.gamesTable,
              where: SQLDBRaw.indexColumn + " = ?",
              whereArgs: [seasonUid]);
          yield BuiltList.from(maps
              .map((Map<String, dynamic> e) =>
                  Game.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
              .where((Game t) => t.uid != null)
              .toList());
        }
      }
    } finally {
      controller.close();
    }
  }

  @override
  Stream<BuiltList<Game>> getGamesForPlayer({String playerUid}) async* {
    // TODO: Work this one out...
  }

  @override
  Stream<BuiltList<Season>> getTeamSeasons({String teamUid}) async* {
    print("Waiting for database");
    Database db = await _sqldbRaw.getDatabase();
    print("Got  database " + teamUid);
    final List<Map<String, dynamic>> maps = await db.query(
        SQLDBRaw.seasonsTable,
        where: SQLDBRaw.secondaryIndexColumn + " = ?",
        whereArgs: [teamUid]);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Season.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .toList());
    var controller = _setupController(SQLDBRaw.seasonsTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change $table");
        if (!db.isOpen) {
          // Exit out of here.
          return;
        }
        if (table.secondaryUid == teamUid) {
          final List<Map<String, dynamic>> maps = await db.query(
              SQLDBRaw.seasonsTable,
              where: SQLDBRaw.indexColumn + " = ?",
              whereArgs: [teamUid]);
          yield BuiltList.from(maps
              .map((Map<String, dynamic> e) =>
                  Season.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
              .where((Season t) => t.uid != null)
              .toList());
        }
      }
    } finally {
      controller.close();
    }
  }

  @override
  Future<String> addPlayer({Player player}) async {
    print("Calling addPlayer");
    Database db = await _sqldbRaw.getDatabase();
    String uid = uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.playersTable);
    Player newP = player.rebuild((b) => b..uid = uid);
    print('Inserting ${json.encode(newP.toMap())}');
    await db.insert(SQLDBRaw.playersTable, {
      SQLDBRaw.indexColumn: uid,
      SQLDBRaw.dataColumn: json.encode(newP.toMap()),
    });
    print("Adding table to stream");
    _changeTableNotification(SQLDBRaw.playersTable, uid: uid);
    print("Done...");
    return uid;
  }

  @override
  Future<String> addSeason({String teamUid, Season season}) async {
    print("Calling addSeason");
    Database db = await _sqldbRaw.getDatabase();
    String uid = uuid.v5(Uuid.NAMESPACE_OID, SQLDBRaw.seasonsTable);
    Season newS = season.rebuild((b) => b
      ..uid = uid
      ..teamUid = teamUid);
    print('Inserting ${json.encode(newS.toMap())}');
    await db.insert(SQLDBRaw.seasonsTable, {
      SQLDBRaw.indexColumn: uid,
      SQLDBRaw.secondaryIndexColumn: teamUid,
      SQLDBRaw.dataColumn: json.encode(newS.toMap()),
    });
    print("Adding table to stream");
    _changeTableNotification(SQLDBRaw.seasonsTable,
        uid: uid, secondaryUid: teamUid);
    print("Done...");
    return uid;
  }

  BuiltList<GameEvent> _getGameEvents(List<Map<String, dynamic>> data) {
    var evs = data
        .map((Map<String, dynamic> e) =>
            GameEvent.fromMap(json.decode(e[SQLDBRaw.dataColumn])))
        .toList();
    evs.sort((GameEvent a, GameEvent b) => a.timestamp.compareTo(b.timestamp));
    return BuiltList.from(evs);
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    print("Waiting for database");
    Database db = await _sqldbRaw.getDatabase();
    print("Got  database " + gameUid);
    final List<Map<String, dynamic>> maps = await db.query(
        SQLDBRaw.gameEventsTable,
        where: SQLDBRaw.secondaryIndexColumn + " = ?",
        whereArgs: [gameUid]);
    print("Query $maps");
    yield _getGameEvents(maps);
    var controller = _setupController(SQLDBRaw.gameEventsTable);
    try {
      await for (_TableChange table in controller.stream) {
        print("Table change $table");
        if (!db.isOpen) {
          // Exit out of here.
          return;
        }
        if (table.secondaryUid == gameUid) {
          final List<Map<String, dynamic>> maps = await db.query(
              SQLDBRaw.gameEventsTable,
              where: SQLDBRaw.indexColumn + " = ?",
              whereArgs: [gameUid]);
          yield _getGameEvents(maps);
        }
      }
    } finally {
      controller.close();
    }
  }

  @override
  Stream<bool> get onDatabaseChange => null;

  // Cannot add a user when using the sql db.
  @override
  Future<String> addUser({User user}) {
    throw UnimplementedError();
  }

  // Cannot get a user when using the sql db.
  @override
  Stream<User> getUser({String userUid}) async* {
    yield null;
  }

  // Cannot update a user when using the sql db.
  @override
  Future<void> updateUser({User user}) {
    throw UnimplementedError();
  }

  @override
  Future<String> addMedia({MediaInfo media}) {
    // TODO: implement addMedia
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMedia({String mediaInfoUid}) {
    // TODO: implement deleteMedia
    throw UnimplementedError();
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForGame({String gameUid}) {
    // TODO: implement getMediaForGame
    throw UnimplementedError();
  }

  @override
  Stream<MediaInfo> getMediaInfo({String mediaInfoUid}) {
    // TODO: implement getMediaForGame
    throw UnimplementedError();
  }

  @override
  Stream<Invite> getInvite({String inviteUid}) {
    // TODO: implement getMediaForGame
    throw UnimplementedError();
  }

  @override
  Future<void> updateMediaInfoThumbnail(
      {MediaInfo mediaInfo, String thumbnailUrl}) {
    // TODO: implement updateMediaInfoThumbnail
    throw UnimplementedError();
  }

  void _changeTableNotification(String table,
      {String uid, String secondaryUid}) {
    if (!_changers.containsKey(table)) {
      _changers[table] = _TableChanger();
    }
    _changers[table].changeTable(uid, secondaryUid);
  }

  StreamController<_TableChange> _setupController(String table) {
    if (!_changers.containsKey(table)) {
      _changers[table] = _TableChanger();
    }
    var ctl = StreamController<_TableChange>();
    _changers[table].subscribeStram(ctl.sink);
    return ctl;
  }

  @override
  Stream<BuiltList<Invite>> getAllInvites(String email) async* {
    yield BuiltList<Invite>();
  }

  String get userUid => "local";
}

///
/// Used to track changes to the table
///
class _TableChange extends EventArgs {
  final String uid;
  final String secondaryUid;

  _TableChange({this.uid, this.secondaryUid});

  @override
  String toString() {
    return '_TableChange{uid: $uid, secondaryUid: $secondaryUid}';
  }
}

class _TableChanger {
  final _tableChangeEvent = Event<_TableChange>();

  void changeTable(String uid, String secondaryUid) {
    _tableChangeEvent
        .broadcast(_TableChange(uid: uid, secondaryUid: secondaryUid));
  }

  void subscribeStram(StreamSink<_TableChange> str) {
    _tableChangeEvent.subscribeStream(str);
  }
}
