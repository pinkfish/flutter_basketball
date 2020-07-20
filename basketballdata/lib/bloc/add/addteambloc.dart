import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../data/season/season.dart';
import '../../data/team/team.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddTeamEvent extends Equatable {}

///
/// Adds this team into the set of teams.
///
class AddTeamEventCommit extends AddTeamEvent {
  final Team newTeam;
  final Season firstSeason;

  AddTeamEventCommit({@required this.newTeam, @required this.firstSeason});

  @override
  List<Object> get props => [this.newTeam];
}

///
/// Deals with specific teams to allow for accepting/deleting/etc of the
/// teams.
///
class AddTeamBloc extends Bloc<AddTeamEvent, AddItemState> {
  final BasketballDatabase db;

  AddTeamBloc({@required this.db}) : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddTeamEvent event) async* {
    // Create a new Team.
    if (event is AddTeamEventCommit) {
      yield AddItemSaving();

      try {
        String uid =
            await db.addTeam(team: event.newTeam, season: event.firstSeason);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        print(e);
        print(s);
        Crashlytics.instance.recordError(e, s);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
