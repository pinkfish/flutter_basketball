import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../basketballdata.dart';
import '../../serializers.dart';

part 'singleseasonstate.g.dart';

///
/// The type of the bloc state for the season.  THis is used to serialize
/// and deserialize the class.
///
class SingleSeasonStateType extends EnumClass {
  static Serializer<SingleSeasonStateType> get serializer =>
      _$singleSeasonStateTypeSerializer;

  static const SingleSeasonStateType Uninitialized = _$uninitialized;
  static const SingleSeasonStateType Loaded = _$loaded;
  static const SingleSeasonStateType SaveSuccessful = _$saveSuccessful;
  static const SingleSeasonStateType SaveFailed = _$saveFailed;
  static const SingleSeasonStateType Deleted = _$deleted;
  static const SingleSeasonStateType Saving = _$saving;

  const SingleSeasonStateType._(String name) : super(name);

  static BuiltSet<SingleSeasonStateType> get values => _$values;

  static SingleSeasonStateType valueOf(String name) => _$valueOf(name);
}

///
/// The data associated with the season.
///
@BuiltValue(instantiable: false)
abstract class SingleSeasonState {
  @nullable
  Season season;
  BuiltList<Game> games;
  bool loadedGames;
  // Don't save all the player details.
  @memoized
  BuiltMap<String, Player> players;
  @memoized
  bool loadedPlayers;

  static SingleSeasonStateBuilder fromState(
      SingleSeasonState state, SingleSeasonStateBuilder builder) {
    return builder
      ..loadedSeasons = state.loadedSeasons
      ..season = state.season?.toBuilder()
      ..games = state.games.toBuilder()
      ..loadedPlayers = state.loadedPlayers
      ..players = state.players.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// We have a season, default state.
///
abstract class SingleSeasonLoaded
    implements
        SingleSeasonState,
        Built<SingleSeasonLoaded, SingleSeasonLoadedBuilder> {
  SingleSeasonLoaded._();
  factory SingleSeasonLoaded(
          [void Function(SingleSeasonLoadedBuilder) updates]) =
      _$SingleSeasonLoaded;

  static SingleSeasonLoadedBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonLoadedBuilder b) => b
    ..type = SingleSeasonStateType.Loaded
    ..loadedSeasons = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonLoaded.serializer, this);
  }

  static SingleSeasonLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSeasonLoaded.serializer, jsonData);
  }

  static Serializer<SingleSeasonLoaded> get serializer =>
      _$singleSeasonLoadedSerializer;
}

///
/// Saving operation in progress.
///
abstract class SingleSeasonSaving
    implements
        SingleSeasonState,
        Built<SingleSeasonSaving, SingleSeasonSavingBuilder> {
  @override
  String toString() {
    return 'SingleSeasonSaving{}';
  }

  static SingleSeasonSavingBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonSavingBuilder());
  }

  static void _initializeBuilder(SingleSeasonSavingBuilder b) => b
    ..type = SingleSeasonStateType.Saving
    ..loadedSeasons = false;

  SingleSeasonSaving._();
  factory SingleSeasonSaving(
          [void Function(SingleSeasonSavingBuilder) updates]) =
      _$SingleSeasonSaving;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonSaving.serializer, this);
  }

  static SingleSeasonSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSeasonSaving.serializer, jsonData);
  }

  static Serializer<SingleSeasonSaving> get serializer =>
      _$singleSeasonSavingSerializer;
}

///
/// Save operation was successful.
///
abstract class SingleSeasonSaveSuccessful
    implements
        SingleSeasonState,
        Built<SingleSeasonSaveSuccessful, SingleSeasonSaveSuccessfulBuilder> {
  @override
  String toString() {
    return 'SingleSeasonSaveSuccessful{}';
  }

  static void _initializeBuilder(SingleSeasonSaveSuccessfulBuilder b) => b
    ..type = SingleSeasonStateType.SaveSuccessful
    ..loadedSeasons = false;

  SingleSeasonSaveSuccessful._();
  factory SingleSeasonSaveSuccessful(
          [void Function(SingleSeasonSaveSuccessfulBuilder) updates]) =
      _$SingleSeasonSaveSuccessful;

  static SingleSeasonSaveSuccessfulBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(
        state, SingleSeasonSaveSuccessfulBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleSeasonSaveSuccessful.serializer, this);
  }

  static SingleSeasonSaveSuccessful fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonSaveSuccessful.serializer, jsonData);
  }

  static Serializer<SingleSeasonSaveSuccessful> get serializer =>
      _$singleSeasonSaveSuccessfulSerializer;
}

///
/// Saving operation failed (goes back to loaded for success).
///
abstract class SingleSeasonSaveFailed
    implements
        SingleSeasonState,
        Built<SingleSeasonSaveFailed, SingleSeasonSaveFailedBuilder> {
  Error get error;

  @override
  String toString() {
    return 'SingleSeasonSaveFailed{}';
  }

  static void _initializeBuilder(SingleSeasonSaveFailedBuilder b) => b
    ..type = SingleSeasonStateType.SaveFailed
    ..loadedSeasons = false;

  SingleSeasonSaveFailed._();
  factory SingleSeasonSaveFailed(
          [void Function(SingleSeasonSaveFailedBuilder) updates]) =
      _$SingleSeasonSaveFailed;

  static SingleSeasonSaveFailedBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonSaveFailedBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonSaveFailed.serializer, this);
  }

  static SingleSeasonSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleSeasonSaveFailed> get serializer =>
      _$singleSeasonSaveFailedSerializer;
}

///
/// Season got deleted.
///
abstract class SingleSeasonDeleted
    implements
        SingleSeasonState,
        Built<SingleSeasonDeleted, SingleSeasonDeletedBuilder> {
  SingleSeasonDeleted._();
  factory SingleSeasonDeleted(
          [void Function(SingleSeasonDeletedBuilder) updates]) =
      _$SingleSeasonDeleted;
  @override
  String toString() {
    return 'SingleSeasonDeleted{}';
  }

  static void _initializeBuilder(SingleSeasonDeletedBuilder b) => b
    ..type = SingleSeasonStateType.Deleted
    ..season = null
    ..loadedSeasons = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonSaveFailed.serializer, this);
  }

  static SingleSeasonDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonDeleted.serializer, jsonData);
  }

  static Serializer<SingleSeasonDeleted> get serializer =>
      _$singleSeasonDeletedSerializer;
}

///
/// Season got deleted.
///
abstract class SingleSeasonUninitialized
    implements
        SingleSeasonState,
        Built<SingleSeasonUninitialized, SingleSeasonUninitializedBuilder> {
  SingleSeasonUninitialized._();
  factory SingleSeasonUninitialized(
          [void Function(SingleSeasonUninitializedBuilder) updates]) =
      _$SingleSeasonUninitialized;

  static void _initializeBuilder(SingleSeasonUninitializedBuilder b) => b
    ..type = SingleSeasonStateType.Uninitialized
    ..season = null
    ..loadedSeasons = false;

  @override
  String toString() {
    return 'SingleSeasonUninitialized{}';
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleSeasonUninitialized.serializer, this);
  }

  static SingleSeasonUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonUninitialized.serializer, jsonData);
  }

  static Serializer<SingleSeasonUninitialized> get serializer =>
      _$singleSeasonUninitializedSerializer;
}
