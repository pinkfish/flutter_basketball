import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase extends BasketballDatabase {
  static const String teamsTable = "Teams";
  static const String playersTable = "Players";
  static const String gamesTable = "Games";
  static const String gameEventsTable = "GameEvents";

  static const String userUidField = "userUid";

  String userUid;

  @override
  Future<String> addGame({Game game}) async {
    var player = Player((b) => b
      ..name = game.opponentName.isEmpty ? "default" : game.opponentName
      ..jerseyNumber = "xx");
    var playerRef = Firestore.instance.collection(playersTable).document();
    player = player.rebuild((b) => b..uid = playerRef.documentID);
    await playerRef.updateData(player.toMap());
    var ref = Firestore.instance.collection(gamesTable).document();
    game = game.rebuild((b) => b
      ..uid = ref.documentID
      ..opponents[playerRef.documentID] =
          PlayerSummary((b2) => b2..currentlyPlaying = true));
    await ref.updateData(game.toMap());
    return ref.documentID;
  }

  @override
  Future<void> addGameEvent({GameEvent event}) async {
    if (event.uid == null || event.uid.isEmpty) {
      var ref = Firestore.instance.collection(gameEventsTable).document();
      event.rebuild((b) => b..uid = ref.documentID);
      return ref.updateData(event.toMap());
    }
    await Firestore.instance
        .collection(gameEventsTable)
        .document(event.uid)
        .setData(event.toMap());
  }

  @override
  Future<void> addGamePlayer({String gameUid, String playerUid}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    return ref.updateData({"playerUids." + playerUid: true});
  }

  @override
  Future<String> addTeam({Team team}) async {
    var ref = Firestore.instance.collection(teamsTable).document();
    var map = team.rebuild((b) => b..uid = ref.documentID).toMap();
    map.putIfAbsent(userUidField, () => userUid);
    ref.updateData(map);
    return ref.documentID;
  }

  @override
  Future<void> addTeamPlayer({String teamUid, String playerUid}) {
    var ref = Firestore.instance.collection(teamsTable).document(teamUid);
    return ref.updateData({"playerUids." + playerUid: true});
  }

  @override
  Future<void> deleteGame({String gameUid}) {
    return Firestore.instance.collection(gamesTable).document(gameUid).delete();
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) {
    print("Deleting event $gameEventUid");
    return Firestore.instance
        .collection(gameEventsTable)
        .document(gameEventUid)
        .delete();
  }

  @override
  Future<void> deleteGamePlayer({String gameUid, String playerUid}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    return ref.updateData({"playerUids." + playerUid: FieldValue.delete()});
  }

  @override
  Future<void> deleteTeam({String teamUid}) {
    return Firestore.instance.collection(teamsTable).document(teamUid).delete();
  }

  @override
  Future<void> deleteTeamPlayer({String teamUid, String playerUid}) {
    var ref = Firestore.instance.collection(teamsTable).document(teamUid);
    return ref.updateData({"playerUids." + playerUid: FieldValue.delete()});
  }

  @override
  Stream<Game> getGame({String gameUid}) async* {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield Game.fromMap(_addUid(doc.documentID, doc.data));
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Game.fromMap(_addUid(snap.documentID, snap.data));
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<Player> getPlayer({String playerUid}) async* {
    var ref = Firestore.instance.collection(playersTable).document(playerUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield Player.fromMap(_addUid(doc.documentID, doc.data));
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Player.fromMap(_addUid(snap.documentID, snap.data));
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() async* {
    Query q = Firestore.instance
        .collection(teamsTable)
        .where(userUidField, isEqualTo: userUid);
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.from(snap.documents.map((DocumentSnapshot snap) =>
        Team.fromMap(_addUid(snap.documentID, snap.data))));

    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Team.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Future<void> updateGame({Game game}) {
    if (game.runningFrom == null) {
      // Delete this field.
      Firestore.instance
          .collection(gamesTable)
          .document(game.uid)
          .updateData({"runningFrom": FieldValue.delete()});
    }
    return Firestore.instance
        .collection(gamesTable)
        .document(game.uid)
        .updateData(game.toMap());
  }

  @override
  Future<void> updateTeam({Team team}) {
    return Firestore.instance
        .collection(teamsTable)
        .document(team.uid)
        .updateData(team.toMap());
  }

  @override
  Future<void> updatePlayer({Player player}) {
    return Firestore.instance
        .collection(playersTable)
        .document(player.uid)
        .updateData(player.toMap());
  }

  @override
  Stream<BuiltList<Game>> getTeamGames({String teamUid}) async* {
    Query q = Firestore.instance
        .collection(gamesTable)
        .where("teamUid", isEqualTo: teamUid);
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
        Game.fromMap(_addUid(snap.documentID, snap.data))));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Game.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Future<String> addPlayer({Player player}) async {
    var ref =
        await Firestore.instance.collection(playersTable).add(player.toMap());
    return ref.documentID;
  }

  @override
  Stream<Team> getTeam({String teamUid}) async* {
    var ref = Firestore.instance.collection(teamsTable).document(teamUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield Team.fromMap(_addUid(doc.documentID, doc.data));
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Team.fromMap(_addUid(doc.documentID, snap.data));
      } else {
        yield null;
      }
    }
  }

  @override
  Future<void> deletePlayer({String playerUid}) {
    return Firestore.instance
        .collection(playersTable)
        .document(playerUid)
        .delete();
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    Query q = Firestore.instance
        .collection(gameEventsTable)
        .where("gameUid", isEqualTo: gameUid)
        .orderBy("timestamp");
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
        GameEvent.fromMap(_addUid(snap.documentID, snap.data))
            .rebuild((b) => b..uid = snap.documentID)));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          GameEvent.fromMap(_addUid(snap.documentID, snap.data))
              .rebuild((b) => b..uid = snap.documentID)));
    }
  }

  Map<String, dynamic> _addUid(String uid, Map<String, dynamic> data) {
    data.putIfAbsent("uid", () => uid);
    return data;
  }

  @override
  Stream<bool> get onDatabaseChange => null;

  @override
  Stream<BuiltList<Game>> getGamesForPlayer({String playerUid}) async* {
    Query q = Firestore.instance
        .collection(gamesTable)
        .where("players." + playerUid + ".playing", isEqualTo: true)
        .orderBy("eventTime");
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
        Game.fromMap(_addUid(snap.documentID, snap.data))));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Game.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }
}
