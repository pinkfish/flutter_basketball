import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../basketballdata.dart';
import '../../serializers.dart';

part 'singlegamestate.g.dart';

///
/// The type of the bloc state for the game.  THis is used to serialize
/// and deserialize the class.
///
class SingleGameStateType extends EnumClass {
  static Serializer<SingleGameStateType> get serializer =>
      _$singleGameStateTypeSerializer;

  static const SingleGameStateType Uninitialized = _$uninitialized;
  static const SingleGameStateType Loaded = _$loaded;
  static const SingleGameStateType SaveSuccessful = _$saveSuccessful;
  static const SingleGameStateType SaveFailed = _$saveFailed;
  static const SingleGameStateType Deleted = _$deleted;
  static const SingleGameStateType Saving = _$saving;

  const SingleGameStateType._(String name) : super(name);

  static BuiltSet<SingleGameStateType> get values => _$values;

  static SingleGameStateType valueOf(String name) => _$valueOf(name);
}

///
/// The data associated with the game.
///
@BuiltValue(instantiable: false)
abstract class SingleGameState {
  @nullable
  Game get game;
  @BuiltValueField(serialize: false)
  bool get loadedGameEvents;
  @BuiltValueField(serialize: false)
  BuiltList<GameEvent> get gameEvents;
  @BuiltValueField(serialize: false)
  bool get loadedMedia;
  @BuiltValueField(serialize: false)
  BuiltList<MediaInfo> get media;
  @BuiltValueField(serialize: false)
  bool get loadedPlayers;
  @BuiltValueField(serialize: false)
  BuiltMap<String, Player> get players;

  SingleGameStateType get type;

  static SingleGameStateBuilder fromState(
      SingleGameState state, SingleGameStateBuilder builder) {
    return builder
      ..game = state.game?.toBuilder()
      ..gameEvents = state.gameEvents.toBuilder()
      ..loadedGameEvents = state.loadedGameEvents
      ..loadedMedia = state.loadedMedia
      ..media = state.media.toBuilder()
      ..loadedPlayers = state.loadedPlayers
      ..players = state.players.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// We have a game, default state.
///
abstract class SingleGameLoaded
    implements
        SingleGameState,
        Built<SingleGameLoaded, SingleGameLoadedBuilder> {
  SingleGameLoaded._();
  factory SingleGameLoaded([void Function(SingleGameLoadedBuilder) updates]) =
      _$SingleGameLoaded;

  static SingleGameLoadedBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameLoadedBuilder b) => b
    ..type = SingleGameStateType.Loaded
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameLoaded.serializer, this);
  }

  static SingleGameLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameLoaded.serializer, jsonData);
  }

  static Serializer<SingleGameLoaded> get serializer =>
      _$singleGameLoadedSerializer;
}

///
/// We have a game, default state.
///
abstract class SingleGameChangeEvents
    implements
        SingleGameState,
        Built<SingleGameChangeEvents, SingleGameChangeEventsBuilder> {
  BuiltList<GameEvent> get removedEvents;
  BuiltList<GameEvent> get newEvents;

  SingleGameChangeEvents._();
  factory SingleGameChangeEvents(
          [void Function(SingleGameChangeEventsBuilder) updates]) =
      _$SingleGameChangeEvents;

  static SingleGameChangeEventsBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameChangeEventsBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameChangeEventsBuilder b) => b
    ..type = SingleGameStateType.Loaded
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameChangeEvents.serializer, this);
  }

  static SingleGameChangeEvents fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameChangeEvents.serializer, jsonData);
  }

  static Serializer<SingleGameChangeEvents> get serializer =>
      _$singleGameChangeEventsSerializer;
}

///
/// Saving operation in progress.
///
abstract class SingleGameSaving
    implements
        SingleGameState,
        Built<SingleGameSaving, SingleGameSavingBuilder> {
  @override
  String toString() {
    return 'SingleGameSaving{}';
  }

  static SingleGameSavingBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameSavingBuilder());
  }

  static void _initializeBuilder(SingleGameSavingBuilder b) => b
    ..type = SingleGameStateType.Saving
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  SingleGameSaving._();
  factory SingleGameSaving([void Function(SingleGameSavingBuilder) updates]) =
      _$SingleGameSaving;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaving.serializer, this);
  }

  static SingleGameSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameSaving.serializer, jsonData);
  }

  static Serializer<SingleGameSaving> get serializer =>
      _$singleGameSavingSerializer;
}

///
/// Save operation was successful.
///
abstract class SingleGameSaveSuccessful
    implements
        SingleGameState,
        Built<SingleGameSaveSuccessful, SingleGameSaveSuccessfulBuilder> {
  @override
  String toString() {
    return 'SingleGameSaveSuccessful{}';
  }

  static void _initializeBuilder(SingleGameSaveSuccessfulBuilder b) => b
    ..type = SingleGameStateType.SaveSuccessful
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  SingleGameSaveSuccessful._();
  factory SingleGameSaveSuccessful(
          [void Function(SingleGameSaveSuccessfulBuilder) updates]) =
      _$SingleGameSaveSuccessful;

  static SingleGameSaveSuccessfulBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameSaveSuccessfulBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaveSuccessful.serializer, this);
  }

  static SingleGameSaveSuccessful fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameSaveSuccessful.serializer, jsonData);
  }

  static Serializer<SingleGameSaveSuccessful> get serializer =>
      _$singleGameSaveSuccessfulSerializer;
}

///
/// Saving operation failed (goes back to loaded for success).
///
abstract class SingleGameSaveFailed
    implements
        SingleGameState,
        Built<SingleGameSaveFailed, SingleGameSaveFailedBuilder> {
  Error get error;

  @override
  String toString() {
    return 'SingleGameSaveFailed{}';
  }

  static void _initializeBuilder(SingleGameSaveFailedBuilder b) => b
    ..type = SingleGameStateType.SaveFailed
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  SingleGameSaveFailed._();
  factory SingleGameSaveFailed(
          [void Function(SingleGameSaveFailedBuilder) updates]) =
      _$SingleGameSaveFailed;

  static SingleGameSaveFailedBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameSaveFailedBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaveFailed.serializer, this);
  }

  static SingleGameSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleGameSaveFailed> get serializer =>
      _$singleGameSaveFailedSerializer;
}

///
/// Game got deleted.
///
abstract class SingleGameDeleted
    implements
        SingleGameState,
        Built<SingleGameDeleted, SingleGameDeletedBuilder> {
  SingleGameDeleted._();
  factory SingleGameDeleted([void Function(SingleGameDeletedBuilder) updates]) =
      _$SingleGameDeleted;
  @override
  String toString() {
    return 'SingleGameDeleted{}';
  }

  static void _initializeBuilder(SingleGameDeletedBuilder b) => b
    ..type = SingleGameStateType.Deleted
    ..game = null
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameDeleted.serializer, this);
  }

  static SingleGameDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameDeleted.serializer, jsonData);
  }

  static Serializer<SingleGameDeleted> get serializer =>
      _$singleGameDeletedSerializer;
}

///
/// Game got deleted.
///
abstract class SingleGameUninitialized
    implements
        SingleGameState,
        Built<SingleGameUninitialized, SingleGameUninitializedBuilder> {
  SingleGameUninitialized._();
  factory SingleGameUninitialized(
          [void Function(SingleGameUninitializedBuilder) updates]) =
      _$SingleGameUninitialized;

  static void _initializeBuilder(SingleGameUninitializedBuilder b) => b
    ..type = SingleGameStateType.Uninitialized
    ..game = null
    ..loadedPlayers = false
    ..loadedMedia = false
    ..loadedGameEvents = false;

  @override
  String toString() {
    return 'SingleGameUninitialized{}';
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameUninitialized.serializer, this);
  }

  static SingleGameUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameUninitialized.serializer, jsonData);
  }

  static Serializer<SingleGameUninitialized> get serializer =>
      _$singleGameUninitializedSerializer;
}
