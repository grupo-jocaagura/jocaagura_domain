part of '../../jocaagura_domain.dart';

/// Represents coarse-grained device categories for responsive design.
///
/// `ScreenSizeEnum` helps map a raw viewport width to a device class.
/// This is typically driven by `ScreenSizeConfig` thresholds and is used
/// to adapt grid metrics and UI behavior.
///
/// ## Values
/// - `mobile`: Phones and small handsets.
/// - `tablet`: Tablets and large handsets in landscape.
/// - `desktop`: Laptops and desktops.
/// - `tv`: Very large screens and TVs.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaagura_domain/jocaagura_domain.dart';
///
/// void main() {
///   final ScreenSizeEnum size = ScreenSizeEnum.desktop;
///   switch (size) {
///     case ScreenSizeEnum.mobile:
///       // Apply compact layout
///       break;
///     case ScreenSizeEnum.tablet:
///       // Apply medium layout
///       break;
///     case ScreenSizeEnum.desktop:
///       // Apply expanded layout
///       break;
///     case ScreenSizeEnum.tv:
///       // Apply extra-large layout
///       break;
///   }
/// }
/// ```
enum ScreenSizeEnum {
  /// Represents mobile devices (e.g., phones).
  mobile,

  /// Represents tablet devices.
  tablet,

  /// Represents desktop or laptop devices.
  desktop,

  /// Represents TV or large screen devices.
  tv,
}

/// A BLoC for responsive layout metrics and policies.
///
/// `BlocResponsive` exposes:
/// - A reactive **screen size stream** (`appScreenSizeStream`)
/// - A reactive **app bar visibility stream** (`showAppbarStream`)
/// - **Derived grid metrics** (columns, margins, gutters, column width)
/// - **Device type** mapping (`deviceType`, `isMobile/tablet/desktop/tv`)
///
/// It is **config-driven** via [ScreenSizeConfig] to avoid hardcoded
/// breakpoints and layout constants. UI layers can update the viewport
/// using [setSizeFromContext] (Flutter adapter) or [setSize] (pure input).
///
/// ### Clean Architecture
/// This bloc may be considered *presentation infrastructure*. It does not
/// depend on any widget tree state beyond the `MediaQuery` adapter used
/// by [setSizeFromContext]. For unit tests or headless usage, prefer
/// [setSize] / [setSizeForTesting].
///
/// ## Example
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:jocaagura_domain/jocaagura_domain.dart';
///
/// class MyLayout extends StatefulWidget {
///   const MyLayout({super.key});
///   @override
///   State<MyLayout> createState() => _MyLayoutState();
/// }
///
/// class _MyLayoutState extends State<MyLayout> {
///   final BlocResponsive responsive = BlocResponsive();
///
///   @override
///   void didChangeDependencies() {
///     super.didChangeDependencies();
///     // Update size reactively when the widget tree is ready
///     responsive.setSizeFromContext(context);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return LayoutBuilder(
///       builder: (_, __) {
///         // Keep metrics in sync during rebuilds
///         responsive.setSizeFromContext(context);
///
///         final cols = responsive.columnsNumber;
///         final w4 = responsive.widthByColumns(4);
///
///         return Padding(
///           padding: EdgeInsets.symmetric(horizontal: responsive.marginWidth),
///           child: SizedBox(
///             width: w4.clamp(0, responsive.workAreaSize.width),
///             child: Text('Device: ${responsive.deviceType}, cols: $cols'),
///           ),
///         );
///       },
///     );
///   }
///
///   @override
///   void dispose() {
///     responsive.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
/// ## Testing (no Flutter context)
///
/// ```dart
/// final bloc = BlocResponsive();
/// bloc.setSizeForTesting(const Size(1280, 800));
/// assert(bloc.isDesktop);
/// assert(bloc.columnsNumber == bloc.sizeConfig.desktopColumnsNumber);
/// ```
class BlocResponsive extends BlocModule {
  BlocResponsive({
    this.sizeConfig = screenSizeConfig,
  }) {
    _blocSizeGeneral.addFunctionToProcessTValueOnStream(
      'updateDrawerWidth',
      (Size val) => _setDrawerWidth(),
    );
    _blocSizeGeneral.addFunctionToProcessTValueOnStream(
      'updateColumnsWidth',
      (Size val) => _setColumnWidth(),
    );
  }

  final ScreenSizeConfig sizeConfig;

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'responsiveBloc';

  /// Stream controller for app screen size.
  final BlocGeneral<Size> _blocSizeGeneral = BlocGeneral<Size>(Size.zero);

  final BlocGeneral<bool> _blocShowAppbar = BlocGeneral<bool>(true);

  /// A stream of app screen sizes.
  ///
  /// Emits the current viewport size. Update via [setSize] or [setSizeFromContext].
  Stream<Size> get appScreenSizeStream => _blocSizeGeneral.stream;

  /// Emits the app bar visibility policy (presentation concern).
  Stream<bool> get showAppbarStream => _blocShowAppbar.stream;

  /// Returns the last known viewport size.
  Size get value => _blocSizeGeneral.value;
  double _drawerWidth = 0.0;

  void _setDrawerWidth() {
    _drawerWidth = size.width - workAreaSize.width;
  }

  /// Computed: width reserved by outer drawers compared to [workAreaSize].
  /// Presentation-specific policy; adjust via [ScreenSizeConfig] if needed.
  double get drawerWidth {
    if (_drawerWidth == 0.0) {
      _setDrawerWidth();
    }
    return _drawerWidth;
  }

  /// Computed: an auxiliary drawer width based on a single column.
  double get secondaryDrawerWidth => columnWidth;

  /// App bar policy height from [sizeConfig].
  double get appBarHeight => sizeConfig.appBarHeight;

  /// Returns height excluding the app bar if [showAppbar] is true.
  double get screenHeightWithoutAppbar =>
      showAppbar ? size.height - appBarHeight : size.height;

  /// Whether the app bar should be visible (presentation concern).
  bool get showAppbar => _blocShowAppbar.value;

  /// Updates the app bar visibility (presentation concern).
  ///
  /// ### Example
  /// ```dart
  /// blocResponsive.showAppbar = false;
  /// ```
  set showAppbar(bool val) {
    _blocShowAppbar.value = val;
  }

  bool get showAppBarStreamIsClosed => _blocShowAppbar.isClosed;
  bool get appScreenSizeStreamIsClosed => _blocSizeGeneral.isClosed;

  /// Update the screen size based on Flutter's [MediaQuery].
  ///
  /// Prefer [setSize] in tests or headless scenarios.
  void setSizeFromContext(BuildContext context) {
    setSize(MediaQuery.of(context).size);
  }

  /// Update the screen size directly (framework-agnostic).
  ///
  /// ### Example
  /// ```dart
  /// blocResponsive.setSize(const Size(1024, 768));
  /// ```
  void setSize(Size sizeTmp) {
    if (sizeTmp.width != value.width || sizeTmp.height != value.height) {
      _blocSizeGeneral.value = sizeTmp;
    }
    workAreaSize = sizeTmp;
    _setDrawerWidth();
    _setColumnWidth();
  }

  /// Headless/testing helper that proxies to [setSize].
  void setSizeForTesting(Size sizeTmp) => setSize(sizeTmp);

  Size get size => value;

  Size _workAreaSize = Size.zero;

  set workAreaSize(Size sizeOfWorkArea) {
    if (isDesktop) {
      _workAreaSize = Size(
        sizeOfWorkArea.width * sizeConfig.percentilOfWorkAreaSize,
        sizeOfWorkArea.height,
      );
      _setColumnWidth();
      return;
    }
    if (isTv) {
      _workAreaSize = Size(
        sizeOfWorkArea.width * sizeConfig.percentilOfBigWorkAreaSize,
        sizeOfWorkArea.height,
      );
      _setColumnWidth();
      return;
    }
    _workAreaSize = sizeOfWorkArea;
    _setColumnWidth();
  }

  /// Work area varies by device type. For desktop/tv a percentage is applied,
  /// otherwise the full size is used. Percentages come from [sizeConfig].
  Size get workAreaSize => isMobile ? size : _workAreaSize;

  /// Columns count derived from [deviceType] and [sizeConfig].
  int get columnsNumber {
    if (isTablet) {
      return sizeConfig.tabletColumnsNumber;
    }
    if (isDesktop || isTv) {
      return sizeConfig.desktopColumnsNumber;
    }
    return sizeConfig.mobileColumnsNumber;
  }

  /// Outer margin (left/right) in logical pixels, from [sizeConfig].
  double get marginWidth {
    if (isTablet) {
      return sizeConfig.maxTabletMarginWidth;
    }
    if (isDesktop || isTv) {
      return sizeConfig.maxDesktopMarginWidth;
    }
    return sizeConfig.maxMobileMarginWidth;
  }

  /// Gutter width per column. Rounded down for pixel alignment.
  double get gutterWidth {
    double tmp = marginWidth * 2;
    tmp = tmp / columnsNumber;
    return tmp.floorToDouble();
  }

  /// Number of gutters between `n` columns (clamped).
  int numberOfGutters(int numberOfColumns) {
    return (numberOfColumns - 1).clamp(0, columnsNumber - 1);
  }

  double _columnWidth = 0.0;

  void _setColumnWidth() {
    double tmp = workAreaSize.width;
    tmp = tmp - (marginWidth * 2);
    tmp = tmp - (numberOfGutters(columnsNumber) * gutterWidth);
    tmp = tmp / columnsNumber;
    _columnWidth = tmp.clamp(0.0, double.maxFinite).floorToDouble();
  }

  /// Single column width after subtracting margins and gutters.
  double get columnWidth {
    if (_columnWidth == 0.0) {
      _setColumnWidth();
    }
    return _columnWidth;
  }

  /// Device type derived from [size.width] and [sizeConfig] thresholds.
  ScreenSizeEnum get deviceType {
    final double width = size.width;
    if (width >= sizeConfig.maxDesktopScreenWidth) {
      return ScreenSizeEnum.tv;
    }
    if (width > sizeConfig.maxTabletScreenWidth) {
      return ScreenSizeEnum.desktop;
    }
    if (width > sizeConfig.maxMobileScreenWidth) {
      return ScreenSizeEnum.tablet;
    }
    return ScreenSizeEnum.mobile;
  }

  /// Convenience flags.
  /// Gets whether the current device is a mobile.
  bool get isMobile => deviceType == ScreenSizeEnum.mobile;

  /// Gets whether the current device is a tablet.
  bool get isTablet => deviceType == ScreenSizeEnum.tablet;

  /// Gets whether the current device is a desktop.
  bool get isDesktop => deviceType == ScreenSizeEnum.desktop;

  /// Gets whether the current device is a TV.
  bool get isTv => deviceType == ScreenSizeEnum.tv;

  /// Returns the total width spanned by `numberOfColumns` including gutters.
  ///
  /// Values are clamped to `[1, columnsNumber]`.
  ///
  /// ### Example
  /// ```dart
  /// final w = blocResponsive.widthByColumns(4);
  /// ```
  double widthByColumns(int numberOfColumns) {
    final int columns = numberOfColumns.abs().clamp(1, columnsNumber);
    double tmp = columnWidth * columns;
    if (columns > 1) {
      tmp = tmp + (gutterWidth * (columns - 1));
    }
    return tmp;
  }

  @override
  FutureOr<void> dispose() {
    _blocSizeGeneral.dispose();
    _blocShowAppbar.dispose();
  }
}
