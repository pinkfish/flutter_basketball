import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///
/// This class gives raw access to the sqlflite db, setting up
/// the databases as needed for access to the local data.
///
class SQLDBRaw {
  final Completer<Database> _complete = Completer();

   static const  String teamsTable = "Teams";
   static const  String playersTable = "Players";
   static const  String gamesTable = "Games";
   static const  String gameEventsTable = "GameEvents";
   static const  String seasonsTable = "Seasons";
   static const  String uploadTable = "Uploads";

   static const  String indexColumn = "uid";
   static const  String secondaryIndexColumn = "otherUid";
   static const  String dataColumn = "data";

  static const  List<String> _tables = const <String>[
    teamsTable,
    playersTable,
    uploadTable,
  ];
  static const  List<String> _tablesSecondaryIndex = const <String>[
    gamesTable,
    gameEventsTable,
    seasonsTable,
  ];

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

  Future<Database> getDatabase() async {
    return _complete.future;
  }
}