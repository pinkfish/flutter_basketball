import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/data/teamuser.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirestoreDatabase extends BasketballDatabase {
  static const String teamsTable = "Teams";
  static const String seasonsTable = "Seasons";
  static const String usersTable = "Users";
  static const String playersTable = "Players";
  static const String gamesTable = "Games";
  static const String gameEventsTable = "GameEvents";
  static const String mediaTable = "Media";

  static const String userUidField = "userUid";
  static const String usersField = "users";
  static const String enabledField = "enabled";

  final FirebaseAnalytics analytics;

  FirestoreDatabase(this.analytics);

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
          PlayerGameSummary((b2) => b2..currentlyPlaying = true));
    await ref.setData(game.toMap());
    analytics.logEvent(name: "AddGame");
    return ref.documentID;
  }

  @override
  Future<void> addGameEvent({GameEvent event}) async {
    if (event.uid == null || event.uid.isEmpty) {
      var ref = Firestore.instance.collection(gameEventsTable).document();
      event.rebuild((b) => b..uid = ref.documentID);
      analytics.logEvent(name: "AddGameEvent", parameters: {
        "type": event.type.toString(),
        "points": event.points.toString()
      });
      return ref.setData(event.toMap());
    }
    analytics.logEvent(name: "UpdateGameEvent");
    return Firestore.instance
        .collection(gameEventsTable)
        .document(event.uid)
        .updateData(event.toMap());
  }

  @override
  Future<void> addGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    analytics.logEvent(name: "AddGamePlayer");
    return ref.updateData(
        {(opponent ? "opponents." : "players.") + playerUid + ".player": true});
  }

  @override
  Future<void> updateGamePlayerData(
      {String gameUid,
      String playerUid,
      PlayerGameSummary summary,
      bool opponent}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    analytics.logEvent(name: "UpdateGamePlayer");
    return ref.updateData({"players." + playerUid: summary.toMap()});
  }

  @override
  Future<String> addTeam({Team team, Season season}) async {
    var ref = Firestore.instance.collection(teamsTable).document();
    var seasonRef = Firestore.instance.collection(seasonsTable).document();

    team = team.rebuild((b) => b..users[userUid] = TeamUser());
    var map = team
        .rebuild((b) => b
          ..uid = ref.documentID
          ..currentSeasonUid = seasonRef.documentID)
        .toMap();
    var seasonMap = season
        .rebuild((b) => b
          ..teamUid = ref.documentID
          ..uid = seasonRef.documentID)
        .toMap();
    await Firestore.instance.runTransaction((transaction) async {
      print(map);
      print(seasonMap);
      await Future.wait(
          [transaction.set(ref, map), transaction.set(seasonRef, seasonMap)]);
      return map;
    }, timeout: Duration(seconds: 5));
    analytics.logEvent(name: "AddTeam");
    return ref.documentID;
  }

  @override
  Future<String> addSeason({String teamUid, Season season}) async {
    var seasonRef = Firestore.instance.collection(seasonsTable).document();

    var seasonMap = season
        .rebuild((b) => b
          ..teamUid = teamUid
          ..uid = seasonRef.documentID)
        .toMap();
    await seasonRef.setData(seasonMap);
    analytics.logEvent(name: "AddSeason");
    return seasonRef.documentID;
  }

  @override
  Future<String> addUser({User user}) async {
    var userRef = Firestore.instance.collection(usersTable).document(user.uid);
    var data = await userRef.get();

    if (!data.exists) {
      analytics.logEvent(name: "AddUser");
      userRef.setData(user.toMap());
    }
    return userRef.documentID;
  }

  @override
  Future<void> addSeasonPlayer({String seasonUid, String playerUid}) {
    var ref = Firestore.instance.collection(seasonsTable).document(seasonUid);
    analytics.logEvent(name: "AddSeasonPlayer");
    return ref.updateData({
      "playerUids." + playerUid: PlayerSeasonSummary().toMap(),
    });
  }

  @override
  Future<void> deleteGame({String gameUid}) {
    analytics.logEvent(name: "DeleteGame");
    return Firestore.instance.collection(gamesTable).document(gameUid).delete();
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) {
    print("Deleting event $gameEventUid");
    analytics.logEvent(name: "DeleteGameEvent");
    return Firestore.instance
        .collection(gameEventsTable)
        .document(gameEventUid)
        .delete();
  }

  @override
  Future<void> deleteGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    analytics.logEvent(name: "DeleteGamePlayer");
    return ref.updateData({
      (opponent ? "opponents." : "players.") + playerUid: FieldValue.delete()
    });
  }

  @override
  Future<void> deleteTeam({String teamUid}) {
    analytics.logEvent(name: "DeleteTeam");
    return Firestore.instance.collection(teamsTable).document(teamUid).delete();
  }

  @override
  Future<void> deleteSeasonPlayer({String seasonUid, String playerUid}) {
    var ref = Firestore.instance.collection(seasonsTable).document(seasonUid);
    analytics.logEvent(name: "DeleteSeasonPlayer");
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

  Map<String, dynamic> _fixTeamSnapshot(Map<String, dynamic> snap) {
    if (snap.containsKey("playerUids")) {
      for (var data in snap["playerUids"].keys) {
        if (snap["playerUids"][data] == true) {
          snap["playerUids"][data] = PlayerSeasonSummary().toMap();
        }
      }
    } else {
      print("No playerUids $snap");
    }

    return snap;
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() async* {
    Query q = Firestore.instance
        .collection(teamsTable)
        .where("$usersField.$userUid.$enabledField", isEqualTo: true);
    QuerySnapshot snap = await q.getDocuments();
    print(snap.documents);
    yield BuiltList.from(snap.documents.map((DocumentSnapshot snap) =>
        Team.fromMap(_fixTeamSnapshot(_addUid(snap.documentID, snap.data)))));

    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Team.fromMap(_fixTeamSnapshot(_addUid(snap.documentID, snap.data)))));
    }
  }

  @override
  Future<void> updateGame({Game game}) async {
    if (game.runningFrom == null) {
      // Delete this field.
      await Firestore.instance
          .collection(gamesTable)
          .document(game.uid)
          .updateData({"runningFrom": FieldValue.delete()});
    }
    analytics.logEvent(name: "UpdateGame");
    return Firestore.instance
        .collection(gamesTable)
        .document(game.uid)
        .updateData(game.toMap());
  }

  @override
  Future<void> updateTeam({Team team}) {
    analytics.logEvent(name: "UpdateTeam");
    return Firestore.instance
        .collection(teamsTable)
        .document(team.uid)
        .updateData(team.toMap());
  }

  @override
  Future<void> updateUser({User user}) async {
    analytics.logEvent(name: "UpdateUser");
    return Firestore.instance
        .collection(usersTable)
        .document(user.uid)
        .updateData(user.toMap());
  }

  @override
  Future<void> updatePlayer({Player player}) {
    analytics.logEvent(name: "UpdatePlayer");
    return Firestore.instance
        .collection(playersTable)
        .document(player.uid)
        .updateData(player.toMap());
  }

  @override
  Future<void> updateSeason({Season season}) {
    analytics.logEvent(name: "UpdateSeason");
    return Firestore.instance
        .collection(seasonsTable)
        .document(season.uid)
        .updateData(season.toMap());
  }

  @override
  Stream<BuiltList<Game>> getSeasonGames({String seasonUid}) async* {
    Query q = Firestore.instance
        .collection(gamesTable)
        .where("seasonUid", isEqualTo: seasonUid);
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
        Game.fromMap(_addUid(snap.documentID, snap.data))));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Game.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Stream<BuiltList<Season>> getTeamSeasons({String teamUid}) async* {
    //  var tq =
    //     await Firestore.instance.collection(teamsTable).document(teamUid).get();
    //Team t = Team.fromMap(tq.data);

    Query q = Firestore.instance
        .collection(seasonsTable)
        .where("teamUid", isEqualTo: teamUid);
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) {
      var s = Season.fromMap(_addUid(snap.documentID, snap.data));
      // updateSeason(
      //    season: s.rebuild((b) => b..playerUids = t.playerUids.toBuilder()));
      return s;
    }));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Season.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Future<String> addPlayer({Player player}) async {
    var ref = Firestore.instance.collection(playersTable).document();
    var p = player.rebuild((b) => b..uid = ref.documentID);
    await ref.setData(p.toMap());
    analytics.logEvent(name: "AddPlayer");
    return ref.documentID;
  }

  @override
  Stream<Team> getTeam({String teamUid}) async* {
    var ref = Firestore.instance.collection(teamsTable).document(teamUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield Team.fromMap(_fixTeamSnapshot(_addUid(doc.documentID, doc.data)));
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Team.fromMap(
            _fixTeamSnapshot(_addUid(doc.documentID, snap.data)));
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<Season> getSeason({String seasonUid}) async* {
    var ref = Firestore.instance.collection(seasonsTable).document(seasonUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield Season.fromMap(_addUid(doc.documentID, doc.data));
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Season.fromMap(_addUid(doc.documentID, snap.data));
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<User> getUser({String userUid}) async* {
    var ref = Firestore.instance.collection(usersTable).document(userUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield User.fromMap(doc.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield User.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Future<void> deletePlayer({String playerUid}) {
    analytics.logEvent(name: "DeletePlayer");
    return Firestore.instance
        .collection(playersTable)
        .document(playerUid)
        .delete();
  }

  @override
  Future<void> deleteSeason({String seasonUid}) {
    analytics.logEvent(name: "DeleteSeason");
    return Firestore.instance
        .collection(seasonsTable)
        .document(seasonUid)
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
        .where("players." + playerUid + ".playing", isEqualTo: true);
    QuerySnapshot snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
        Game.fromMap(_addUid(snap.documentID, snap.data))));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          Game.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Future<String> addMedia({MediaInfo media}) async {
    var ref = Firestore.instance.collection(mediaTable).document();
    var p = media.rebuild((b) => b..uid = ref.documentID);
    var data = p.toMap();
    data["uploadTime"] = FieldValue.serverTimestamp();
    await ref.setData(data);
    analytics.logEvent(name: "AddMedia");
    return ref.documentID;
  }

  Future<void> deleteMedia({String mediaInfoUid}) {
    analytics.logEvent(name: "DeleteMedia");
    return Firestore.instance
        .collection(mediaTable)
        .document(mediaInfoUid)
        .delete();
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForGame({String gameUid}) async* {
    Query q = Firestore.instance
        .collection(mediaTable)
        .where("gameUid", isEqualTo: gameUid);
    QuerySnapshot snap = await q.getDocuments();
    snap.documents.forEach((e) {
      print(e.data);
    });
    yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
        MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((DocumentSnapshot snap) =>
          MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }
}
