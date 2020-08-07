import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../data/media/mediainfo.dart';
import '../../db/basketballdatabase.dart';
import '../crashreporting.dart';
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
  final CrashReporting crashes;

  AddMediaBloc({@required this.db, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddMediaEvent event) async* {
    // Create a new Media.
    if (event is AddMediaEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await db.addMedia(media: event.newMedia);
        yield AddItemDone(uid: uid);
      } catch (e, s) {
        crashes.recordError(e, s);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
