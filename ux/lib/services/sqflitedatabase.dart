import 'dart:async';
import 'dart:convert';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

///
/// Interface to get all the data from the local sql database.
///
class SqlfliteDatabase extends BasketballDatabase {
  Completer<Database> _complete = Completer();
  StreamController<_TableChange> _controller =
      StreamController<_TableChange>(sync: false);
  Stream<_TableChange> _tableChange;
  final Uuid uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});

  static const String teamsTable = "Teams";
  static const String playersTable = "Players";
  static const String gamesTable = "Games";
  static const String gameEventsTable = "GameEvents";
  static const String seasonsTable = "Seasons";

  static const String indexColumn = "uid";
  static const String secondaryIndexColumn = "otherUid";
  static const String dataColumn = "data";

  static const List<String> _tables = const <String>[
    teamsTable,
    playersTable,
  ];
  static const List<String> _tablesSecondaryIndex = const <String>[
    gamesTable,
    gameEventsTable,
    seasonsTable,
  ];

  SqlfliteDatabase() {
    _tableChange = _controller.stream.asBroadcastStream();
  }

  Future<void> open() async {
    print("open database");
    //await deleteDatabase(join(await getDatabasesPath(), 'doggie_database.db'));
    // Open the database and store the reference.
    Database database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'basketball.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await Future.forEach(_tables, (String table) async {
          print('Made db $table');
          return await db.execute("CREATE TABLE IF NOT EXISTS " +
              table +
              " (" +
              indexColumn +
              " text PRIMARY KEY, " +
              dataColumn +
              " text NOT NULL);");
        });
        await Future.forEach(_tablesSecondaryIndex, (String table) async {
          print('Made db with secondary $table');
          return await db.execute("CREATE TABLE IF NOT EXISTS " +
              table +
              " (" +
              indexColumn +
              " text PRIMARY KEY, " +
              secondaryIndexColumn +
              " text KEY, " +
              dataColumn +
              " text NOT NULL);");
        });
      },
    );
    _complete.complete(database);
  }

  Future<void> waitTillOpen() async {
    await _complete.future;
    return;
  }

  @override
  Future<String> addGame({Game game}) async {
    Database db = await _complete.future;
    String uid = uuid.v5(Uuid.NAMESPACE_OID, gamesTable);
    Game newG = game.rebuild((b) => b..uid = uid);
    print('Inserting ${json.encode(newG.toMap())}');
    await db.insert(gamesTable, {
      indexColumn: uid,
      secondaryIndexColumn: game.seasonUid,
      dataColumn: json.encode(newG.toMap()),
    });
    _controller.add(_TableChange(
        table: gamesTable, uid: uid, secondaryUid: game.seasonUid));
    return uid;
  }

  @override
  Future<void> addGameEvent({GameEvent event}) async {
    Database db = await _complete.future;

    String uid = event.uid ?? uuid.v5(Uuid.NAMESPACE_OID, gameEventsTable);
    GameEvent newEv = event.rebuild((b) => b..uid = uid);
    db.insert(gameEventsTable, {
      indexColumn: uid,
      secondaryIndexColumn: event.gameUid,
      dataColumn: json.encode(newEv.toMap())
    });
    _controller.add(_TableChange(
        table: gameEventsTable, uid: uid, secondaryUid: event.gameUid));
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
    _controller.add(_TableChange(
        table: gamesTable, uid: gameUid, secondaryUid: t.seasonUid));
    return playerUid;
  }

  @override
  Future<String> addTeam({Team team, Season season}) async {
    Database db = await _complete.future;
    String uid = uuid.v5(Uuid.NAMESPACE_OID, teamsTable);
    String seasonUid = uuid.v5(Uuid.NAMESPACE_OID, seasonsTable);
    Team newT = team.rebuild((b) => b
      ..uid = uid
      ..currentSeasonUid = seasonUid);
    Season newS = season.rebuild((b) => b
      ..teamUid = uid
      ..uid = seasonUid);
    await db.insert(teamsTable, {
      indexColumn: uid,
      dataColumn: json.encode(newT.toMap()),
    });
    await db.insert(seasonsTable, {
      indexColumn: seasonUid,
      secondaryIndexColumn: uid,
      dataColumn: json.encode(newS.toMap()),
    });
    _controller.add(_TableChange(table: teamsTable, uid: uid));
    return uid;
  }

  @override
  Future<void> addSeasonPlayer({String seasonUid, String playerUid}) async {
    Season t = await _getSeason(seasonUid: seasonUid);
    await updateSeason(
        season: t.rebuild((b) =>
            b..playerUids.putIfAbsent(playerUid, () => PlayerSeasonSummary())));
    _controller.add(_TableChange(table: seasonsTable, uid: seasonUid));
    return playerUid;
  }

  @override
  Future<void> deleteGame({String gameUid}) async {
    Database db = await _complete.future;
    Game g = await _getGame(gameUid: gameUid);
    await db.delete(gamesTable, where: "uid = ?", whereArgs: [gameUid]);
    _controller.add(_TableChange(
        table: gamesTable, uid: gameUid, secondaryUid: g.seasonUid));
    return null;
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) async {
    Database db = await _complete.future;
    GameEvent ev = await _getGameEvent(gameEventUid: gameEventUid);
    await db
        .delete(gameEventsTable, where: "uid = ?", whereArgs: [gameEventUid]);
    _controller.add(_TableChange(
        table: gameEventsTable, uid: gameEventUid, secondaryUid: ev.gameUid));
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
    Database db = await _complete.future;
    await db.delete(teamsTable, where: "uid = ?", whereArgs: [teamUid]);
    _controller.add(_TableChange(table: teamsTable, uid: teamUid));
    return null;
  }

  @override
  Future<void> deletePlayer({String playerUid}) async {
    Database db = await _complete.future;
    await db.delete(playersTable, where: "uid = ?", whereArgs: [playerUid]);
    _controller.add(_TableChange(table: playersTable, uid: playerUid));
    // TODO: Delete from the other places it is referenced too.
    return null;
  }

  @override
  Future<void> deleteSeason({String seasonUid}) async {
    Database db = await _complete.future;
    await db.delete(seasonsTable, where: "uid = ?", whereArgs: [seasonUid]);
    _controller.add(_TableChange(table: seasonsTable, uid: seasonUid));
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
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps =
        await db.query(teamsTable, where: "uid = ?", whereArgs: [teamUid]);
    print("Query $maps");
    if (maps.isEmpty) {
      return null;
    }
    return maps
        .map((Map<String, dynamic> e) =>
            Team.fromMap(json.decode(e[dataColumn])))
        .first;
  }

  Future<Season> _getSeason({String seasonUid}) async {
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps =
        await db.query(seasonsTable, where: "uid = ?", whereArgs: [seasonUid]);
    print("Query $maps");
    if (maps.isEmpty) {
      return null;
    }
    return maps
        .map((Map<String, dynamic> e) =>
            Season.fromMap(json.decode(e[dataColumn])))
        .first;
  }

  @override
  Stream<Player> getPlayer({String playerUid}) async* {
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps =
        await db.query(playersTable, where: "uid = ?", whereArgs: [playerUid]);
    print("Query $maps");
    yield maps
        .map((Map<String, dynamic> e) =>
            Player.fromMap(json.decode(e[dataColumn])))
        .first;
    await for (_TableChange table in _tableChange) {
      print("Table change getPlayer $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.uid == playerUid) {
        final List<Map<String, dynamic>> maps = await db
            .query(playersTable, where: "uid = ?", whereArgs: [playerUid]);
        yield maps
            .map((Map<String, dynamic> e) =>
                Player.fromMap(json.decode(e[dataColumn])))
            .first;
      }
    }
  }

  Future<Game> _getGame({String gameUid}) async {
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps =
        await db.query(gamesTable, where: "uid = ?", whereArgs: [gameUid]);
    if (maps.isEmpty) {
      return null;
    }
    Game g = maps
        .map((Map<String, dynamic> e) =>
            Game.fromMap(json.decode(e[dataColumn])))
        .first;
    return g;
  }

  Future<GameEvent> _getGameEvent({String gameEventUid}) async {
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps = await db
        .query(gameEventsTable, where: "uid = ?", whereArgs: [gameEventUid]);
    if (maps.isEmpty) {
      return null;
    }
    GameEvent g = maps
        .map((Map<String, dynamic> e) =>
            GameEvent.fromMap(json.decode(e[dataColumn])))
        .first;
    return g;
  }

  @override
  Stream<Game> getGame({String gameUid}) async* {
    yield await _getGame(gameUid: gameUid);
    Database db = await _complete.future;
    await for (_TableChange table in _tableChange) {
      print("Table change getGame $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.secondaryUid == gameUid || table.uid == gameUid) {
        yield await _getGame(gameUid: gameUid);
      }
    }
  }

  @override
  Stream<Team> getTeam({String teamUid}) async* {
    yield await _getTeam(teamUid: teamUid);
    Database db = await _complete.future;
    await for (_TableChange table in _tableChange) {
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
  }

  @override
  Stream<Season> getSeason({String seasonUid}) async* {
    yield await _getSeason(seasonUid: seasonUid);
    Database db = await _complete.future;
    await for (_TableChange table in _tableChange) {
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
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() async* {
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps = await db.query(teamsTable);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Team.fromMap(json.decode(e[dataColumn])))
        .toList());
    print("getTeams waiting for change");
    await for (_TableChange table in _tableChange) {
      print("Table change getTeams $table");
      if (!db.isOpen) {
        print("db is not open");
        // Exit out of here.
        return;
      }
      if (table.table == teamsTable) {
        final List<Map<String, dynamic>> maps = await db.query(teamsTable);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Team.fromMap(json.decode(e[dataColumn])))
            .where((Team t) => t.uid != null)
            .toList());
      }
    }
    print("Exit getTeams");
  }

  @override
  Future<void> updateGame({Game game}) async {
    Database db = await _complete.future;
    db.update(
        gamesTable,
        {
          indexColumn: game.uid,
          dataColumn: json.encode(game.toMap()),
        },
        where: 'uid = ?',
        whereArgs: [game.uid]);
    _controller.add(_TableChange(
        table: gamesTable, uid: game.uid, secondaryUid: game.seasonUid));
    return null;
  }

  @override
  Future<void> updateTeam({Team team}) async {
    Database db = await _complete.future;
    db.update(
        teamsTable,
        {
          indexColumn: team.uid,
          dataColumn: json.encode(team.toMap()),
        },
        where: "uid = ?",
        whereArgs: [team.uid]);
    _controller.add(_TableChange(table: teamsTable, uid: team.uid));
    return null;
  }

  @override
  Future<void> updatePlayer({Player player}) async {
    Database db = await _complete.future;
    db.update(
        playersTable,
        {
          indexColumn: player.uid,
          dataColumn: json.encode(player.toMap()),
        },
        where: "uid = ?",
        whereArgs: [player.uid]);

    _controller.add(_TableChange(table: playersTable, uid: player.uid));
    return null;
  }

  @override
  Future<void> updateSeason({Season season}) async {
    Database db = await _complete.future;
    db.update(
        seasonsTable,
        {
          indexColumn: season.uid,
          dataColumn: json.encode(season.toMap()),
        },
        where: "uid = ?",
        whereArgs: [season.uid]);

    _controller.add(_TableChange(table: seasonsTable, uid: season.uid));
    return null;
  }

  @override
  Stream<BuiltList<Game>> getSeasonGames({String seasonUid}) async* {
    print("Waiting for database");
    Database db = await _complete.future;
    print("Got  database " + seasonUid);
    final List<Map<String, dynamic>> maps = await db.query(gamesTable,
        where: secondaryIndexColumn + " = ?", whereArgs: [seasonUid]);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Game.fromMap(json.decode(e[dataColumn])))
        .toList());
    await for (_TableChange table in _tableChange) {
      print("Table change $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.secondaryUid == seasonUid) {
        final List<Map<String, dynamic>> maps = await db.query(gamesTable,
            where: indexColumn + " = ?", whereArgs: [seasonUid]);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Game.fromMap(json.decode(e[dataColumn])))
            .where((Game t) => t.uid != null)
            .toList());
      }
    }
  }

  @override
  Stream<BuiltList<Game>> getGamesForPlayer({String playerUid}) async* {
    // TODO: Work this one out...
  }

  @override
  Stream<BuiltList<Season>> getTeamSeasons({String teamUid}) async* {
    print("Waiting for database");
    Database db = await _complete.future;
    print("Got  database " + teamUid);
    final List<Map<String, dynamic>> maps = await db.query(seasonsTable,
        where: secondaryIndexColumn + " = ?", whereArgs: [teamUid]);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Season.fromMap(json.decode(e[dataColumn])))
        .toList());
    await for (_TableChange table in _tableChange) {
      print("Table change $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.secondaryUid == teamUid) {
        final List<Map<String, dynamic>> maps = await db.query(seasonsTable,
            where: indexColumn + " = ?", whereArgs: [teamUid]);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Season.fromMap(json.decode(e[dataColumn])))
            .where((Season t) => t.uid != null)
            .toList());
      }
    }
  }

  @override
  Future<String> addPlayer({Player player}) async {
    print("Calling addPlayer");
    Database db = await _complete.future;
    String uid = uuid.v5(Uuid.NAMESPACE_OID, playersTable);
    Player newP = player.rebuild((b) => b..uid = uid);
    print('Inserting ${json.encode(newP.toMap())}');
    await db.insert(playersTable, {
      indexColumn: uid,
      dataColumn: json.encode(newP.toMap()),
    });
    print("Adding table to stream");
    _controller.add(_TableChange(table: playersTable, uid: uid));
    print("Done...");
    return uid;
  }

  @override
  Future<String> addSeason({String teamUid, Season season}) async {
    print("Calling addSeason");
    Database db = await _complete.future;
    String uid = uuid.v5(Uuid.NAMESPACE_OID, seasonsTable);
    Season newS = season.rebuild((b) => b
      ..uid = uid
      ..teamUid = teamUid);
    print('Inserting ${json.encode(newS.toMap())}');
    await db.insert(seasonsTable, {
      indexColumn: uid,
      secondaryIndexColumn: teamUid,
      dataColumn: json.encode(newS.toMap()),
    });
    print("Adding table to stream");
    _controller.add(
        _TableChange(table: seasonsTable, uid: uid, secondaryUid: teamUid));
    print("Done...");
    return uid;
  }

  BuiltList<GameEvent> _getGameEvents(List<Map<String, dynamic>> data) {
    var evs = data
        .map((Map<String, dynamic> e) =>
            GameEvent.fromMap(json.decode(e[dataColumn])))
        .toList();
    evs.sort((GameEvent a, GameEvent b) => a.timestamp.compareTo(b.timestamp));
    return BuiltList.from(evs);
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    print("Waiting for database");
    Database db = await _complete.future;
    print("Got  database " + gameUid);
    final List<Map<String, dynamic>> maps = await db.query(gameEventsTable,
        where: secondaryIndexColumn + " = ?", whereArgs: [gameUid]);
    print("Query $maps");
    yield _getGameEvents(maps);
    await for (_TableChange table in _tableChange) {
      print("Table change $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.secondaryUid == gameUid) {
        final List<Map<String, dynamic>> maps = await db.query(gameEventsTable,
            where: indexColumn + " = ?", whereArgs: [gameUid]);
        yield _getGameEvents(maps);
      }
    }
  }

  @override
  Stream<bool> get onDatabaseChange => null;
}

///
/// Used to track changes to the table
///
class _TableChange extends Equatable {
  final String table;
  final String uid;
  final String secondaryUid;

  _TableChange({this.table, this.uid, this.secondaryUid});

  @override
  List<Object> get props => [table, uid, secondaryUid];

  @override
  String toString() {
    return '_TableChange{table: $table, uid: $uid, secondaryUid: $secondaryUid}';
  }
}
