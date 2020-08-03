import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendance.g.dart';

class Attendance extends EnumClass {
  static Serializer<Attendance> get serializer => _$attendanceSerializer;

  static const Attendance Yes = _$yes;
  static const Attendance No = _$no;
  static const Attendance Maybe = _$maybe;

  const Attendance._(String name) : super(name);

  static BuiltSet<Attendance> get values => _$values;

  static Attendance valueOf(String name) => _$valueOf(name);
}
