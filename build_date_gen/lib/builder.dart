import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'builddategenerator.dart';
import 'builddatepostprocess.dart';

Builder buildDateReporter(BuilderOptions options) =>
    SharedPartBuilder([BuildDateGenerator()], 'build_date');

PostProcessBuilder buildDatePostProcess(BuilderOptions options) =>
    BuildDatePostProcess();
