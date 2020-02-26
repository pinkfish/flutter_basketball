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
  static const String dataColumn = "data";

  static const List<String> _tables = const <String>[
    teamsTable,
    playersTable,
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
      },
    );
    _complete.complete(database);
  }

  @override
  Future<String> addGame({String teamUid, Game game}) {
    // TODO: implement addGame
    return null;
  }

  @override
  Future<void> addGameEvent({String gameUid, GameEvent event}) {
    // TODO: implement addGameEvent
    return null;
  }

  @override
  Future<String> addGamePlayer({String gameUid, Player player}) {
    // TODO: implement addGamePlayer
    return null;
  }

  @override
  Future<String> addTeam({Team team}) async {
    Database db = await _complete.future;
    String uid =
        Firestore.instance.collection(teamsTable).document().documentID;
    db.insert(teamsTable, {
      indexColumn: uid,
      dataColumn: json.encode(team.toMap()),
    });
    _controller.add(teamsTable);
    return uid;
  }

  @override
  Future<String> addTeamPlayer({String teamUid, Player player}) {
    // TODO: implement addTeamPlayer
    return null;
  }

  @override
  Future<void> deleteGame({String gameUid}) async {
    Database db = await _complete.future;
    db.delete(gamesTable, where: "uid = ?", whereArgs: [gameUid]);
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
    db.delete(teamsTable, where: "uid = ?", whereArgs: [teamUid]);
    _controller.add(teamsTable);
    return null;
  }

  @override
  Future<void> deleteTeamPlayer({String teamUid, String playerUid}) {
    // TODO: implement deleteTeamPlayer
    return null;
  }

  @override
  Stream<BuiltList<Player>> getGamePlayers({String gameUid}) {
    // TODO: implement getGamePlayers
    return null;
  }

  @override
  Stream<BuiltList<Game>> getGames({String teamUid}) {
    // TODO: implement getGames
    return null;
  }

  @override
  Stream<BuiltList<Player>> getTeamPlayers({String teamUid}) {
    // TODO: implement getTeamPlayers
    return null;
  }

  @override
  Stream<BuiltList<Team>> getTeams() async* {
    Database db = await _complete.future;
    final List<Map<String, dynamic>> maps = await db.query(teamsTable);
    yield BuiltList.from(maps
        .map((Map<String, dynamic> e) =>
            Team.fromMap(json.decode(e[dataColumn])))
        .toList());
    await for (String table in _tableChange) {
      if (!db.isOpen) {
        // Exit out of here.
        return;
      }
      if (table == teamsTable) {
        final List<Map<String, dynamic>> maps = await db.query(teamsTable);
        yield BuiltList.from(maps
            .map((Map<String, dynamic> e) =>
                Team.fromMap(json.decode(e[dataColumn])))
            .toList());
      }
    }
  }

  @override
  Future<void> updateGame({Game game}) async {
    Database db = await _complete.future;
    db.insert(teamsTable, {
      "uid": game.uid,
      "data": json.encode(game.toMap()),
    });
    _controller.add(gamesTable);
    return null;
  }

  @override
  Future<void> updateTeam({Team team}) async {
    Database db = await _complete.future;
    db.insert(teamsTable, {
      "uid": team.uid,
      "data": json.encode(team.toMap()),
    });
    _controller.add(teamsTable);
    return null;
  }
}
