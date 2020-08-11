import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../basketballdata.dart';
import '../../serializers.dart';

part 'singleteamstate.g.dart';

///
/// The type of the bloc state for the team.  THis is used to serialize
/// and deserialize the class.
///
class SingleTeamStateType extends EnumClass {
  static Serializer<SingleTeamStateType> get serializer =>
      _$singleTeamStateTypeSerializer;

  static const SingleTeamStateType Uninitialized = _$uninitialized;
  static const SingleTeamStateType Loaded = _$loaded;
  static const SingleTeamStateType SaveSuccessful = _$saveSuccessful;
  static const SingleTeamStateType SaveFailed = _$saveFailed;
  static const SingleTeamStateType Deleted = _$deleted;
  static const SingleTeamStateType Saving = _$saving;

  const SingleTeamStateType._(String name) : super(name);

  static BuiltSet<SingleTeamStateType> get values => _$values;

  static SingleTeamStateType valueOf(String name) => _$valueOf(name);
}

///
/// The data associated with the team.
///
@BuiltValue(instantiable: false)
abstract class SingleTeamState {
  @nullable
  Team get team;
  bool get loadedSeasons;
  BuiltList<Season> get seasons;
  SingleTeamStateType get type;

  static SingleTeamStateBuilder fromState(
      SingleTeamState state, SingleTeamStateBuilder builder) {
    return builder
      ..loadedSeasons = state.loadedSeasons
      ..team = state.team?.toBuilder()
      ..seasons = state.seasons.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// We have a team, default state.
///
abstract class SingleTeamLoaded
    implements
        SingleTeamState,
        Built<SingleTeamLoaded, SingleTeamLoadedBuilder> {
  SingleTeamLoaded._();
  factory SingleTeamLoaded([void Function(SingleTeamLoadedBuilder) updates]) =
      _$SingleTeamLoaded;

  static SingleTeamLoadedBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamLoadedBuilder b) => b
    ..type = SingleTeamStateType.Loaded
    ..loadedSeasons = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamLoaded.serializer, this);
  }

  static SingleTeamLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamLoaded.serializer, jsonData);
  }

  static Serializer<SingleTeamLoaded> get serializer =>
      _$singleTeamLoadedSerializer;
}

///
/// Saving operation in progress.
///
abstract class SingleTeamSaving
    implements
        SingleTeamState,
        Built<SingleTeamSaving, SingleTeamSavingBuilder> {
  @override
  String toString() {
    return 'SingleTeamSaving{}';
  }

  static SingleTeamSavingBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamSavingBuilder());
  }

  static void _initializeBuilder(SingleTeamSavingBuilder b) => b
    ..type = SingleTeamStateType.Saving
    ..loadedSeasons = false;

  SingleTeamSaving._();
  factory SingleTeamSaving([void Function(SingleTeamSavingBuilder) updates]) =
      _$SingleTeamSaving;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamSaving.serializer, this);
  }

  static SingleTeamSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamSaving.serializer, jsonData);
  }

  static Serializer<SingleTeamSaving> get serializer =>
      _$singleTeamSavingSerializer;
}

///
/// Save operation was successful.
///
abstract class SingleTeamSaveSuccessful
    implements
        SingleTeamState,
        Built<SingleTeamSaveSuccessful, SingleTeamSaveSuccessfulBuilder> {
  @override
  String toString() {
    return 'SingleTeamSaveSuccessful{}';
  }

  static void _initializeBuilder(SingleTeamSaveSuccessfulBuilder b) => b
    ..type = SingleTeamStateType.SaveSuccessful
    ..loadedSeasons = false;

  SingleTeamSaveSuccessful._();
  factory SingleTeamSaveSuccessful(
          [void Function(SingleTeamSaveSuccessfulBuilder) updates]) =
      _$SingleTeamSaveSuccessful;

  static SingleTeamSaveSuccessfulBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamSaveSuccessfulBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamSaveSuccessful.serializer, this);
  }

  static SingleTeamSaveSuccessful fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSaveSuccessful.serializer, jsonData);
  }

  static Serializer<SingleTeamSaveSuccessful> get serializer =>
      _$singleTeamSaveSuccessfulSerializer;
}

///
/// Saving operation failed (goes back to loaded for success).
///
abstract class SingleTeamSaveFailed
    implements
        SingleTeamState,
        Built<SingleTeamSaveFailed, SingleTeamSaveFailedBuilder> {
  Error get error;

  @override
  String toString() {
    return 'SingleTeamSaveFailed{}';
  }

  static void _initializeBuilder(SingleTeamSaveFailedBuilder b) => b
    ..type = SingleTeamStateType.SaveFailed
    ..loadedSeasons = false;

  SingleTeamSaveFailed._();
  factory SingleTeamSaveFailed(
          [void Function(SingleTeamSaveFailedBuilder) updates]) =
      _$SingleTeamSaveFailed;

  static SingleTeamSaveFailedBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamSaveFailedBuilder());
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamSaveFailed.serializer, this);
  }

  static SingleTeamSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleTeamSaveFailed> get serializer =>
      _$singleTeamSaveFailedSerializer;
}

///
/// Team got deleted.
///
abstract class SingleTeamDeleted
    implements
        SingleTeamState,
        Built<SingleTeamDeleted, SingleTeamDeletedBuilder> {
  SingleTeamDeleted._();
  factory SingleTeamDeleted([void Function(SingleTeamDeletedBuilder) updates]) =
      _$SingleTeamDeleted;
  @override
  String toString() {
    return 'SingleTeamDeleted{}';
  }

  static void _initializeBuilder(SingleTeamDeletedBuilder b) => b
    ..type = SingleTeamStateType.Deleted
    ..team = null
    ..loadedSeasons = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamDeleted.serializer, this);
  }

  static SingleTeamDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamDeleted.serializer, jsonData);
  }

  static Serializer<SingleTeamDeleted> get serializer =>
      _$singleTeamDeletedSerializer;
}

///
/// Team got deleted.
///
abstract class SingleTeamUninitialized
    implements
        SingleTeamState,
        Built<SingleTeamUninitialized, SingleTeamUninitializedBuilder> {
  SingleTeamUninitialized._();
  factory SingleTeamUninitialized(
          [void Function(SingleTeamUninitializedBuilder) updates]) =
      _$SingleTeamUninitialized;

  static void _initializeBuilder(SingleTeamUninitializedBuilder b) => b
    ..type = SingleTeamStateType.Uninitialized
    ..team = null
    ..loadedSeasons = false;

  @override
  String toString() {
    return 'SingleTeamUninitialized{}';
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamUninitialized.serializer, this);
  }

  static SingleTeamUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamUninitialized.serializer, jsonData);
  }

  static Serializer<SingleTeamUninitialized> get serializer =>
      _$singleTeamUninitializedSerializer;
}
