import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gameperiod.g.dart';

///
/// The GamePeriod to deal with in the game.
///
class GamePeriod extends EnumClass {
  static Serializer<GamePeriod> get serializer => _$gamePeriodSerializer;

  static const GamePeriod NotStarted = _$notStarted;
  static const GamePeriod Period1 = _$period1;
  static const GamePeriod Period2 = _$period2;
  static const GamePeriod Period3 = _$period3;
  static const GamePeriod Period4 = _$period4;
  static const GamePeriod OverTime = _$overTime;
  static const GamePeriod Finished = _$finished;

  const GamePeriod._(String name) : super(name);

  static BuiltSet<GamePeriod> get values => _$values;

  static GamePeriod valueOf(String name) => _$valueOf(name);
}
