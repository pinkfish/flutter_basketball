// Copyright (c) 2017, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

class Timestamp extends DateTime {
  Timestamp.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch)
      : super.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch, isUtc: true);
}

/// Serializer for [DateTime].
///
/// An exception will be thrown on attempt to serialize local DateTime
/// instances; you must use UTC.
class TimestampSerializer implements PrimitiveSerializer<Timestamp> {
  final bool structured = false;
  @override
  final Iterable<Type> types = BuiltList<Type>([Timestamp]);
  @override
  final String wireName = 'Timestamp';

  @override
  Object serialize(Serializers serializers, Timestamp dateTime,
      {FullType specifiedType = FullType.unspecified}) {
    if (!dateTime.isUtc) {
      throw ArgumentError.value(
          dateTime, 'dateTime', 'Must be in utc for serialization.');
    }

    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    int nanoseconds = (dateTime.microsecondsSinceEpoch % 1000000) * 1000;
    return "Timestamp(seconds=$seconds, nanonseconds=$nanoseconds)";
  }

  @override
  Timestamp deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    String bit = serialized.toString();
    bit = bit.replaceAll("Timestamp(", "");
    bit = bit.replaceAll(")", "");
    var parts = bit.split(",");
    int totalTs = 0;
    for (var p in parts) {
      p = p.trim();
      print("$p");
      var num = int.parse(p.split("=")[1]);
      if (p.startsWith("seconds")) {
        totalTs += num * 1000000;
      }
      if (p.startsWith("nanoseconds")) {
        totalTs += num ~/ 1000;
      }
    }

    DateTime ret = Timestamp.fromMicrosecondsSinceEpoch(totalTs);
    return ret;
  }
}
