import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gamefoultype.g.dart';

///
/// Type of foul.
///
class GameFoulType extends EnumClass {
  static Serializer<GameFoulType> get serializer => _$gameFoulTypeSerializer;

  static const GameFoulType Personal = _$personal;
  static const GameFoulType Flagrant = _$flagrant;
  static const GameFoulType Technical = _$technical;

  const GameFoulType._(String name) : super(name);

  static BuiltSet<GameFoulType> get values => _$values;

  static GameFoulType valueOf(String name) => _$valueOf(name);
}
