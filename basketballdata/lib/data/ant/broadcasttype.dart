import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broadcasttype.g.dart';

///
/// Data about the broadcastType itself.
///
class BroadcastType extends EnumClass {
  static Serializer<BroadcastType> get serializer => _$broadcastTypeSerializer;

  static const BroadcastType liveStream = _$liveStream;
  static const BroadcastType ipCamera = _$ipCamera;
  static const BroadcastType streamSource = _$streamSource;
  static const BroadcastType VoD = _$voD;

  const BroadcastType._(String name) : super(name);

  static BuiltSet<BroadcastType> get values => _$values;

  static BroadcastType valueOf(String name) => _$valueOf(name);
}
