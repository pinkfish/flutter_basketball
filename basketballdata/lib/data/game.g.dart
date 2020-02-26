// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Game> _$gameSerializer = new _$GameSerializer();

class _$GameSerializer implements StructuredSerializer<Game> {
  @override
  final Iterable<Type> types = const [Game, _$Game];
  @override
  final String wireName = 'Game';

  @override
  Iterable<Object> serialize(Serializers serializers, Game object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'eventTime',
      serializers.serialize(object.eventTime,
          specifiedType: const FullType(DateTime)),
      'location',
      serializers.serialize(object.location,
          specifiedType: const FullType(String)),
      'events',
      serializers.serialize(object.events,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(GameEvent)])),
      'playerUids',
      serializers.serialize(object.playerUids,
          specifiedType: const FullType(
              BuiltMap, const [const FullType(String), const FullType(bool)])),
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
  Game deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GameBuilder();

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
        case 'eventTime':
          result.eventTime = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'location':
          result.location = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'events':
          result.events.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(GameEvent)])));
          break;
        case 'playerUids':
          result.playerUids.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(bool)])));
          break;
      }
    }

    return result.build();
  }
}

class _$Game extends Game {
  @override
  final String uid;
  @override
  final DateTime eventTime;
  @override
  final String location;
  @override
  final BuiltMap<String, GameEvent> events;
  @override
  final BuiltMap<String, bool> playerUids;

  factory _$Game([void Function(GameBuilder) updates]) =>
      (new GameBuilder()..update(updates)).build();

  _$Game._(
      {this.uid, this.eventTime, this.location, this.events, this.playerUids})
      : super._() {
    if (eventTime == null) {
      throw new BuiltValueNullFieldError('Game', 'eventTime');
    }
    if (location == null) {
      throw new BuiltValueNullFieldError('Game', 'location');
    }
    if (events == null) {
      throw new BuiltValueNullFieldError('Game', 'events');
    }
    if (playerUids == null) {
      throw new BuiltValueNullFieldError('Game', 'playerUids');
    }
  }

  @override
  Game rebuild(void Function(GameBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GameBuilder toBuilder() => new GameBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Game &&
        uid == other.uid &&
        eventTime == other.eventTime &&
        location == other.location &&
        events == other.events &&
        playerUids == other.playerUids;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc(0, uid.hashCode), eventTime.hashCode),
                location.hashCode),
            events.hashCode),
        playerUids.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Game')
          ..add('uid', uid)
          ..add('eventTime', eventTime)
          ..add('location', location)
          ..add('events', events)
          ..add('playerUids', playerUids))
        .toString();
  }
}

class GameBuilder implements Builder<Game, GameBuilder> {
  _$Game _$v;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  DateTime _eventTime;
  DateTime get eventTime => _$this._eventTime;
  set eventTime(DateTime eventTime) => _$this._eventTime = eventTime;

  String _location;
  String get location => _$this._location;
  set location(String location) => _$this._location = location;

  MapBuilder<String, GameEvent> _events;
  MapBuilder<String, GameEvent> get events =>
      _$this._events ??= new MapBuilder<String, GameEvent>();
  set events(MapBuilder<String, GameEvent> events) => _$this._events = events;

  MapBuilder<String, bool> _playerUids;
  MapBuilder<String, bool> get playerUids =>
      _$this._playerUids ??= new MapBuilder<String, bool>();
  set playerUids(MapBuilder<String, bool> playerUids) =>
      _$this._playerUids = playerUids;

  GameBuilder();

  GameBuilder get _$this {
    if (_$v != null) {
      _uid = _$v.uid;
      _eventTime = _$v.eventTime;
      _location = _$v.location;
      _events = _$v.events?.toBuilder();
      _playerUids = _$v.playerUids?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Game other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Game;
  }

  @override
  void update(void Function(GameBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Game build() {
    _$Game _$result;
    try {
      _$result = _$v ??
          new _$Game._(
              uid: uid,
              eventTime: eventTime,
              location: location,
              events: events.build(),
              playerUids: playerUids.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'events';
        events.build();
        _$failedField = 'playerUids';
        playerUids.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Game', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
