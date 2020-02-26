// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gameevent.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GameEvent> _$gameEventSerializer = new _$GameEventSerializer();

class _$GameEventSerializer implements StructuredSerializer<GameEvent> {
  @override
  final Iterable<Type> types = const [GameEvent, _$GameEvent];
  @override
  final String wireName = 'GameEvent';

  @override
  Iterable<Object> serialize(Serializers serializers, GameEvent object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'timestamp',
      serializers.serialize(object.timestamp,
          specifiedType: const FullType(DateTime)),
      'type',
      serializers.serialize(object.type,
          specifiedType: const FullType(GameEventType)),
      'playerUid',
      serializers.serialize(object.playerUid,
          specifiedType: const FullType(String)),
    ];
    if (object.uid != null) {
      result
        ..add('uid')
        ..add(serializers.serialize(object.uid,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GameEvent deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GameEventBuilder();

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
        case 'timestamp':
          result.timestamp = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(GameEventType)) as GameEventType;
          break;
        case 'playerUid':
          result.playerUid = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GameEvent extends GameEvent {
  @override
  final String uid;
  @override
  final DateTime timestamp;
  @override
  final GameEventType type;
  @override
  final String playerUid;

  factory _$GameEvent([void Function(GameEventBuilder) updates]) =>
      (new GameEventBuilder()..update(updates)).build();

  _$GameEvent._({this.uid, this.timestamp, this.type, this.playerUid})
      : super._() {
    if (timestamp == null) {
      throw new BuiltValueNullFieldError('GameEvent', 'timestamp');
    }
    if (type == null) {
      throw new BuiltValueNullFieldError('GameEvent', 'type');
    }
    if (playerUid == null) {
      throw new BuiltValueNullFieldError('GameEvent', 'playerUid');
    }
  }

  @override
  GameEvent rebuild(void Function(GameEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameEventBuilder toBuilder() => new GameEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GameEvent &&
        uid == other.uid &&
        timestamp == other.timestamp &&
        type == other.type &&
        playerUid == other.playerUid;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, uid.hashCode), timestamp.hashCode), type.hashCode),
        playerUid.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('GameEvent')
          ..add('uid', uid)
          ..add('timestamp', timestamp)
          ..add('type', type)
          ..add('playerUid', playerUid))
        .toString();
  }
}

class GameEventBuilder implements Builder<GameEvent, GameEventBuilder> {
  _$GameEvent _$v;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  DateTime _timestamp;
  DateTime get timestamp => _$this._timestamp;
  set timestamp(DateTime timestamp) => _$this._timestamp = timestamp;

  GameEventType _type;
  GameEventType get type => _$this._type;
  set type(GameEventType type) => _$this._type = type;

  String _playerUid;
  String get playerUid => _$this._playerUid;
  set playerUid(String playerUid) => _$this._playerUid = playerUid;

  GameEventBuilder();

  GameEventBuilder get _$this {
    if (_$v != null) {
      _uid = _$v.uid;
      _timestamp = _$v.timestamp;
      _type = _$v.type;
      _playerUid = _$v.playerUid;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GameEvent other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$GameEvent;
  }

  @override
  void update(void Function(GameEventBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$GameEvent build() {
    final _$result = _$v ??
        new _$GameEvent._(
            uid: uid, timestamp: timestamp, type: type, playerUid: playerUid);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
