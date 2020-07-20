import 'dart:async';

import 'package:basketballdata/data/media/mediainfo.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// The basic data for the mediaInfo and all the data associated with it.
///
abstract class SingleMediaInfoState extends Equatable {
  final MediaInfo mediaInfo;

  SingleMediaInfoState({@required this.mediaInfo});

  @override
  List<Object> get props => [mediaInfo];
}

///
/// We have a mediaInfo, default state.
///
class SingleMediaInfoLoaded extends SingleMediaInfoState {
  SingleMediaInfoLoaded({MediaInfo mediaInfo, SingleMediaInfoState state})
      : super(mediaInfo: mediaInfo ?? state.mediaInfo);

  @override
  String toString() {
    return 'SingleMediaInfoLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleMediaInfoSaving extends SingleMediaInfoState {
  SingleMediaInfoSaving({@required SingleMediaInfoState singleMediaInfoState})
      : super(mediaInfo: singleMediaInfoState.mediaInfo);

  @override
  String toString() {
    return 'SingleMediaInfoSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleMediaInfoSaveFailed extends SingleMediaInfoState {
  final Error error;

  SingleMediaInfoSaveFailed(
      {@required SingleMediaInfoState singleMediaInfoState, this.error})
      : super(mediaInfo: singleMediaInfoState.mediaInfo);

  @override
  String toString() {
    return 'SingleMediaInfoSaveFailed{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleMediaInfoSaveSuccessful extends SingleMediaInfoState {
  SingleMediaInfoSaveSuccessful(
      {@required SingleMediaInfoState singleMediaInfoState})
      : super(mediaInfo: singleMediaInfoState.mediaInfo);

  @override
  String toString() {
    return 'SingleMediaInfoSaveFailed{}';
  }
}

///
/// MediaInfo got deleted.
///
class SingleMediaInfoDeleted extends SingleMediaInfoState {
  SingleMediaInfoDeleted() : super(mediaInfo: null);

  @override
  String toString() {
    return 'SingleMediaInfoDeleted{}';
  }
}

///
/// What the system has not yet read the mediaInfo state.
///
class SingleMediaInfoUninitialized extends SingleMediaInfoState {
  SingleMediaInfoUninitialized() : super(mediaInfo: null);
}

abstract class SingleMediaInfoEvent extends Equatable {}

class _SingleMediaInfoNewMediaInfo extends SingleMediaInfoEvent {
  final MediaInfo newMediaInfo;

  _SingleMediaInfoNewMediaInfo({@required this.newMediaInfo});

  @override
  List<Object> get props => [newMediaInfo];
}

class _SingleMediaInfoDeleted extends SingleMediaInfoEvent {
  _SingleMediaInfoDeleted();

  @override
  List<Object> get props => [];
}

///
/// Updates the url for this media info event.
///
class SingleMediaInfoUpdateThumbnail extends SingleMediaInfoEvent {
  final String thumbnailUrl;

  SingleMediaInfoUpdateThumbnail({@required this.thumbnailUrl});

  @override
  List<Object> get props => [thumbnailUrl];
}

///
/// Bloc to handle updates and state of a specific mediaInfo.
///
class SingleMediaInfoBloc
    extends Bloc<SingleMediaInfoEvent, SingleMediaInfoState> {
  final String mediaInfoUid;
  final BasketballDatabase db;

  StreamSubscription<MediaInfo> _mediaInfoSub;

  SingleMediaInfoBloc({@required this.db, @required this.mediaInfoUid})
      : super(SingleMediaInfoUninitialized()) {
    _mediaInfoSub =
        db.getMediaInfo(mediaInfoUid: mediaInfoUid).listen(_onMediaInfoUpdate);
  }

  void _onMediaInfoUpdate(MediaInfo g) {
    if (g != this.state.mediaInfo) {
      if (g != null) {
        add(_SingleMediaInfoNewMediaInfo(newMediaInfo: g));
      } else {
        add(_SingleMediaInfoDeleted());
      }
    }
  }

  @override
  Future<void> close() async {
    _mediaInfoSub?.cancel();
    _mediaInfoSub = null;
    await super.close();
  }

  @override
  Stream<SingleMediaInfoState> mapEventToState(
      SingleMediaInfoEvent event) async* {
    if (event is _SingleMediaInfoNewMediaInfo) {
      yield SingleMediaInfoLoaded(mediaInfo: event.newMediaInfo, state: state);
    }

    if (event is _SingleMediaInfoDeleted) {
      yield SingleMediaInfoDeleted();
    }
  }
}
