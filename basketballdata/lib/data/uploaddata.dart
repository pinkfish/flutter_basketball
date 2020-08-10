import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';

part 'uploaddata.g.dart';

///
/// Tracks the data associated with the upload so it an be written out to
/// sql db.
///
abstract class UploadData implements Built<UploadData, UploadDataBuilder> {
  String get localPath;
  String get gcsPath;
  String get videoUid;
  String get gameUid;
  String get uid;

  UploadData._();

  factory UploadData([updates(UploadDataBuilder b)]) = _$UploadData;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(UploadData.serializer, this);
  }

  static UploadData fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(UploadData.serializer, jsonData);
  }

  static Serializer<UploadData> get serializer => _$uploadDataSerializer;
}
