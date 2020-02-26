import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/team.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddTeamEvent extends Equatable {}

///
/// Adds this team into the set of teams.
///
class AddTeamEventCommit extends AddTeamEvent {
  final Team newTeam;

  AddTeamEventCommit({@required this.newTeam});

  @override
  List<Object> get props => [this.newTeam];
}

///
/// Deals with specific teams to allow for accepting/deleting/etc of the
/// teams.
///
class AddTeamBloc extends Bloc<AddTeamEvent, AddItemState> {
  final BasketballDatabase db;

  AddTeamBloc({@required this.db});

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddTeamEvent event) async* {
    // Create a new Team.
    if (event is AddTeamEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addTeam(team: event.newTeam);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        print(e);
        print(s);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
