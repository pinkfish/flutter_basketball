import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../basketballdata.dart';
import '../../serializers.dart';

part 'invitesstate.g.dart';

class InvitesBlocStateType extends EnumClass {
  static Serializer<InvitesBlocStateType> get serializer =>
      _$invitesBlocStateTypeSerializer;

  static const InvitesBlocStateType Uninitialized = _$uninitialized;
  static const InvitesBlocStateType Loaded = _$loaded;

  const InvitesBlocStateType._(String name) : super(name);

  static BuiltSet<InvitesBlocStateType> get values => _$values;

  static InvitesBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the invites bloc.  It tracks all the
/// exciting invites stuff.
///
@BuiltValue(instantiable: false)
abstract class InvitesBlocState {
  BuiltList<Invite> get invites;
  InvitesBlocStateType get type;

  static InvitesBlocStateBuilder fromState(
      InvitesBlocState state, InvitesBlocStateBuilder builder) {
    return builder..invites = state.invites.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// The invites loaded from the database.
///
abstract class InvitesBlocLoaded
    implements
        InvitesBlocState,
        Built<InvitesBlocLoaded, InvitesBlocLoadedBuilder> {
  InvitesBlocLoaded._();
  factory InvitesBlocLoaded([void Function(InvitesBlocLoadedBuilder) updates]) =
      _$InvitesBlocLoaded;

  static InvitesBlocLoadedBuilder fromState(InvitesBlocState state) {
    return InvitesBlocState.fromState(state, InvitesBlocLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(InvitesBlocLoadedBuilder b) =>
      b..type = InvitesBlocStateType.Loaded;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(InvitesBlocLoaded.serializer, this);
  }

  static InvitesBlocLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(InvitesBlocLoaded.serializer, jsonData);
  }

  static Serializer<InvitesBlocLoaded> get serializer =>
      _$invitesBlocLoadedSerializer;
}

///
/// The invites bloc that is unitialized.
///
abstract class InvitesBlocUninitialized
    implements
        InvitesBlocState,
        Built<InvitesBlocUninitialized, InvitesBlocUninitializedBuilder> {
  InvitesBlocUninitialized._();
  factory InvitesBlocUninitialized(
          [void Function(InvitesBlocUninitializedBuilder) updates]) =
      _$InvitesBlocUninitialized;

  static InvitesBlocUninitializedBuilder fromState(InvitesBlocState state) {
    return InvitesBlocState.fromState(state, InvitesBlocUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(InvitesBlocUninitializedBuilder b) =>
      b..type = InvitesBlocStateType.Uninitialized;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(InvitesBlocUninitialized.serializer, this);
  }

  static InvitesBlocUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        InvitesBlocUninitialized.serializer, jsonData);
  }

  static Serializer<InvitesBlocUninitialized> get serializer =>
      _$invitesBlocUninitializedSerializer;
}
