import 'package:charts_common/common.dart';
import 'package:meta/meta.dart';

import 'durationextents.dart';
import 'durationrangetickprovider.dart';
import 'durationscale.dart';
import 'durationstepper.dart';

class DurationRangeTickProviderImpl extends DurationRangeTickProvider {
  final int requiredMinimumTicks;
  final DurationStepper timeStepper;

  DurationRangeTickProviderImpl(this.timeStepper,
      {this.requiredMinimumTicks = 3});

  @override
  bool providesSufficientTicksForRange(DurationExtents domainExtents) {
    final cnt = timeStepper.getStepCountBetween(domainExtents, 1);
    return cnt >= requiredMinimumTicks;
  }

  /// Find the closet step size, from provided step size, in milliseconds.
  @override
  int getClosestStepSize(int stepSize) {
    return timeStepper.typicalStepSizeMs *
        _getClosestIncrementFromStepSize(stepSize);
  }

  // Find the increment that is closest to the step size.
  int _getClosestIncrementFromStepSize(int stepSize) {
    int minDifference;
    int closestIncrement;

    for (int increment in timeStepper.allowedTickIncrements) {
      final difference =
          (stepSize - (timeStepper.typicalStepSizeMs * increment)).abs();
      if (minDifference == null || minDifference > difference) {
        minDifference = difference;
        closestIncrement = increment;
      }
    }

    return closestIncrement;
  }

  @override
  List<Tick<Duration>> getTicks({
    @required ChartContext context,
    @required GraphicsFactory graphicsFactory,
    @required DurationScale scale,
    @required TickFormatter<Duration> formatter,
    @required Map<Duration, String> formatterValueCache,
    @required TickDrawStrategy tickDrawStrategy,
    @required AxisOrientation orientation,
    bool viewportExtensionEnabled = false,
    TickHint<Duration> tickHint,
  }) {
    List<Tick<Duration>> currentTicks;
    final tickValues = <Duration>[];
    final timeStepIt = timeStepper.getSteps(scale.viewportDomain).iterator;

    // Try different tickIncrements and choose the first that has no collisions.
    // If none exist use the last one which should have the fewest ticks and
    // hope that the renderer will resolve collisions.
    //
    // If a tick hint was provided, use the tick hint to search for the closest
    // increment and use that.
    List<int> allowedTickIncrements;
    if (tickHint != null) {
      final stepSize =
          tickHint.end.inMilliseconds - tickHint.start.inMilliseconds;
      allowedTickIncrements = [_getClosestIncrementFromStepSize(stepSize)];
    } else {
      allowedTickIncrements = timeStepper.allowedTickIncrements;
    }

    for (int i = 0; i < allowedTickIncrements.length; i++) {
      // Create tick values with a specified increment.
      final tickIncrement = allowedTickIncrements[i];
      tickValues.clear();
      timeStepIt.reset(tickIncrement);
      while (timeStepIt.moveNext()) {
        tickValues.add(timeStepIt.current);
      }

      // Create ticks
      currentTicks = createTicks(tickValues,
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: formatterValueCache,
          tickDrawStrategy: tickDrawStrategy,
          stepSize: timeStepper.typicalStepSizeMs * tickIncrement);

      // Request collision check from draw strategy.
      final collisionReport =
          tickDrawStrategy.collides(currentTicks, orientation);

      if (!collisionReport.ticksCollide) {
        // Return the first non colliding ticks.
        return currentTicks;
      }
    }

    // If all ticks collide, return the last generated ticks.
    return currentTicks;
  }
}
