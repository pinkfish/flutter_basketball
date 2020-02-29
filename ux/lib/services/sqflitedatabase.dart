import 'dart:async';
import 'dart:convert';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///
/// Interface to get all the data from the local sql database.
///
class SqlfliteDatabase extends BasketballDatabase {
  Completer<Database> _complete = Completer();
  StreamController<_TableChange> _controller =
      StreamController<_TableChange>(sync: false);
  Stream<_TableChange> _tableChange;

  static const String teamsTable = "Teams";
  static const String playersTable = "Players";
  static const String gamesTable = "Games";
  static const String gameEventsTable = "GameEvents";

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
  ];

  SqlfliteDatabase() {
    _tableChange = _controller.stream.asBroadcastStream();
  }

  Future<void> open() async {
    //await deleteDatabase(join(await getDatabasesPath(), 'doggie_database.db'));
    // Open the database and store the reference.
    Database database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'doggie_database.db'),
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

  @override
  Future<String> addGame({String teamUid, Game game}) async {
    Database db = await _complete.future;
    String uid =
        Firestore.instance.collection(gamesTable).document().documentID;
    Game newG = game.rebuild((b) => b..uid = uid);
    print('Inserting ${json.encode(newG.toMap())}');
    await db.insert(gamesTable, {
      indexColumn: uid,
      secondaryIndexColumn: game.teamUid,
      dataColumn: json.encode(newG.toMap()),
    });
    _controller.add(
        _TableChange(table: gamesTable, uid: uid, secondaryUid: game.teamUid));
    return uid;
  }

  @override
  Future<void> addGameEvent({String gameUid, GameEvent event}) async {
    Database db = await _complete.future;
    String uid =
        Firestore.instance.collection(gameEventsTable).document().documentID;
    GameEvent newEv = event.rebuild((b) => b
      ..uid = uid
      ..gameUid = gameUid);
    db.insert(gameEventsTable, {
      indexColumn: uid,
      secondaryIndexColumn: gameUid,
      dataColumn: json.encode(newEv.toMap())
    });
    _controller.add(_TableChange(table: gamesTable, uid: gameUid));
    return uid;
  }

  @override
  Future<void> addGamePlayer({String gameUid, String playerUid}) async {
    Game t = await _getGame(gameUid: gameUid);
    await updateGame(
        game: t.rebuild(
            (b) => b..players.putIfAbsent(playerUid, () => PlayerSummary())));
    _controller.add(_TableChange(table: gamesTable, uid: gameUid));
    return playerUid;
  }

  @override
  Future<String> addTeam({Team team}) async {
    Database db = await _complete.future;
    String uid =
        Firestore.instance.collection(teamsTable).document().documentID;
    Team newT = team.rebuild((b) => b..uid = uid);
    print('Inserting ${json.encode(newT.toMap())}');
    await db.insert(teamsTable, {
      indexColumn: uid,
      dataColumn: json.encode(newT.toMap()),
    });
    _controller.add(_TableChange(table: teamsTable, uid: uid));
    return uid;
  }

  @override
  Future<void> addTeamPlayer({String teamUid, String playerUid}) async {
    Team t = await _getTeam(teamUid: teamUid);
    await updateTeam(
        team:
            t.rebuild((b) => b..playerUids.putIfAbsent(playerUid, () => true)));
    _controller.add(_TableChange(table: teamsTable, uid: teamUid));
    return playerUid;
  }

  @override
  Future<void> deleteGame({String gameUid}) async {
    Database db = await _complete.future;
    await db.delete(gamesTable, where: "uid = ?", whereArgs: [gameUid]);
    _controller.add(_TableChange(table: gamesTable, uid: gameUid));
    return null;
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) async {
    Database db = await _complete.future;
    await db
        .delete(gameEventsTable, where: "uid = ?", whereArgs: [gameEventUid]);
    _controller.add(_TableChange(table: gameEventsTable, uid: gameEventUid));
    return null;
  }

  @override
  Future<void> deleteGamePlayer({String gameUid, String playerUid}) async {
    Game t = await _getGame(gameUid: gameUid);
    _controller.add(_TableChange(table: gamesTable, uid: gameUid));
    return updateGame(game: t.rebuild((b) => b..players.remove(playerUid)));
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
  Future<void> deleteTeamPlayer({String teamUid, String playerUid}) async {
    Team t = await _getTeam(teamUid: teamUid);
    _controller.add(_TableChange(table: teamsTable, uid: teamUid));
    return updateTeam(team: t.rebuild((b) => b..playerUids.remove(playerUid)));
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
      if (table.table == playersTable && table.uid == playerUid) {
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
    print("Query $maps");
    if (maps.isEmpty) {
      return null;
    }
    return maps
        .map((Map<String, dynamic> e) =>
            Game.fromMap(json.decode(e[dataColumn])))
        .first;
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
      if (table.table == gamesTable && table.uid == gameUid) {
        yield await _getGame(gameUid: gameUid);
      }
    }
  }

  @override
  Stream<Team> getTeam({String teamUid}) async* {
    yield await _getTeam(teamUid: teamUid);
    Database db = await _complete.future;
    await for (_TableChange table in _tableChange) {
      print("Table change getGame $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.table == teamsTable && table.uid == teamUid) {
        yield await _getTeam(teamUid: teamUid);
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
    db.insert(gamesTable, {
      indexColumn: game.uid,
      dataColumn: json.encode(game.toMap()),
    });
    _controller.add(_TableChange(
        table: gamesTable, uid: game.uid, secondaryUid: game.teamUid));
    return null;
  }

  @override
  Future<void> updateTeam({Team team}) async {
    Database db = await _complete.future;
    db.update(teamsTable, {
      indexColumn: team.uid,
      dataColumn: json.encode(team.toMap()),
    });
    _controller.add(_TableChange(table: teamsTable, uid: team.uid));
    return null;
  }

  @override
  Future<void> updatePlayer({Player player}) async {
    Database db = await _complete.future;
    db.update(playersTable, {
      indexColumn: player.uid,
      dataColumn: json.encode(player.toMap()),
    });
    _controller.add(_TableChange(table: playersTable, uid: player.uid));
    return null;
  }

  @override
  Stream<BuiltList<Game>> getTeamGames({String teamUid}) async* {
    print("Waiting for database");
    Database db = await _complete.future;
    print("Got  database " + teamUid);
    final List<Map<String, dynamic>> maps = await db.query(gamesTable,
        where: secondaryIndexColumn + " = ?", whereArgs: [teamUid]);
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
      if (table.table == gamesTable && table.secondaryUid == teamUid) {
        final List<Map<String, dynamic>> maps = await db.query(gamesTable,
            where: indexColumn + " = ?", whereArgs: [teamUid]);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Game.fromMap(json.decode(e[dataColumn])))
            .where((Game t) => t.uid != null)
            .toList());
      }
    }
  }

  @override
  Future<String> addPlayer({Player player}) async {
    print("Calling addPlayer");
    Database db = await _complete.future;
    String uid =
        Firestore.instance.collection(playersTable).document().documentID;
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
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    print("Waiting for database");
    Database db = await _complete.future;
    print("Got  database " + gameUid);
    final List<Map<String, dynamic>> maps = await db.query(gameEventsTable,
        where: secondaryIndexColumn + " = ?", whereArgs: [gameUid]);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            GameEvent.fromMap(json.decode(e[dataColumn])))
        .toList());
    await for (_TableChange table in _tableChange) {
      print("Table change $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table.table == gameEventsTable && table.secondaryUid == gameUid) {
        final List<Map<String, dynamic>> maps = await db.query(gameEventsTable,
            where: indexColumn + " = ?", whereArgs: [gameUid]);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                GameEvent.fromMap(json.decode(e[dataColumn])))
            .toList());
      }
    }
  }
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
