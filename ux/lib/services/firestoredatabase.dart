import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/data/teamuser.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase extends BasketballDatabase {
  static const String teamsTable = "Teams";
  static const String seasonsTable = "Seasons";
  static const String playersTable = "Players";
  static const String gamesTable = "Games";
  static const String gameEventsTable = "GameEvents";

  static const String userUidField = "userUid";
  static const String enabledField = "enabled";

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
  Future<void> addGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
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
    ref.setData(map);
    var seasonMap = season
        .rebuild((b) =>
    b
      ..teamUid = ref.documentID
      ..uid = seasonRef.documentID)
        .toMap();
    seasonRef.setData(seasonMap);
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
    seasonRef.setData(seasonMap);
    return seasonRef.documentID;
  }

  @override
  Future<void> addSeasonPlayer({String seasonUid, String playerUid}) {
    var ref = Firestore.instance.collection(seasonsTable).document(seasonUid);
    return ref.updateData({
      "playerUids." + playerUid: PlayerSeasonSummary().toMap(),
    });
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
  Future<void> deleteGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref = Firestore.instance.collection(gamesTable).document(gameUid);
    return ref.updateData({
      (opponent ? "opponents." : "players.") + playerUid: FieldValue.delete()
    });
  }

  @override
  Future<void> deleteTeam({String teamUid}) {
    return Firestore.instance.collection(teamsTable).document(teamUid).delete();
  }

  @override
  Future<void> deleteSeasonPlayer({String seasonUid, String playerUid}) {
    var ref = Firestore.instance.collection(seasonsTable).document(seasonUid);
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
    for (var data in snap["playerUids"].keys) {
      if (snap["playerUids"][data] == true) {
        snap["playerUids"][data] = PlayerSeasonSummary().toMap();
      }
    }

    return snap;
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() async* {
    Query q = Firestore.instance
        .collection(teamsTable)
        .where("${userUidField}.${userUid}.${enabledField}", isEqualTo: true);
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
  Future<void> updateSeason({Season season}) {
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
  Future<void> deletePlayer({String playerUid}) {
    return Firestore.instance
        .collection(playersTable)
        .document(playerUid)
        .delete();
  }

  @override
  Future<void> deleteSeason({String seasonUid}) {
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
}
