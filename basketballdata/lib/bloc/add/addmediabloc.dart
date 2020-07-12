import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';

import '../../data/mediainfo.dart';
import '../../db/basketballdatabase.dart';
import 'additemstate.dart';

abstract class AddMediaEvent extends Equatable {}

///
/// Adds this media into the set of medias.
///
class AddMediaEventCommit extends AddMediaEvent {
  final MediaInfo newMedia;

  AddMediaEventCommit({@required this.newMedia});

  @override
  List<Object> get props => [this.newMedia];
}

///
/// Deals with specific medias to allow for accepting/deleting/etc of the
/// medias.
///
class AddMediaBloc extends Bloc<AddMediaEvent, AddItemState> {
  final BasketballDatabase db;

  AddMediaBloc({@required this.db}) : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddMediaEvent event) async* {
    // Create a new Media.
    if (event is AddMediaEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addMedia(media: event.newMedia);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
