import 'dart:async';

import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../data/game.dart';

///
/// The base state for the games bloc.  It tracks all the
/// exciting games stuff.
///
abstract class GamesBlocState extends Equatable {
  final BuiltList<Game> games;

  GamesBlocState({@required this.games});

  @override
  List<Object> get props => [games];
}

///
/// The games loaded from the database.
///
class GamesBlocLoaded extends GamesBlocState {
  GamesBlocLoaded(
      {@required GamesBlocState state, @required BuiltList<Game> games})
      : super(games: games);
}

///
/// The games bloc that is unitialized.
///
class GamesBlocStateUnitialized extends GamesBlocState {}

///
/// Updates all the games in the games bloc.
///
class GamesBlocUpdateGames extends GamesBlocEvent {
  final BuiltList<Game> games;

  GamesBlocUpdateGames({this.games});

  @override
  List<Object> get props => [this.games];
}

///
/// The base class for all the events in the games bloc.
///
abstract class GamesBlocEvent extends Equatable {}

///
/// The bloc for dealing with all the games.
///
class GamesBloc extends Bloc<GamesBlocEvent, GamesBlocState> {
  final BasketballDatabase db;
  final String teamUid;
  StreamSubscription<BuiltList<Game>> _sub;

  GamesBloc({this.db, this.teamUid}) {
    _sub = db.getGames(teamUid: this.teamUid).listen(
        (BuiltList<Game> game) => add(GamesBlocUpdateGames(games: game)));
  }

  @override
  GamesBlocState get initialState => GamesBlocStateUnitialized();

  @override
  Stream<GamesBlocState> mapEventToState(GamesBlocEvent event) async* {
    if (event is GamesBlocUpdateGames) {
      yield GamesBlocLoaded(state: state, games: event.games);
    }
  }

  @override
  Future<Function> close() {
    _sub?.cancel();
    _sub = null;
    return super.close();
  }
}
