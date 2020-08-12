import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gameeventtype.g.dart';

///
/// The type of the game event.
///
class GameEventType extends EnumClass {
  static Serializer<GameEventType> get serializer => _$gameEventTypeSerializer;

  static const GameEventType Made = _$made;
  static const GameEventType Missed = _$missed;
  static const GameEventType Foul = _$foul;
  static const GameEventType Sub = _$sub;
  static const GameEventType OffsensiveRebound = _$offensiveRebound;
  static const GameEventType DefensiveRebound = _$defensiveRebound;
  static const GameEventType Block = _$block;
  static const GameEventType Steal = _$steal;
  static const GameEventType Turnover = _$turnover;
  static const GameEventType PeriodStart = _$periodStart;
  static const GameEventType PeriodEnd = _$periodEnd;
  static const GameEventType TimeoutStart = _$timeoutStart;
  static const GameEventType TimeoutEnd = _$timeoutEnd;
  static const GameEventType EmptyEvent = _$emptyEvent;

  const GameEventType._(String name) : super(name);

  static BuiltSet<GameEventType> get values => _$values;

  static GameEventType valueOf(String name) => _$valueOf(name);
}
