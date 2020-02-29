import 'package:basketballdata/data/game.dart';
import 'package:basketballdata/data/gameevent.dart';
import 'package:basketballdata/data/player.dart';
import 'package:basketballdata/data/team.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase extends BasketballDatabase {
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
  Future<void> addGamePlayer({String gameUid, String playerUid}) {
    // TODO: implement addGamePlayer
    return null;
  }

  @override
  Future<String> addTeam({Team team}) {
    // TODO: implement addTeam
    return null;
  }

  @override
  Future<void> addTeamPlayer({String teamUid, String playerUid}) {
    // TODO: implement addTeamPlayer
    return null;
  }

  @override
  Future<void> deleteGame({String gameUid}) {
    // TODO: implement deleteGame
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
  Future<void> deleteTeam({String teamUid}) {
    // TODO: implement deleteTeam
    return null;
  }

  @override
  Future<void> deleteTeamPlayer({String teamUid, String playerUid}) {
    // TODO: implement deleteTeamPlayer
    return null;
  }

  @override
  Stream<Game> getGame({String gameUid}) {
    // TODO: implement getGames
    return null;
  }

  @override
  Stream<Player> getPlayer({String playerUid}) {
    // TODO: implement getTeamPlayers
    return null;
  }

  @override
  Stream<BuiltList<Team>> getAllTeams() async* {
    Query q =
        Firestore.instance.collection("Teams").where("userUid", isEqualTo: "1");
    QuerySnapshot snap = await q.getDocuments();
    yield snap.documents
        .map((DocumentSnapshot snap) => Team.fromMap(snap.data));
    await for (QuerySnapshot snap in q.snapshots()) {
      yield snap.documents
          .map((DocumentSnapshot snap) => Team.fromMap(snap.data));
    }
  }

  @override
  Future<void> updateGame({Game game}) {
    // TODO: implement updateGame
    return null;
  }

  @override
  Future<void> updateTeam({Team team}) {
    // TODO: implement updateTeam
    return null;
  }

  @override
  Future<void> updatePlayer({Player player}) {
    // TODO: implement updatePlayer
    return null;
  }

  @override
  Stream<BuiltList<Game>> getTeamGames({String teamUid}) {
    // TODO: implement getTeamGames
    return null;
  }

  @override
  Future<String> addPlayer({Player player}) {
    // TODO: implement addPlayer
    return null;
  }

  @override
  Stream<Team> getTeam({String teamUid}) {
    // TODO: implement getTeam
    return null;
  }

  @override
  Future<void> deletePlayer({String playerUid}) {
    // TODO: implement deletePlayer
    return null;
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) {
    // TODO: implement getGameEvents
    return null;
  }
}
