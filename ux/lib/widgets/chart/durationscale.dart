import 'package:charts_common/common.dart';

import 'durationextents.dart';

/// [DurationScale] is a wrapper for [LinearScale].
/// [Duration] values are converted to millisecondsSinceEpoch and passed to the
/// [LinearScale].
class DurationScale extends MutableScale<Duration> {
  final LinearScale _linearScale;

  DurationScale() : _linearScale = LinearScale();

  DurationScale._copy(DurationScale other)
      : _linearScale = other._linearScale.copy();

  @override
  num operator [](Duration domainValue) =>
      _linearScale[domainValue.inMilliseconds];

  @override
  Duration reverse(double pixelLocation) =>
      Duration(milliseconds: _linearScale.reverse(pixelLocation).round());

  @override
  void resetDomain() {
    _linearScale.resetDomain();
  }

  @override
  set stepSizeConfig(StepSizeConfig config) {
    _linearScale.stepSizeConfig = config;
  }

  @override
  StepSizeConfig get stepSizeConfig => _linearScale.stepSizeConfig;

  @override
  set rangeBandConfig(RangeBandConfig barGroupWidthConfig) {
    _linearScale.rangeBandConfig = barGroupWidthConfig;
  }

  @override
  void setViewportSettings(double viewportScale, double viewportTranslatePx) {
    _linearScale.setViewportSettings(viewportScale, viewportTranslatePx);
  }

  @override
  set range(ScaleOutputExtent extent) {
    _linearScale.range = extent;
  }

  @override
  void addDomain(Duration domainValue) {
    _linearScale.addDomain(domainValue.inMilliseconds);
  }

  @override
  void resetViewportSettings() {
    _linearScale.resetViewportSettings();
  }

  DurationExtents get viewportDomain {
    final extents = _linearScale.viewportDomain;
    return DurationExtents(
        start: Duration(milliseconds: extents.min.toInt()),
        end: Duration(milliseconds: extents.max.toInt()));
  }

  set viewportDomain(DurationExtents extents) {
    _linearScale.viewportDomain = NumericExtents(
        extents.start.inMilliseconds, extents.end.inMilliseconds);
  }

  @override
  DurationScale copy() => DurationScale._copy(this);

  @override
  double get viewportTranslatePx => _linearScale.viewportTranslatePx;

  @override
  double get viewportScalingFactor => _linearScale.viewportScalingFactor;

  @override
  bool isRangeValueWithinViewport(double rangeValue) =>
      _linearScale.isRangeValueWithinViewport(rangeValue);

  @override
  int compareDomainValueToViewport(Duration domainValue) =>
      _linearScale.compareDomainValueToViewport(domainValue.inMilliseconds);

  @override
  double get rangeBand => _linearScale.rangeBand;

  @override
  double get stepSize => _linearScale.stepSize;

  @override
  double get domainStepSize => _linearScale.domainStepSize;

  @override
  RangeBandConfig get rangeBandConfig => _linearScale.rangeBandConfig;

  @override
  int get rangeWidth => _linearScale.rangeWidth;

  @override
  ScaleOutputExtent get range => _linearScale.range;

  @override
  bool canTranslate(Duration domainValue) =>
      _linearScale.canTranslate(domainValue.inMilliseconds);

  NumericExtents get dataExtent => _linearScale.dataExtent;
}
