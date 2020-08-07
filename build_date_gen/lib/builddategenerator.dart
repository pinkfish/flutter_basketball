import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:basketballdata/builddate.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

///
/// Generates a file that has a build date in it.
///
class BuildDateGenerator extends GeneratorForAnnotation<BuildDate> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    var now = DateTime.now();
    return '''// Make an exciting build date
// String to match on frog frog frog
final DateTime _\$${element.name}Int = DateTime.fromMillisecondsSinceEpoch(${now.millisecondsSinceEpoch});
''';
  }
}
