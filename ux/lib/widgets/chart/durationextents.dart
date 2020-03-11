import 'package:charts_common/common.dart';
import 'package:meta/meta.dart' show required;

class DurationExtents extends Extents<Duration> {
  final Duration start;
  final Duration end;

  DurationExtents({@required this.start, @required this.end});

  @override
  bool operator ==(other) {
    return other is DurationExtents && start == other.start && end == other.end;
  }

  @override
  int get hashCode => (start.hashCode + (end.hashCode * 37));
}
