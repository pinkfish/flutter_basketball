import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../basketballdata.dart';
import '../../serializers.dart';

part 'teamsblocstate.g.dart';

class TeamsBlocStateType extends EnumClass {
  static Serializer<TeamsBlocStateType> get serializer =>
      _$teamsBlocStateTypeSerializer;

  static const TeamsBlocStateType Uninitialized = _$uninitialized;
  static const TeamsBlocStateType Loaded = _$loaded;

  const TeamsBlocStateType._(String name) : super(name);

  static BuiltSet<TeamsBlocStateType> get values => _$values;

  static TeamsBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the teams bloc.  It tracks all the
/// exciting teams stuff.
///
@BuiltValue(instantiable: false)
abstract class TeamsBlocState {
  BuiltList<Team> get teams;
  TeamsBlocStateType get type;

  static TeamsBlocStateBuilder fromState(
      TeamsBlocState state, TeamsBlocStateBuilder builder) {
    return builder..teams = state.teams.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// The teams loaded from the database.
///
abstract class TeamsBlocLoaded
    implements TeamsBlocState, Built<TeamsBlocLoaded, TeamsBlocLoadedBuilder> {
  TeamsBlocLoaded._();
  factory TeamsBlocLoaded([void Function(TeamsBlocLoadedBuilder) updates]) =
      _$TeamsBlocLoaded;

  static TeamsBlocLoadedBuilder fromState(TeamsBlocState state) {
    return TeamsBlocState.fromState(state, TeamsBlocLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(TeamsBlocLoadedBuilder b) =>
      b..type = TeamsBlocStateType.Loaded;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(TeamsBlocLoaded.serializer, this);
  }

  static TeamsBlocLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(TeamsBlocLoaded.serializer, jsonData);
  }

  static Serializer<TeamsBlocLoaded> get serializer =>
      _$teamsBlocLoadedSerializer;
}

///
/// The teams bloc that is unitialized.
///
abstract class TeamsBlocUninitialized
    implements
        TeamsBlocState,
        Built<TeamsBlocUninitialized, TeamsBlocUninitializedBuilder> {
  TeamsBlocUninitialized._();
  factory TeamsBlocUninitialized(
          [void Function(TeamsBlocUninitializedBuilder) updates]) =
      _$TeamsBlocUninitialized;

  static TeamsBlocUninitializedBuilder fromState(TeamsBlocState state) {
    return TeamsBlocState.fromState(state, TeamsBlocUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(TeamsBlocUninitializedBuilder b) =>
      b..type = TeamsBlocStateType.Uninitialized;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(TeamsBlocUninitialized.serializer, this);
  }

  static TeamsBlocUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        TeamsBlocUninitialized.serializer, jsonData);
  }

  static Serializer<TeamsBlocUninitialized> get serializer =>
      _$teamsBlocUninitializedSerializer;
}
