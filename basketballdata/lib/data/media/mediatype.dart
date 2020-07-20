import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mediatype.g.dart';

///
/// The GamePeriod to deal with in the game.
///
class MediaType extends EnumClass {
  static Serializer<MediaType> get serializer => _$mediaTypeSerializer;

  static const MediaType VideoStreaming = _$videoStreaming;
  static const MediaType VideoOnDemand = _$videoOnDemand;
  static const MediaType Image = _$image;

  const MediaType._(String name) : super(name);

  static BuiltSet<MediaType> get values => _$values;

  static MediaType valueOf(String name) => _$valueOf(name);
}
