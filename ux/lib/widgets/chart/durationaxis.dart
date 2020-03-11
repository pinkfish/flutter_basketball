import 'package:charts_common/common.dart';

import 'autoadjustingdurationtickprovider.dart';
import 'durationextents.dart';
import 'durationscale.dart';
import 'durationtickformatter.dart';

class DurationAxis extends Axis<Duration> {
  DurationAxis({TickProvider tickProvider, TickFormatter tickFormatter})
      : super(
          tickProvider:
              tickProvider ?? AutoAdjustingDurationTickProvider.createDefault(),
          tickFormatter: tickFormatter ?? DurationTickFormatter(),
          scale: DurationScale(),
        );

  void setScaleViewport(DurationExtents viewport) {
    autoViewport = false;
    (mutableScale as DurationScale).viewportDomain = viewport;
  }
}
