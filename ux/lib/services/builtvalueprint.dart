import 'package:built_value/built_value.dart';

///
/// Only print the class name for the builtvalue.
///
class JustClassNameBuiltValueToStringHelper
    implements BuiltValueToStringHelper {
  final String className;

  JustClassNameBuiltValueToStringHelper(this.className);

  @override
  void add(String field, Object value) {}

  @override
  String toString() {
    return className;
  }
}
