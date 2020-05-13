import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';
import 'broadcaststatus.dart';
import 'broadcasttype.dart';

part 'broadcast.g.dart';

///
/// Data about the broadcast itself.
///
abstract class Broadcast implements Built<Broadcast, BroadcastBuilder> {
  String get streamId;

  @nullable
  BroadcastStatus get status;
  @nullable
  BroadcastType get type;
  String get name;
  @nullable
  String get description;
  @nullable
  bool get publish;
  @nullable
  DateTime get date;
  @nullable
  bool get publicStream;
  @nullable
  bool get is360;
  @nullable
  String get streamUrl;
  @nullable
  String get rtmpURL;
  @nullable
  bool get zombi;
  @nullable
  int get pendingPacketSize;
  @nullable
  int get hlsViewerCount;
  @nullable
  int get webRTCViewerCount;
  @nullable
  int get rtmpViewerCount;
  @nullable
  double get speed;
  @nullable
  int get bitrate;
  @nullable
  String get latitude;
  @nullable
  String get longitude;

  Broadcast._();
  factory Broadcast([updates(BroadcastBuilder b)]) = _$Broadcast;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Broadcast.serializer, this);
  }

  static Broadcast fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Broadcast.serializer, jsonData);
  }

  static Serializer<Broadcast> get serializer => _$broadcastSerializer;
}
