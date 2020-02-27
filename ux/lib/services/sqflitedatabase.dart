import 'dart:async';
import 'dart:convert';

import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlfliteDatabase extends BasketballDatabase {
  Completer<Database> _complete = Completer();
  StreamController<String> _controller = StreamController<String>();
  Stream<String> _tableChange;

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

  Future<void> open() async {
    _tableChange = _controller.stream.asBroadcastStream();
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
          print('Made db $table');
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
    await db.insert(teamsTable, {
      indexColumn: uid,
      secondaryIndexColumn: game.teamUid,
      dataColumn: json.encode(newG.toMap()),
    });
    print("Adding table to stream");
    _controller.add(teamsTable);
    print("Done...");
    return uid;
  }

  @override
  Future<void> addGameEvent({String gameUid, GameEvent event}) {
    // TODO: implement addGameEvent
    return null;
  }

  @override
  Future<String> addGamePlayer({String gameUid, String playerUid}) {
    // TODO: implement addGamePlayer
    return null;
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
    print("Adding table to stream");
    _controller.add(teamsTable);
    print("Done...");
    return uid;
  }

  @override
  Future<String> addTeamPlayer({String teamUid, String playerUid}) {
    // TODO: implement addTeamPlayer
    return null;
  }

  @override
  Future<void> deleteGame({String gameUid}) async {
    Database db = await _complete.future;
    await db.delete(gamesTable, where: "uid = ?", whereArgs: [gameUid]);
    _controller.add(gamesTable);
    return null;
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) {
    // TODO: implement deleteGameEvent
    return null;
  }

  @override
  Future<void> deleteGamePlayer({String gameUid, String playerUid}) {
    // TODO: implement deleteGamePlayer
    return null;
  }

  @override
  Future<void> deleteTeam({String teamUid}) async {
    Database db = await _complete.future;
    await db.delete(teamsTable, where: "uid = ?", whereArgs: [teamUid]);
    _controller.add(teamsTable);
    return null;
  }

  @override
  Future<void> deleteTeamPlayer({String teamUid, String playerUid}) {
    // TODO: implement deleteTeamPlayer
    return null;
  }

  @override
  Stream<Player> getPlayer({String playerUid}) {
    // TODO: implement getGamePlayers
    return null;
  }

  @override
  Stream<Game> getGame({String gameUid}) {
    // TODO: implement getGames
    return null;
  }

  @override
  Stream<BuiltList<Team>> getTeams() async* {
    print("Waiting for database");
    Database db = await _complete.future;
    print("Got  database");
    final List<Map<String, dynamic>> maps = await db.query(teamsTable);
    print("Query $maps");
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Team.fromMap(json.decode(e[dataColumn])))
        .toList());
    await for (String table in _tableChange) {
      print("Table change $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table == teamsTable) {
        final List<Map<String, dynamic>> maps = await db.query(teamsTable);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Team.fromMap(json.decode(e[dataColumn])))
            .where((Team t) => t.uid != null)
            .toList());
      }
    }
  }

  @override
  Future<void> updateGame({Game game}) async {
    Database db = await _complete.future;
    db.insert(teamsTable, {
      indexColumn: game.uid,
      dataColumn: json.encode(game.toMap()),
    });
    _controller.add(gamesTable);
    return null;
  }

  @override
  Future<void> updateTeam({Team team}) async {
    Database db = await _complete.future;
    db.update(teamsTable, {
      indexColumn: team.uid,
      dataColumn: json.encode(team.toMap()),
    });
    _controller.add(teamsTable);
    return null;
  }

  @override
  Future<void> updatePlayer({Player player}) {
    // TODO: implement updatePlayer
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
    await for (String table in _tableChange) {
      print("Table change $table");
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table == gamesTable) {
        final List<Map<String, dynamic>> maps = await db.query(teamsTable,
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
  Future<String> addPlayer({Player player}) {
    // TODO: implement addPlayer
    return null;
  }
}
