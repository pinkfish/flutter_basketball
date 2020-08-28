import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/data/game/game.dart';
import 'package:basketballdata/data/game/gameevent.dart';
import 'package:basketballdata/data/invites/invite.dart';
import 'package:basketballdata/data/invites/invitefactory.dart';
import 'package:basketballdata/data/player/player.dart';
import 'package:basketballdata/data/team/team.dart';
import 'package:basketballdata/data/team/teamuser.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:basketballstats/services/sqldbraw.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

///
/// The class to handle all the firebase interactions.
///
class FirestoreDatabase extends BasketballDatabase {
  final FirebaseAnalytics analytics;

  FirestoreDatabase(this.analytics);

  String userUid;
  String userEmail;

  @override
  Future<String> addGame({Game game, BuiltList<Player> guestPlayers}) async {
    String ret;
    await Firestore.instance.runTransaction((transaction) async {
      ret = await _addGame(transaction, game, guestPlayers);
    });
    return ret;
  }

  Future<String> _addGame(Transaction transaction, Game game,
      BuiltList<Player> guestPlayers) async {
    var player = Player((b) => b
      ..name = game.opponentName.isEmpty ? "default" : game.opponentName
      ..jerseyNumber = "xx");
    var playerRef =
        Firestore.instance.collection(SQLDBRaw.playersTable).document();
    player = player.rebuild((b) => b..uid = playerRef.documentID);
    await transaction.set(playerRef, player.toMap());
    // Add all the guest players and put them into the players list.
    MapBuilder<String, PlayerGameSummary> players = MapBuilder();
    await Future.wait(guestPlayers.map((p) async {
      var uid = await addPlayer(player: p);
      players[uid] = PlayerGameSummary((b) => b
        ..currentlyPlaying = false
        ..playing = true);
    }));
    var ref = Firestore.instance.collection(SQLDBRaw.gamesTable).document();
    game = game.rebuild((b) => b
      ..uid = ref.documentID
      ..players = players
      ..opponents[playerRef.documentID] =
          PlayerGameSummary((b2) => b2..currentlyPlaying = true));
    await transaction.set(ref, game.toMap());
    analytics.logEvent(name: "AddGame");
    return ref.documentID;
  }

  @override
  Future<String> getGameEventId({GameEvent event}) async {
    var ref =
        Firestore.instance.collection(SQLDBRaw.gameEventsTable).document();
    analytics.logEvent(name: "AddGameEvent", parameters: {
      "type": event.type.toString(),
      "points": event.points.toString()
    });
    return ref.documentID;
  }

  @override
  Future<void> setGameEvent({GameEvent event}) async {
    if (event.uid == null || event.uid.isEmpty) {
      throw ArgumentError("uid must not be empty");
    }
    print("Saving game event $event");
    analytics.logEvent(name: "UpdateGameEvent");
    return Firestore.instance
        .collection(SQLDBRaw.gameEventsTable)
        .document(event.uid)
        .setData(event.toMap());
  }

  @override
  Future<void> addGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref =
        Firestore.instance.collection(SQLDBRaw.gamesTable).document(gameUid);
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
    var ref =
        Firestore.instance.collection(SQLDBRaw.gamesTable).document(gameUid);
    analytics.logEvent(name: "UpdateGamePlayer");
    return ref.updateData({"players." + playerUid: summary.toMap()});
  }

  @override
  Future<String> addTeam({Team team, Season season}) async {
    var ref = Firestore.instance.collection(SQLDBRaw.teamsTable).document();
    var seasonRef =
        Firestore.instance.collection(SQLDBRaw.seasonsTable).document();

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
      await Future.wait(
          [transaction.set(ref, map), transaction.set(seasonRef, seasonMap)]);
      return map;
    }, timeout: Duration(seconds: 5));
    analytics.logEvent(name: "AddTeam");
    return ref.documentID;
  }

  @override
  Future<String> addSeason({String teamUid, Season season}) async {
    var seasonRef =
        Firestore.instance.collection(SQLDBRaw.seasonsTable).document();

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
    var userRef =
        Firestore.instance.collection(SQLDBRaw.usersTable).document(user.uid);
    var data = await userRef.get();

    if (!data.exists) {
      analytics.logEvent(name: "AddUser");
      userRef.setData(user.toMap());
    }
    return userRef.documentID;
  }

  @override
  Future<void> addSeasonPlayer({String seasonUid, String playerUid}) {
    var ref = Firestore.instance
        .collection(SQLDBRaw.seasonsTable)
        .document(seasonUid);
    analytics.logEvent(name: "AddSeasonPlayer");
    return ref.updateData({
      "playerUids." + playerUid: PlayerSeasonSummary().toMap(),
    });
  }

  @override
  Future<void> deleteGame({String gameUid}) {
    analytics.logEvent(name: "DeleteGame");
    return Firestore.instance
        .collection(SQLDBRaw.gamesTable)
        .document(gameUid)
        .delete();
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) {
    print("Deleting event $gameEventUid");
    analytics.logEvent(name: "DeleteGameEvent");
    return Firestore.instance
        .collection(SQLDBRaw.gameEventsTable)
        .document(gameEventUid)
        .delete();
  }

  @override
  Future<void> deleteGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref =
        Firestore.instance.collection(SQLDBRaw.gamesTable).document(gameUid);
    analytics.logEvent(name: "DeleteGamePlayer");
    return ref.updateData({
      (opponent ? "opponents." : "players.") + playerUid: FieldValue.delete()
    });
  }

  @override
  Future<void> deleteTeam({String teamUid}) {
    analytics.logEvent(name: "DeleteTeam");
    return Firestore.instance
        .collection(SQLDBRaw.teamsTable)
        .document(teamUid)
        .delete();
  }

  @override
  Future<void> deleteSeasonPlayer({String seasonUid, String playerUid}) {
    var ref = Firestore.instance
        .collection(SQLDBRaw.seasonsTable)
        .document(seasonUid);
    analytics.logEvent(name: "DeleteSeasonPlayer");
    return ref.updateData({"playerUids." + playerUid: FieldValue.delete()});
  }

  @override
  Stream<Game> getGame({String gameUid}) async* {
    var ref =
        Firestore.instance.collection(SQLDBRaw.gamesTable).document(gameUid);
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
    var ref = Firestore.instance
        .collection(SQLDBRaw.playersTable)
        .document(playerUid);
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
  Stream<Invite> getInvite({String inviteUid}) async* {
    var ref = Firestore.instance
        .collection(SQLDBRaw.invitesTable)
        .document(inviteUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield InviteFactory.makeInviteFromJSON(doc.documentID, doc.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield InviteFactory.makeInviteFromJSON(snap.documentID, snap.data);
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
    Query q = Firestore.instance.collection(SQLDBRaw.teamsTable).where(
        "${SQLDBRaw.usersField}.$userUid.${SQLDBRaw.enabledField}",
        isEqualTo: true);
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
  Stream<BuiltList<Invite>> getAllInvites(String email) async* {
    Query q = Firestore.instance
        .collection(SQLDBRaw.invitesTable)
        .where("${SQLDBRaw.emailField}", isEqualTo: email);
    QuerySnapshot snap = await q.getDocuments();
    print(snap.documents);
    yield BuiltList.from(snap.documents.map((DocumentSnapshot snap) =>
        InviteFactory.makeInviteFromJSON(snap.documentID, snap.data)));

    await for (QuerySnapshot snap in q.snapshots()) {
      yield BuiltList.from(snap.documents.map((DocumentSnapshot snap) =>
          InviteFactory.makeInviteFromJSON(snap.documentID, snap.data)));
    }
  }

  @override
  Future<void> updateGame({Game game}) async {
    if (game.runningFrom == null) {
      // Delete this field.
      await Firestore.instance
          .collection(SQLDBRaw.gamesTable)
          .document(game.uid)
          .updateData({"runningFrom": FieldValue.delete()});
    }
    analytics.logEvent(name: "UpdateGame");
    return Firestore.instance
        .collection(SQLDBRaw.gamesTable)
        .document(game.uid)
        .updateData(game.toMap());
  }

  @override
  Future<void> updateTeam({Team team}) {
    analytics.logEvent(name: "UpdateTeam");
    return Firestore.instance
        .collection(SQLDBRaw.teamsTable)
        .document(team.uid)
        .updateData(team.toMap());
  }

  @override
  Future<void> updateUser({User user}) async {
    analytics.logEvent(name: "UpdateUser");
    return Firestore.instance
        .collection(SQLDBRaw.usersTable)
        .document(user.uid)
        .updateData(user.toMap());
  }

  @override
  Future<void> updatePlayer({Player player}) {
    analytics.logEvent(name: "UpdatePlayer");
    return Firestore.instance
        .collection(SQLDBRaw.playersTable)
        .document(player.uid)
        .updateData(player.toMap());
  }

  @override
  Future<void> updateSeason({Season season}) {
    analytics.logEvent(name: "UpdateSeason");
    return Firestore.instance
        .collection(SQLDBRaw.seasonsTable)
        .document(season.uid)
        .updateData(season.toMap());
  }

  @override
  Stream<BuiltList<Game>> getSeasonGames({String seasonUid}) async* {
    Query q = Firestore.instance
        .collection(SQLDBRaw.gamesTable)
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
        .collection(SQLDBRaw.seasonsTable)
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
    String ret;
    await Firestore.instance.runTransaction((transaction) async {
      ret = await _addPlayer(transaction, player);
    });
    return ret;
  }

  Future<String> _addPlayer(Transaction t, Player player) async {
    var ref = Firestore.instance.collection(SQLDBRaw.playersTable).document();
    var p = player.rebuild((b) => b..uid = ref.documentID);
    await t.set(ref, p.toMap());
    analytics.logEvent(name: "AddPlayer");
    return ref.documentID;
  }

  @override
  Future<String> addInvite({Invite invite}) async {
    String ret;
    var ref = Firestore.instance.collection(SQLDBRaw.invitesTable).document();
    if (invite is InviteToTeam) {
      var i = invite.rebuild((b) => b
        ..uid = ref.documentID
        ..sentByUid = userUid);
      await ref.setData(i.toMap());
    } else {
      throw UnimplementedError();
    }
    return ret;
  }

  @override
  Stream<Team> getTeam({String teamUid}) async* {
    var ref =
        Firestore.instance.collection(SQLDBRaw.teamsTable).document(teamUid);
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
    var ref = Firestore.instance
        .collection(SQLDBRaw.seasonsTable)
        .document(seasonUid);
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
    var ref =
        Firestore.instance.collection(SQLDBRaw.usersTable).document(userUid);
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
        .collection(SQLDBRaw.playersTable)
        .document(playerUid)
        .delete();
  }

  @override
  Future<void> deleteSeason({String seasonUid}) {
    analytics.logEvent(name: "DeleteSeason");
    return Firestore.instance
        .collection(SQLDBRaw.seasonsTable)
        .document(seasonUid)
        .delete();
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    Query q = Firestore.instance
        .collection(SQLDBRaw.gameEventsTable)
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
        .collection(SQLDBRaw.gamesTable)
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
    var ref = Firestore.instance.collection(SQLDBRaw.mediaTable).document();
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
        .collection(SQLDBRaw.mediaTable)
        .document(mediaInfoUid)
        .delete();
  }

  @override
  Future<void> deleteInvite({String inviteUid}) {
    analytics.logEvent(name: "DeleteInvite");
    return Firestore.instance
        .collection(SQLDBRaw.invitesTable)
        .document(inviteUid)
        .delete();
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForGame({String gameUid}) async* {
    Query q = Firestore.instance
        .collection(SQLDBRaw.mediaTable)
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

  @override
  Stream<MediaInfo> getMediaInfo({String mediaInfoUid}) async* {
    var ref = Firestore.instance
        .collection(SQLDBRaw.mediaTable)
        .document(mediaInfoUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield MediaInfo.fromMap(doc.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield MediaInfo.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  Future<void> updateMediaInfoThumbnail(
      {MediaInfo mediaInfo, String thumbnailUrl}) async {
    var ref = Firestore.instance
        .collection(SQLDBRaw.mediaTable)
        .document(mediaInfo.uid);
    await ref.updateData({thumbnailUrl: thumbnailUrl});
  }
}
