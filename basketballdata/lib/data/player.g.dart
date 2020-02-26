// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Player> _$playerSerializer = new _$PlayerSerializer();

class _$PlayerSerializer implements StructuredSerializer<Player> {
  @override
  final Iterable<Type> types = const [Player, _$Player];
  @override
  final String wireName = 'Player';

  @override
  Iterable<Object> serialize(Serializers serializers, Player object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'jerseyNumber',
      serializers.serialize(object.jerseyNumber,
          specifiedType: const FullType(num)),
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
  Player deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new PlayerBuilder();

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
        case 'jerseyNumber':
          result.jerseyNumber = serializers.deserialize(value,
              specifiedType: const FullType(num)) as num;
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

class _$Player extends Player {
  @override
  final String uid;
  @override
  final String photoUid;
  @override
  final num jerseyNumber;
  @override
  final String name;

  factory _$Player([void Function(PlayerBuilder) updates]) =>
      (new PlayerBuilder()..update(updates)).build();

  _$Player._({this.uid, this.photoUid, this.jerseyNumber, this.name})
      : super._() {
    if (jerseyNumber == null) {
      throw new BuiltValueNullFieldError('Player', 'jerseyNumber');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('Player', 'name');
    }
  }

  @override
  Player rebuild(void Function(PlayerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlayerBuilder toBuilder() => new PlayerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Player &&
        uid == other.uid &&
        photoUid == other.photoUid &&
        jerseyNumber == other.jerseyNumber &&
        name == other.name;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, uid.hashCode), photoUid.hashCode),
            jerseyNumber.hashCode),
        name.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Player')
          ..add('uid', uid)
          ..add('photoUid', photoUid)
          ..add('jerseyNumber', jerseyNumber)
          ..add('name', name))
        .toString();
  }
}

class PlayerBuilder implements Builder<Player, PlayerBuilder> {
  _$Player _$v;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  String _photoUid;
  String get photoUid => _$this._photoUid;
  set photoUid(String photoUid) => _$this._photoUid = photoUid;

  num _jerseyNumber;
  num get jerseyNumber => _$this._jerseyNumber;
  set jerseyNumber(num jerseyNumber) => _$this._jerseyNumber = jerseyNumber;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  PlayerBuilder();

  PlayerBuilder get _$this {
    if (_$v != null) {
      _uid = _$v.uid;
      _photoUid = _$v.photoUid;
      _jerseyNumber = _$v.jerseyNumber;
      _name = _$v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Player other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Player;
  }

  @override
  void update(void Function(PlayerBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Player build() {
    final _$result = _$v ??
        new _$Player._(
            uid: uid,
            photoUid: photoUid,
            jerseyNumber: jerseyNumber,
            name: name);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
