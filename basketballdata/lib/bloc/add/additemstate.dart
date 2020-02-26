import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class AddItemState extends Equatable {
  AddItemState() : super();
}

///
/// No data at all yet.
///
class AddItemUninitialized extends AddItemState {
  AddItemUninitialized();

  @override
  String toString() {
    return 'AddItemUninitialized{}';
  }

  @override
  List<Object> get props => null;
}

///
/// Doing something.
///
class AddItemSaving extends AddItemState {
  AddItemSaving();

  @override
  String toString() {
    return 'AddItemSaving{}';
  }

  @override
  List<Object> get props => null;
}

///
/// Invalid arguements.
///
class AddItemInvalidArguments extends AddItemState {
  final Error error;

  AddItemInvalidArguments({@required this.error}) : super();

  String toString() {
    return 'AddItemInvalidArguments{}';
  }

  @override
  List<Object> get props => [error];
}

///
/// Data is now loaded.
///
class AddItemDone extends AddItemState {
  final String uid;

  AddItemDone({@required this.uid}) : super();

  @override
  String toString() {
    return 'AddItemDone{}';
  }

  @override
  List<Object> get props => [uid];
}

///
/// Failed to save the player (this could be an accept or an add).
///
class AddItemSaveFailed extends AddItemState {
  final Error error;

  AddItemSaveFailed({@required this.error}) : super();

  @override
  String toString() {
    return 'AddItemSaveFailed{}';
  }

  @override
  List<Object> get props => [error];
}
