import 'dart:collection';

import 'package:basketballdata/basketballdata.dart';
import 'package:basketballdata/db/basketballdatabase.dart';
import 'package:bloc/bloc.dart';

///
/// Undo stack to deal with undoing GameEvents as they are written and
/// unwritten to the db.
///
class GameEventUndoStack extends Cubit<GameEventWithChange> {
  final _changeStack = _ChangeStack<GameEventWithChange>();
  final BasketballDatabase db;

  /// Initial value is empty.
  GameEventUndoStack({this.db}) : super(null);

  Future<void> addEvent(GameEvent ev, bool existing) async {
    var uid = await db.getGameEventId();
    ev = ev.rebuild((b) => b..uid = uid);
    emit(GameEventWithChange(ev, !existing));
  }

  @override
  void emit(GameEventWithChange state) {
    _changeStack.add(_Change<GameEventWithChange>(
      this.state,
      () {
        // Don't write existing events back out again.
        if (state.changedOnce) {
          db.setGameEvent(event: state.ev);
        }
        state.changedOnce = true;
        super.emit(state);
      },
      (val) {
        db.deleteGameEvent(gameEventUid: state.ev.uid);
        state.changedOnce = true;
        super.emit(val);
      },
    ));
  }

  /// Figure out if we have written anything in here.
  bool get isGameEmpty => !_changeStack.canRedo && !_changeStack.canUndo;

  /// Undo the last change
  void undo() => _changeStack.undo();

  /// Redo the previous change
  void redo() => _changeStack.redo();

  /// Checks whether the undo/redo stack is empty
  bool get canUndo => _changeStack.canUndo;

  /// Checks wether the undo/redo stack is at the current change
  bool get canRedo => _changeStack.canRedo;
}

class _ChangeStack<T> {
  _ChangeStack({this.limit});

  final Queue<_Change<T>> _history = ListQueue();
  final Queue<_Change<T>> _redos = ListQueue();

  int limit;

  bool get canRedo => _redos.isNotEmpty;
  bool get canUndo => _history.isNotEmpty;

  void add(_Change<T> change) {
    change.execute();
    if (limit != null && limit == 0) {
      return;
    }

    _history.addLast(change);
    _redos.clear();

    if (limit != null && _history.length > limit) {
      if (limit > 0) {
        _history.removeFirst();
      }
    }
  }

  void clear() {
    _history.clear();
    _redos.clear();
  }

  void redo() {
    if (canRedo) {
      final change = _redos.removeFirst()..execute();
      _history.addLast(change);
    }
  }

  void undo() {
    if (canUndo) {
      final change = _history.removeLast()..undo();
      _redos.addFirst(change);
    }
  }
}

class _Change<T> {
  _Change(
    this._oldValue,
    this._execute(),
    this._undo(T oldValue),
  );

  final T _oldValue;
  final Function _execute;
  final Function(T oldValue) _undo;

  void execute() => _execute();
  void undo() => _undo(_oldValue);
}

class GameEventWithChange {
  final GameEvent ev;
  bool changedOnce;

  GameEventWithChange(this.ev, this.changedOnce);
}
