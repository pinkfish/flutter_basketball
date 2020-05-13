import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broadcaststatus.g.dart';

class BroadcastStatus extends EnumClass {
  static Serializer<BroadcastStatus> get serializer =>
      _$broadcastStatusSerializer;

  static const BroadcastStatus finished = _$finished;
  static const BroadcastStatus broadcasting = _$broadcasting;
  static const BroadcastStatus created = _$created;

  const BroadcastStatus._(String name) : super(name);

  static BuiltSet<BroadcastStatus> get values => _$values;

  static BroadcastStatus valueOf(String name) => _$valueOf(name);
}
