// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Team> _$teamSerializer = new _$TeamSerializer();

class _$TeamSerializer implements StructuredSerializer<Team> {
  @override
  final Iterable<Type> types = const [Team, _$Team];
  @override
  final String wireName = 'Team';

  @override
  Iterable<Object> serialize(Serializers serializers, Team object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'playerUids',
      serializers.serialize(object.playerUids,
          specifiedType: const FullType(
              BuiltMap, const [const FullType(String), const FullType(bool)])),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];
    if (object.uid != null) {
      result
        ..add('uid')
        ..add(serializers.serialize(object.uid,
            specifiedType: const FullType(String)));
    }
    if (object.photoUid != null) {
      result
        ..add('photoUid')
        ..add(serializers.serialize(object.photoUid,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  Team deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TeamBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'uid':
          result.uid = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'photoUid':
          result.photoUid = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'playerUids':
          result.playerUids.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(bool)])));
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$Team extends Team {
  @override
  final String uid;
  @override
  final String photoUid;
  @override
  final BuiltMap<String, bool> playerUids;
  @override
  final String name;

  factory _$Team([void Function(TeamBuilder) updates]) =>
      (new TeamBuilder()..update(updates)).build();

  _$Team._({this.uid, this.photoUid, this.playerUids, this.name}) : super._() {
    if (playerUids == null) {
      throw new BuiltValueNullFieldError('Team', 'playerUids');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('Team', 'name');
    }
  }

  @override
  Team rebuild(void Function(TeamBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TeamBuilder toBuilder() => new TeamBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Team &&
        uid == other.uid &&
        photoUid == other.photoUid &&
        playerUids == other.playerUids &&
        name == other.name;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, uid.hashCode), photoUid.hashCode), playerUids.hashCode),
        name.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Team')
          ..add('uid', uid)
          ..add('photoUid', photoUid)
          ..add('playerUids', playerUids)
          ..add('name', name))
        .toString();
  }
}

class TeamBuilder implements Builder<Team, TeamBuilder> {
  _$Team _$v;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  String _photoUid;
  String get photoUid => _$this._photoUid;
  set photoUid(String photoUid) => _$this._photoUid = photoUid;

  MapBuilder<String, bool> _playerUids;
  MapBuilder<String, bool> get playerUids =>
      _$this._playerUids ??= new MapBuilder<String, bool>();
  set playerUids(MapBuilder<String, bool> playerUids) =>
      _$this._playerUids = playerUids;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  TeamBuilder();

  TeamBuilder get _$this {
    if (_$v != null) {
      _uid = _$v.uid;
      _photoUid = _$v.photoUid;
      _playerUids = _$v.playerUids?.toBuilder();
      _name = _$v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Team other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Team;
  }

  @override
  void update(void Function(TeamBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Team build() {
    _$Team _$result;
    try {
      _$result = _$v ??
          new _$Team._(
              uid: uid,
              photoUid: photoUid,
              playerUids: playerUids.build(),
              name: name);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'playerUids';
        playerUids.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Team', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
