import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializers.dart';

part 'user.g.dart';

abstract class User implements Built<User, UserBuilder> {
  @nullable
  String get uid;

  @nullable
  String get photoUid;

  String get name;

  String get email;

  User._();

  factory User([updates(UserBuilder b)]) = _$User;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(User.serializer, this);
  }

  static User fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(User.serializer, jsonData);
  }

  static Serializer<User> get serializer => _$userSerializer;
}
