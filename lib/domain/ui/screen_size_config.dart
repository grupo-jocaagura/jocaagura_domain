part of '../../jocaagura_domain.dart';

/// Immutable configuration for responsive thresholds and grid metrics.
///
/// All values are consumed by [BlocResponsive] to compute:
/// - Device class mapping (mobile/tablet/desktop/tv)
/// - Margins, gutters and column counts
/// - Work area percentiles for large screens
///
/// Adjust per app/brand to achieve consistent layout behavior.
///
/// ## Example
/// ```dart
/// const myConfig = ScreenSizeConfig(
///   maxDesktopScreenWidth: 1920.0,
///   maxTabletScreenWidth: 1100.0,
///   maxMobileScreenWidth: 520.0,
///   maxDesktopMarginWidth: 64.0,
///   maxTabletMarginWidth: 32.0,
///   maxMobileMarginWidth: 16.0,
///   desktopColumnsNumber: 12,
///   tabletColumnsNumber: 8,
///   mobileColumnsNumber: 4,
///   percentilOfWorkAreaSize: 0.86,
///   percentilOfBigWorkAreaSize: 0.80,
///   appBarHeight: 60.0,
/// );
///
/// final responsive = BlocResponsive(sizeConfig: myConfig);
/// ```
class ScreenSizeConfig {
  const ScreenSizeConfig({
    required this.maxTabletScreenWidth,
    required this.maxDesktopScreenWidth,
    required this.maxMobileScreenWidth,
    required this.maxDesktopMarginWidth,
    required this.maxTabletMarginWidth,
    required this.maxMobileMarginWidth,
    required this.desktopColumnsNumber,
    required this.tabletColumnsNumber,
    required this.mobileColumnsNumber,
    required this.percentilOfWorkAreaSize,
    required this.percentilOfBigWorkAreaSize,
    required this.appBarHeight,
  });
  final double maxTabletScreenWidth;

  final double maxDesktopScreenWidth;
  final double maxMobileScreenWidth;

  final double maxDesktopMarginWidth;
  final double maxTabletMarginWidth;
  final double maxMobileMarginWidth;

  final int desktopColumnsNumber;
  final int tabletColumnsNumber;
  final int mobileColumnsNumber;

  final double percentilOfWorkAreaSize;
  final double percentilOfBigWorkAreaSize;
  final double appBarHeight;
}

const ScreenSizeConfig screenSizeConfig = ScreenSizeConfig(
  maxDesktopScreenWidth: 1920.0,
  maxTabletScreenWidth: 1100.0,
  maxMobileScreenWidth: 520.0,
  maxDesktopMarginWidth: 64.0,
  maxTabletMarginWidth: 32.0,
  maxMobileMarginWidth: 16.0,
  desktopColumnsNumber: 12,
  tabletColumnsNumber: 8,
  mobileColumnsNumber: 4,
  percentilOfWorkAreaSize: 0.86,
  percentilOfBigWorkAreaSize: 0.8,
  appBarHeight: 60.0,
);
