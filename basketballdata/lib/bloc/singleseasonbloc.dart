import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../data/game.dart';
import '../data/season.dart';

abstract class SingleSeasonBlocState extends Equatable {
  final Season season;
  final BuiltList<Game> games;
  final bool loadedGames;

  SingleSeasonBlocState(
      {@required this.season,
      @required this.games,
      @required this.loadedGames});

  @override
  List<Object> get props => [season, games, loadedGames];
}

///
/// We have a season, default state.
///
class SingleSeasonLoaded extends SingleSeasonBlocState {
  SingleSeasonLoaded(
      {@required SingleSeasonBlocState state,
      Season season,
      BuiltList<Game> games,
      bool loadedGames})
      : super(
            season: season ?? state.season,
            games: games ?? state.games,
            loadedGames: loadedGames ?? state.loadedGames);

  @override
  String toString() {
    return 'SingleSeasonLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleSeasonSaving extends SingleSeasonBlocState {
  SingleSeasonSaving({@required SingleSeasonBlocState singleSeasonState})
      : super(
            season: singleSeasonState.season,
            games: singleSeasonState.games,
            loadedGames: singleSeasonState.loadedGames);

  @override
  String toString() {
    return 'SingleSeasonSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleSeasonSaveFailed extends SingleSeasonBlocState {
  final Error error;

  SingleSeasonSaveFailed(
      {@required SingleSeasonBlocState singleSeasonState, this.error})
      : super(
            season: singleSeasonState.season,
            games: singleSeasonState.games,
            loadedGames: singleSeasonState.loadedGames);

  @override
  String toString() {
    return 'SingleSeasonSaveFailed{}';
  }
}

///
/// Season got deleted.
///
class SingleSeasonDeleted extends SingleSeasonBlocState {
  SingleSeasonDeleted()
      : super(season: null, games: BuiltList.of([]), loadedGames: false);

  @override
  String toString() {
    return 'SingleSeasonDeleted{}';
  }
}

///
/// Season is still loading.
///
class SingleSeasonUninitialized extends SingleSeasonBlocState {
  SingleSeasonUninitialized()
      : super(season: null, games: BuiltList.of([]), loadedGames: false);

  @override
  String toString() {
    return 'SingleSeasonUninitialized{}';
  }
}

abstract class SingleSeasonEvent extends Equatable {}

///
/// Updates the season (writes it out to firebase.
///
class SingleSeasonUpdate extends SingleSeasonEvent {
  final Season season;

  SingleSeasonUpdate({@required this.season});

  @override
  List<Object> get props => [season];
}

///
/// Adds an player to the season.
///
class SingleSeasonAddPlayer extends SingleSeasonEvent {
  final String playerUid;

  SingleSeasonAddPlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
}

///
/// Deletes an player from the season.
///
class SingleSeasonRemovePlayer extends SingleSeasonEvent {
  final String playerUid;

  SingleSeasonRemovePlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
}

///
/// Delete this season from the world.
///
class SingleSeasonDelete extends SingleSeasonEvent {
  SingleSeasonDelete();

  @override
  List<Object> get props => [];
}

///
/// Loads the games associated with this season.
///
class SingleSeasonLoadGames extends SingleSeasonEvent {
  @override
  List<Object> get props => null;
}

class _SingleSeasonNewSeason extends SingleSeasonEvent {
  final Season newSeason;

  _SingleSeasonNewSeason({@required this.newSeason});

  @override
  List<Object> get props => [newSeason];
}

class _SingleSeasonUpdateGames extends SingleSeasonEvent {
  final BuiltList<Game> games;

  _SingleSeasonUpdateGames({@required this.games});

  @override
  List<Object> get props => [games];
}

class _SingleSeasonDeleted extends SingleSeasonEvent {
  _SingleSeasonDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific season.
///
class SingleSeasonBloc extends Bloc<SingleSeasonEvent, SingleSeasonBlocState> {
  final BasketballDatabase db;
  final String seasonUid;
  final Lock _lock = new Lock();

  StreamSubscription<Season> _seasonSub;
  StreamSubscription<BuiltList<Game>> _gameSub;

  SingleSeasonBloc({@required this.db, @required this.seasonUid}) {
    _seasonSub = db.getSeason(seasonUid: seasonUid).listen((Season t) {
      if (t != null) {
        // Only send this if the season is not the same.
        if (t != state.season || !(state is SingleSeasonLoaded)) {
          add(_SingleSeasonNewSeason(newSeason: t));
        }
      } else {
        add(_SingleSeasonDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    _seasonSub?.cancel();
    _gameSub?.cancel();
    await super.close();
  }

  @override
  SingleSeasonBlocState get initialState {
    return SingleSeasonUninitialized();
  }

  @override
  Stream<SingleSeasonBlocState> mapEventToState(
      SingleSeasonEvent event) async* {
    if (event is _SingleSeasonNewSeason) {
      yield SingleSeasonLoaded(state: state, season: event.newSeason);
    }

    // The season is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the season.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving(singleSeasonState: state);
      try {
        Season season = event.season;
        if (season != state.season) {
          await db.updateSeason(season: season);
        } else {
          yield SingleSeasonLoaded(state: state, season: event.season);
        }
      } catch (e) {
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: e);
      }
    }

    if (event is SingleSeasonAddPlayer) {
      yield SingleSeasonSaving(singleSeasonState: state);
      try {
        if (!state.season.playerUids.containsKey(event.playerUid)) {
          await db.addSeasonPlayer(
              seasonUid: seasonUid, playerUid: event.playerUid);
        } else {
          yield SingleSeasonLoaded(state: state);
        }
      } catch (e) {
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: e);
      }
    }

    if (event is SingleSeasonRemovePlayer) {
      yield SingleSeasonSaving(singleSeasonState: state);
      try {
        if (state.season.playerUids.containsKey(event.playerUid)) {
          await db.deleteSeasonPlayer(
              seasonUid: seasonUid, playerUid: event.playerUid);
        } else {
          yield SingleSeasonLoaded(state: state);
        }
      } catch (e) {
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: e);
      }
    }

    if (event is SingleSeasonDelete) {
      try {
        await db.deleteSeason(seasonUid: seasonUid);
      } catch (e) {
        yield SingleSeasonSaveFailed(singleSeasonState: state, error: e);
      }
    }

    if (event is _SingleSeasonUpdateGames) {
      yield SingleSeasonLoaded(
          state: state, games: event.games, loadedGames: true);
    }

    if (event is SingleSeasonLoadGames) {
      _lock.synchronized(() {
        _gameSub = db
            .getSeasonGames(seasonUid: this.seasonUid)
            .listen((BuiltList<Game> games) {
          add(_SingleSeasonUpdateGames(games: games));
        });
      });
    }
  }
}
