import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'mediatype.dart';
import '../serializers.dart';
import '../timestampserializer.dart';

part 'mediainfo.g.dart';

enum MediaInfoResult { Win, Tie, Loss }

///
/// Data about the videoInfo itself.
///
abstract class MediaInfo implements Built<MediaInfo, MediaInfoBuilder> {
  @nullable
  String get uid;

  String get seasonUid;
  String get teamUid;
  String get gameUid;

  /// When the media was uploaded.
  @nullable
  Timestamp get uploadTime;

  /// The duration of the media (0 for images)
  Duration get length;

  /// Tracks when this videoInfo is starting at in respect to the game
  /// itself.
  DateTime get startAt;

  String get description;

  @nullable
  Uri get thumbnailUrl;

  @nullable
  Uri get rtmpUrl;

  MediaType get type;

  Uri get url;

  MediaInfo._();
  factory MediaInfo([updates(MediaInfoBuilder b)]) = _$MediaInfo;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(MediaInfo.serializer, this);
  }

  static MediaInfo fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(MediaInfo.serializer, jsonData);
  }

  static Serializer<MediaInfo> get serializer => _$mediaInfoSerializer;
}
