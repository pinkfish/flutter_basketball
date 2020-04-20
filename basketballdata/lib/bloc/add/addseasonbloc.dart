import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../data/season.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddSeasonEvent extends Equatable {}

///
/// Adds this season into the set of seasons.
///
class AddSeasonEventCommit extends AddSeasonEvent {
  final Season newSeason;
  final String teamUid;

  AddSeasonEventCommit({@required this.newSeason, @required this.teamUid});

  @override
  List<Object> get props => [this.newSeason, this.teamUid];
}

///
/// Add a season into the system handling the update status for it.
///
class AddSeasonBloc extends Bloc<AddSeasonEvent, AddItemState> {
  final BasketballDatabase db;

  AddSeasonBloc({@required this.db});

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddSeasonEvent event) async* {
    // Create a new Season.
    if (event is AddSeasonEventCommit) {
      yield AddItemSaving();

      try {
        String uid =
            await db.addSeason(teamUid: event.teamUid, season: event.newSeason);
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
