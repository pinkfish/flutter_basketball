import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

class BuildDatePostProcess extends PostProcessBuilder {
  static String _lineToAppend = "\n// Update file";

  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    var content = await buildStep.readInputAsString();
    if (content.contains("String to match on frog frog frog")) {
      var fname = buildStep.inputId.path.replaceAll(".g.dart", ".dart");
      File f = File(fname);
      var data = await f.readAsString();
      await f.setLastModified(DateTime.now());
      if (data.contains(_lineToAppend)) {
        data = data.replaceAll(_lineToAppend, "");
      } else {
        data += _lineToAppend;
      }
      await f.writeAsString(data);
    }
  }

  @override
  Iterable<String> get inputExtensions => const [".dart"];
}
