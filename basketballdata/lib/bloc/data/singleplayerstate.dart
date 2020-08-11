import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../basketballdata.dart';
import '../../serializers.dart';

part 'singleplayerstate.g.dart';

class SinglePlayerStateType extends EnumClass {
  static Serializer<SinglePlayerStateType> get serializer =>
      _$singlePlayerStateTypeSerializer;

  static const SinglePlayerStateType Uninitialized = _$uninitialized;
  static const SinglePlayerStateType Loaded = _$loaded;
  static const SinglePlayerStateType SaveSuccessful = _$saveSuccessful;
  static const SinglePlayerStateType SaveFailed = _$saveFailed;
  static const SinglePlayerStateType Deleted = _$deleted;
  static const SinglePlayerStateType Saving = _$saving;

  const SinglePlayerStateType._(String name) : super(name);

  static BuiltSet<SinglePlayerStateType> get values => _$values;

  static SinglePlayerStateType valueOf(String name) => _$valueOf(name);
}

///
/// The data associated with the player.
///
@BuiltValue(instantiable: false)
abstract class SinglePlayerState {
  @nullable
  Player get player;
  // Don't track the games or save them out to disk.
  @BuiltValueField(serialize: false)
  bool get loadedGames;
  @BuiltValueField(serialize: false)
  BuiltList<Game> get games;
  SinglePlayerStateType get type;

  static SinglePlayerStateBuilder fromState(
      SinglePlayerState state, SinglePlayerStateBuilder builder) {
    return builder
      ..loadedGames = state.loadedGames
      ..player = state.player?.toBuilder()
      ..games = state.games.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// We have a player, default state.
///
abstract class SinglePlayerLoaded
    implements
        SinglePlayerState,
        Built<SinglePlayerLoaded, SinglePlayerLoadedBuilder> {
  SinglePlayerLoaded._();
  factory SinglePlayerLoaded(
          [void Function(SinglePlayerLoadedBuilder) updates]) =
      _$SinglePlayerLoaded;

  static SinglePlayerLoadedBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerLoadedBuilder b) => b
    ..type = SinglePlayerStateType.Loaded
    ..loadedGames = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerLoaded.serializer, this);
  }

  static SinglePlayerLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SinglePlayerLoaded.serializer, jsonData);
  }

  static Serializer<SinglePlayerLoaded> get serializer =>
      _$singlePlayerLoadedSerializer;
}

///
/// Saving operation in progress.
///
abstract class SinglePlayerSaving
    implements
        SinglePlayerState,
        Built<SinglePlayerSaving, SinglePlayerSavingBuilder> {
  @override
  String toString() {
    return 'SinglePlayerSaving{}';
  }

  static SinglePlayerSavingBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerSavingBuilder());
  }

  static void _initializeBuilder(SinglePlayerSavingBuilder b) => b
    ..type = SinglePlayerStateType.Saving
    ..loadedGames = false;

  SinglePlayerSaving._();
  factory SinglePlayerSaving(
          [void Function(SinglePlayerSavingBuilder) updates]) =
      _$SinglePlayerSaving;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerSaving.serializer, this);
  }

  static SinglePlayerSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SinglePlayerSaving.serializer, jsonData);
  }

  static Serializer<SinglePlayerSaving> get serializer =>
      _$singlePlayerSavingSerializer;
}

///
/// Save operation was successful.
///
abstract class SinglePlayerSaveSuccessful
    implements
        SinglePlayerState,
        Built<SinglePlayerSaveSuccessful, SinglePlayerSaveSuccessfulBuilder> {
  @override
  String toString() {
    return 'SinglePlayerSaveSuccessful{}';
  }

  static void _initializeBuilder(SinglePlayerSaveSuccessfulBuilder b) => b
    ..type = SinglePlayerStateType.SaveSuccessful
    ..loadedGames = false;

  SinglePlayerSaveSuccessful._();
  factory SinglePlayerSaveSuccessful(
          [void Function(SinglePlayerSaveSuccessfulBuilder) updates]) =
      _$SinglePlayerSaveSuccessful;

  static SinglePlayerSaveSuccessfulBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(
        state, SinglePlayerSaveSuccessfulBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SinglePlayerSaveSuccessful.serializer, this);
  }

  static SinglePlayerSaveSuccessful fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerSaveSuccessful.serializer, jsonData);
  }

  static Serializer<SinglePlayerSaveSuccessful> get serializer =>
      _$singlePlayerSaveSuccessfulSerializer;
}

///
/// Saving operation failed (goes back to loaded for success).
///
abstract class SinglePlayerSaveFailed
    implements
        SinglePlayerState,
        Built<SinglePlayerSaveFailed, SinglePlayerSaveFailedBuilder> {
  Error get error;

  @override
  String toString() {
    return 'SinglePlayerSaveFailed{}';
  }

  static void _initializeBuilder(SinglePlayerSaveFailedBuilder b) => b
    ..type = SinglePlayerStateType.SaveFailed
    ..loadedGames = false;

  SinglePlayerSaveFailed._();
  factory SinglePlayerSaveFailed(
          [void Function(SinglePlayerSaveFailedBuilder) updates]) =
      _$SinglePlayerSaveFailed;

  static SinglePlayerSaveFailedBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerSaveFailedBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerSaveFailed.serializer, this);
  }

  static SinglePlayerSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerSaveFailed.serializer, jsonData);
  }

  static Serializer<SinglePlayerSaveFailed> get serializer =>
      _$singlePlayerSaveFailedSerializer;
}

///
/// Player got deleted.
///
abstract class SinglePlayerDeleted
    implements
        SinglePlayerState,
        Built<SinglePlayerDeleted, SinglePlayerDeletedBuilder> {
  SinglePlayerDeleted._();
  factory SinglePlayerDeleted(
          [void Function(SinglePlayerDeletedBuilder) updates]) =
      _$SinglePlayerDeleted;
  @override
  String toString() {
    return 'SinglePlayerDeleted{}';
  }

  static void _initializeBuilder(SinglePlayerDeletedBuilder b) => b
    ..type = SinglePlayerStateType.Deleted
    ..player = null
    ..loadedGames = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerDeleted.serializer, this);
  }

  static SinglePlayerDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerDeleted.serializer, jsonData);
  }

  static Serializer<SinglePlayerDeleted> get serializer =>
      _$singlePlayerDeletedSerializer;
}

///
/// Player got deleted.
///
abstract class SinglePlayerUninitialized
    implements
        SinglePlayerState,
        Built<SinglePlayerUninitialized, SinglePlayerUninitializedBuilder> {
  SinglePlayerUninitialized._();
  factory SinglePlayerUninitialized(
          [void Function(SinglePlayerUninitializedBuilder) updates]) =
      _$SinglePlayerUninitialized;

  static void _initializeBuilder(SinglePlayerUninitializedBuilder b) => b
    ..type = SinglePlayerStateType.Uninitialized
    ..player = null
    ..loadedGames = false;

  @override
  String toString() {
    return 'SinglePlayerUninitialized{}';
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SinglePlayerUninitialized.serializer, this);
  }

  static SinglePlayerUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerUninitialized.serializer, jsonData);
  }

  static Serializer<SinglePlayerUninitialized> get serializer =>
      _$singlePlayerUninitializedSerializer;
}
