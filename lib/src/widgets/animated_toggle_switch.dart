part of 'package:animated_toggle_switch/animated_toggle_switch.dart';

typedef SizeIconBuilder<T> = Widget Function(BuildContext context,
    SizeProperties<T> local, DetailedGlobalToggleProperties<T> global);

typedef SimpleSizeIconBuilder<T> = Widget Function(T value, Size size);

typedef SimpleIconBuilder<T> = Widget Function(T value);

typedef RollingIconBuilder<T> = Widget Function(BuildContext context,
    RollingProperties<T> local, DetailedGlobalToggleProperties<T> global);

typedef SimpleRollingIconBuilder<T> = Widget Function(
    T value, Size size, bool foreground);

typedef LoadingIconBuilder<T> = Widget Function(
    BuildContext context, DetailedGlobalToggleProperties<T> global);

/// A version of IconBuilder for writing a own Animation on the change of the selected item.
typedef AnimatedIconBuilder<T> = Widget Function(
    BuildContext context,
    AnimatedToggleProperties<T> local,
    DetailedGlobalToggleProperties<T> global);

typedef IconBuilder<T> = Widget Function(BuildContext context,
    LocalToggleProperties<T> local, DetailedGlobalToggleProperties<T> global);

typedef ColorBuilder<T> = Color? Function(T value);

/// Specifies when an icon should be highlighted.
enum AnimationType {
  /// Starts an animation if an item is selected.
  onSelected,

  /// Start an animation if an item is hovered by the indicator.
  onHover,
}

/// Different types of transitions for the foreground indicator.
///
/// Currently this enum is used only for deactivating the rolling animation in
/// some constructors.
enum ForegroundIndicatorTransitionType {
  /// Fades between the different icons.
  fading,

  /// Fades between the different icons and shows a rolling animation
  /// additionally.
  rolling,
}

/// A class with different constructors of different switches.
/// The constructors have sensible default values for their parameters,
/// but can also be customized.
///
/// If you want to implement a completely custom switch,
/// you should use [CustomAnimatedToggleSwitch], which is used by
/// [AnimatedToggleSwitch] in the background.
class AnimatedToggleSwitch<T> extends StatelessWidget {
  /// The currently selected value. It has to be set at [onChanged] or whenever for animating to this value.
  ///
  /// [current] has to be in [values] for working correctly if [allowUnlistedValues] is false.
  final T current;

  /// All possible values.
  final List<T> values;

  /// The IconBuilder for all icons with the specified size.
  final AnimatedIconBuilder<T>? animatedIconBuilder;

  /// Builder for the color of the indicator depending on the current value.
  final ColorBuilder<T>? colorBuilder;

  /// Duration of the motion animation.
  final Duration animationDuration;

  /// If null, [animationDuration] is taken.
  ///
  /// [iconAnimationDuration] defines the duration of the Animation built in [animatedIconBuilder].
  /// In some constructors this is the Duration of the size animation.
  final Duration? iconAnimationDuration;

  /// Curve of the motion animation.
  final Curve animationCurve;

  /// [iconAnimationCurve] defines the duration of the Animation built in [animatedIconBuilder].
  /// In some constructors this is the [Curve] of the size animation.
  final Curve iconAnimationCurve;

  /// Size of the indicator.
  final Size indicatorSize;

  /// Callback for selecting a new value. The new [current] should be set here.
  final Function(T)? onChanged;

  /// Width of the border of the switch. For deactivating please set this to 0.0 and set [borderColor] to Colors.transparent.
  final double borderWidth;

  /// [BorderRadius] of the border. If this is null, the standard BorderRadius is taken.
  final BorderRadiusGeometry? borderRadius;

  /// [BorderRadius] of the indicator. Defaults to [borderRadius].
  final BorderRadiusGeometry? indicatorBorderRadius;

  /// Standard color of the border of the switch. For deactivating please set this to Colors.transparent and set [borderWidth] to 0.0.
  final Color? borderColor;

  /// Color of the background.
  final Color? innerColor;

  /// Gradient of the background. Overwrites [innerColor] if not null.
  final Gradient? innerGradient;

  /// Opacity for the icons.
  ///
  /// Please set [iconOpacity] and [selectedIconOpacity] to 1.0 for deactivating the AnimatedOpacity.
  final double iconOpacity;

  /// Opacity for the currently selected icon.
  ///
  /// Please set [iconOpacity] and [selectedIconOpacity] to 1.0 for deactivating the AnimatedOpacity.
  final double selectedIconOpacity;

  /// Space between the "indicator rooms" of the adjacent icons.
  final double dif;

  /// Total height of the widget.
  final double height;

  /// If null, the indicator is behind the icons. Otherwise an icon is in the indicator and is built using this function.
  final CustomIndicatorBuilder<T>? foregroundIndicatorIconBuilder;

  /// Standard Indicator Color
  final Color? indicatorColor;

  /// A builder for the Color of the Border. Can be used alternatively to [borderColor].
  final ColorBuilder<T>? borderColorBuilder;

  /// Which iconAnimationType for the [animatedIconBuilder] should be taken?
  final AnimationType iconAnimationType;

  /// Which iconAnimationType for the indicator should be taken?
  final AnimationType indicatorAnimationType;

  /// Callback for tapping anywhere on the widget.
  final Function()? onTap;

  final IconArrangement _iconArrangement;

  /// [MouseCursor] to show when not hovering an indicator.
  ///
  /// Defaults to [SystemMouseCursors.click] if [iconsTappable] is [true]
  /// and to [MouseCursor.defer] otherwise.
  final MouseCursor? defaultCursor;

  /// [MouseCursor] to show when grabbing the indicators.
  final MouseCursor draggingCursor;

  /// [MouseCursor] to show when hovering the indicators.
  final MouseCursor dragCursor;

  /// [MouseCursor] to show during loading.
  final MouseCursor loadingCursor;

  /// The [FittingMode] of the switch.
  ///
  /// Change this only if you don't want the switch to adjust when the constraints are too small.
  final FittingMode fittingMode;

  final BoxBorder? indicatorBorder;

  /// Shadow for the indicator [Container].
  final List<BoxShadow> foregroundBoxShadow;

  /// Shadow for the [Container] in the background.
  final List<BoxShadow> boxShadow;

  /// Indicates if [onChanged] is called when an icon is tapped.
  /// If [false] the user can change the value only by dragging the indicator.
  final bool iconsTappable;

  /// The minimum width of the indicator's hitbox.
  ///
  /// Helpful if the indicator is so small that you can hardly grip it.
  final double minTouchTargetSize;

  /// The direction in which the icons are arranged.
  ///
  /// If null, the [TextDirection] is taken from the [BuildContext].
  final TextDirection? textDirection;

  /// A builder for the loading icon.
  final LoadingIconBuilder<T> loadingIconBuilder;

  /// Indicates if the switch is currently loading.
  ///
  /// If set to [null], the switch is loading automatically when a [Future] is
  /// returned by [onChanged] or [onTap].
  final bool? loading;

  /// Duration of the loading animation.
  ///
  /// Defaults to [animationDuration].
  final Duration? loadingAnimationDuration;

  /// Curve of the loading animation.
  ///
  /// Defaults to [animationCurve].
  final Curve? loadingAnimationCurve;

  /// Indicates if an error should be thrown if [current] is not in [values].
  ///
  /// If [allowUnlistedValues] is [true] and [values] does not contain [current],
  /// the indicator disappears with the specified [indicatorAppearingBuilder].
  final bool allowUnlistedValues;

  /// Custom builder for the appearing animation of the indicator.
  ///
  /// If you want to use this feature, you have to set [allowUnlistedValues] to [true].
  ///
  /// An indicator can appear if [current] was previously not contained in [values].
  final IndicatorAppearingBuilder indicatorAppearingBuilder;

  /// Duration of the appearing animation.
  final Duration indicatorAppearingDuration;

  /// Curve of the appearing animation.
  final Curve indicatorAppearingCurve;

  /// Builder for divider or other separators between the icons. Consider using [customSeparatorBuilder] for maximum customizability.
  ///
  /// The available width is specified by [dif].
  ///
  /// This builder is supported by [IconArrangement.row] only.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Builder for divider or other separators between the icons. Consider using [separatorBuilder] for a simpler builder function.
  ///
  /// The available width is specified by [dif].
  ///
  /// This builder is supported by [IconArrangement.row] only.
  final CustomSeparatorBuilder<T>? customSeparatorBuilder;

  /// Constructor of AnimatedToggleSwitch with all possible settings.
  ///
  /// Consider using [CustomAnimatedToggleSwitch] for maximum customizability.
  const AnimatedToggleSwitch.custom({
    Key? key,
    required this.current,
    required this.values,
    this.animatedIconBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.indicatorSize = const Size(48.0, double.infinity),
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    this.iconAnimationCurve = Curves.easeOutBack,
    this.iconAnimationDuration,
    this.iconOpacity = 0.5,
    this.borderRadius,
    this.dif = 0.0,
    this.foregroundIndicatorIconBuilder,
    this.selectedIconOpacity = 1.0,
    this.height = 50.0,
    this.borderColorBuilder,
    this.iconAnimationType = AnimationType.onSelected,
    this.indicatorAnimationType = AnimationType.onSelected,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.iconsTappable = true,
    this.defaultCursor,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    this.innerGradient,
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        _defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
  })  : this._iconArrangement = IconArrangement.row,
        super(key: key);

  /// Provides an [AnimatedToggleSwitch] with the standard size animation of the icons.
  ///
  /// Maximum one builder of [iconBuilder] and [customIconBuilder] must be provided.
  AnimatedToggleSwitch.size({
    Key? key,
    required this.current,
    required this.values,
    SimpleSizeIconBuilder<T>? iconBuilder,
    SizeIconBuilder<T>? customIconBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.indicatorSize = const Size(48.0, double.infinity),
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    iconSize = const Size(23.0, 23.0),
    selectedIconSize = const Size(34.5, 34.5),
    this.iconAnimationCurve = Curves.easeOutBack,
    this.iconAnimationDuration,
    this.iconOpacity = 0.5,
    this.borderRadius,
    this.dif = 0.0,
    this.foregroundIndicatorIconBuilder,
    this.selectedIconOpacity = 1.0,
    this.height = 50.0,
    this.borderColorBuilder,
    this.iconAnimationType = AnimationType.onSelected,
    this.indicatorAnimationType = AnimationType.onSelected,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.iconsTappable = true,
    this.defaultCursor,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    this.innerGradient,
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        _defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
  })  : animatedIconBuilder = _iconSizeBuilder<T>(
            iconBuilder, customIconBuilder, iconSize, selectedIconSize),
        this._iconArrangement = IconArrangement.row,
        super(key: key);

  /// All size values ([indicatorWidth], [iconSize], [selectedIconSize]) are relative to the specified height.
  /// (So an [indicatorWidth] of 1.0 means equality of [height] - 2*[borderWidth] and [indicatorWidth])
  ///
  /// Maximum one builder of [iconBuilder] and [customIconBuilder] must be provided.
  AnimatedToggleSwitch.sizeByHeight({
    Key? key,
    this.height = 50.0,
    required this.current,
    required this.values,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    Size indicatorSize = const Size(1.0, 1.0),
    SimpleSizeIconBuilder<T>? iconBuilder,
    SizeIconBuilder<T>? customIconBuilder,
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    iconSize = const Size(0.5, 0.5),
    selectedIconSize = const Size(0.75, 0.75),
    this.iconAnimationCurve = Curves.easeOutBack,
    this.iconAnimationDuration,
    this.iconOpacity = 0.5,
    this.borderRadius,
    dif = 0.0,
    this.foregroundIndicatorIconBuilder,
    this.selectedIconOpacity = 1.0,
    this.borderColorBuilder,
    this.iconAnimationType = AnimationType.onSelected,
    this.indicatorAnimationType = AnimationType.onSelected,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.iconsTappable = true,
    this.defaultCursor,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    this.innerGradient,
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        _defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
  })  : this.indicatorSize = indicatorSize * (height - 2 * borderWidth),
        this.dif = dif * (height - 2 * borderWidth),
        animatedIconBuilder = _iconSizeBuilder<T>(
            iconBuilder,
            customIconBuilder,
            iconSize * (height + 2 * borderWidth),
            selectedIconSize * (height + 2 * borderWidth)),
        this._iconArrangement = IconArrangement.row,
        super(key: key);

  static AnimatedIconBuilder<T>? _iconSizeBuilder<T>(
      SimpleSizeIconBuilder<T>? iconBuilder,
      SizeIconBuilder<T>? customIconBuilder,
      Size iconSize,
      Size selectedIconSize) {
    assert(iconBuilder == null || customIconBuilder == null);
    if (customIconBuilder == null && iconBuilder != null)
      customIconBuilder = (c, l, g) => iconBuilder(l.value, l.iconSize);
    return customIconBuilder == null
        ? null
        : (context, local, global) => customIconBuilder!(
              context,
              SizeProperties.fromAnimated(
                  iconSize: Size(
                      iconSize.width +
                          (selectedIconSize.width - iconSize.width) *
                              local.animationValue,
                      iconSize.height +
                          (selectedIconSize.height - iconSize.height) *
                              local.animationValue),
                  properties: local),
              global,
            );
  }

  /// Another version of [AnimatedToggleSwitch.custom].
  ///
  /// All size values ([indicatorWidth]) are relative to the specified height.
  /// (So an [indicatorWidth] of 1.0 means equality of [height] - 2*[borderWidth] and [indicatorWidth])
  ///
  /// Consider using [CustomAnimatedToggleSwitch] for maximum customizability.
  const AnimatedToggleSwitch.customByHeight({
    Key? key,
    this.height = 50.0,
    required this.current,
    required this.values,
    this.animatedIconBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    Size indicatorSize = const Size(1.0, 1.0),
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    this.iconAnimationCurve = Curves.easeOutBack,
    this.iconAnimationDuration,
    this.iconOpacity = 0.5,
    this.borderRadius,
    dif = 0.0,
    this.foregroundIndicatorIconBuilder,
    this.selectedIconOpacity = 1.0,
    this.borderColorBuilder,
    this.iconAnimationType = AnimationType.onSelected,
    this.indicatorAnimationType = AnimationType.onSelected,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.iconsTappable = true,
    this.defaultCursor,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    this.innerGradient,
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        _defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
  })  : this.dif = dif * (height - 2 * borderWidth),
        this.indicatorSize = indicatorSize * (height - 2 * borderWidth),
        this._iconArrangement = IconArrangement.row,
        super(key: key);

  /// Special version of [AnimatedToggleSwitch.customByHeight].
  ///
  /// It is not recommended to use [iconRadius] and [selectedIconRadius]
  /// but to use the [foreground] argument of [iconBuilder] to determine which size to use.
  /// If you still want to get the sizes in the builder, you have to use the [customIconBuilder] instead of [iconBuilder].
  ///
  /// All size values ([indicatorWidth], [indicatorSize], [selectedIconSize]) are relative to the specified height.
  /// (So an [indicatorWidth] of 1.0 means equality of [height] - 2*[borderWidth] and [indicatorWidth])
  ///
  /// Maximum one builder of [iconBuilder] and [customIconBuilder] must be provided.
  AnimatedToggleSwitch.rollingByHeight({
    Key? key,
    this.height = 50.0,
    required this.current,
    required this.values,
    SimpleRollingIconBuilder<T>? iconBuilder,
    RollingIconBuilder<T>? customIconBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    Size indicatorSize = const Size(1.0, 1.0),
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    double iconRadius = 0.25,
    double selectedIconRadius = 0.35,
    this.iconOpacity = 0.5,
    this.borderRadius,
    double dif = 0.0,
    this.borderColorBuilder,
    this.indicatorAnimationType = AnimationType.onSelected,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.iconsTappable = true,
    this.defaultCursor,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    ForegroundIndicatorTransitionType transitionType =
        ForegroundIndicatorTransitionType.rolling,
    this.innerGradient,
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        _defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
  })  : this.iconAnimationCurve = Curves.linear,
        this.dif = dif * (height - 2 * borderWidth),
        this.iconAnimationDuration = Duration.zero,
        this.indicatorSize = indicatorSize * (height - 2 * borderWidth),
        this.selectedIconOpacity = iconOpacity,
        this.iconAnimationType = AnimationType.onSelected,
        this.foregroundIndicatorIconBuilder =
            _rollingForegroundIndicatorIconBuilder<T>(
                values,
                iconBuilder,
                customIconBuilder,
                Size.square(
                    selectedIconRadius * 2 * (height - 2 * borderWidth)),
                transitionType),
        animatedIconBuilder = _standardIconBuilder(
            iconBuilder,
            customIconBuilder,
            Size.square(iconRadius * 2 * (height - 2 * borderWidth)),
            Size.square(iconRadius * 2 * (height - 2 * borderWidth))),
        this._iconArrangement = IconArrangement.row,
        super(key: key);

  /// Defining a rolling animation using the [foregroundIndicatorIconBuilder] of [AnimatedToggleSwitch].
  ///
  /// It is not recommended to use [iconRadius] and [selectedIconRadius]
  /// but to use the [foreground] argument of [iconBuilder] to determine which size to use.
  /// If you still want to get the sizes in the builder, you have to use the [customIconBuilder] instead of [iconBuilder].
  ///
  /// Maximum one builder of [iconBuilder] and [customIconBuilder] must be provided.
  AnimatedToggleSwitch.rolling({
    Key? key,
    required this.current,
    required this.values,
    SimpleRollingIconBuilder<T>? iconBuilder,
    RollingIconBuilder<T>? customIconBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.indicatorSize = const Size(46.0, double.infinity),
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    double iconRadius = 11.5,
    double selectedIconRadius = 16.1,
    this.iconOpacity = 0.5,
    this.borderRadius,
    this.dif = 0.0,
    this.height = 50.0,
    this.borderColorBuilder,
    this.indicatorAnimationType = AnimationType.onSelected,
    this.onTap,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.iconsTappable = true,
    this.defaultCursor,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    ForegroundIndicatorTransitionType transitionType =
        ForegroundIndicatorTransitionType.rolling,
    this.innerGradient,
    this.allowUnlistedValues = false,
    this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
    this.indicatorAppearingDuration =
        _defaultIndicatorAppearingAnimationDuration,
    this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
    this.separatorBuilder,
    this.customSeparatorBuilder,
  })  : this.iconAnimationCurve = Curves.linear,
        this.iconAnimationDuration = Duration.zero,
        this.selectedIconOpacity = iconOpacity,
        this.iconAnimationType = AnimationType.onSelected,
        this.foregroundIndicatorIconBuilder =
            _rollingForegroundIndicatorIconBuilder<T>(
                values,
                iconBuilder,
                customIconBuilder,
                Size.square(selectedIconRadius * 2),
                transitionType),
        this.animatedIconBuilder = _standardIconBuilder(
            iconBuilder,
            customIconBuilder,
            Size.square(iconRadius * 2),
            Size.square(iconRadius * 2)),
        this._iconArrangement = IconArrangement.row,
        super(key: key);

  static CustomIndicatorBuilder<T> _rollingForegroundIndicatorIconBuilder<T>(
      List<T> values,
      SimpleRollingIconBuilder<T>? iconBuilder,
      RollingIconBuilder<T>? customIconBuilder,
      Size iconSize,
      ForegroundIndicatorTransitionType transitionType) {
    assert(iconBuilder == null || customIconBuilder == null);
    if (customIconBuilder == null && iconBuilder != null)
      customIconBuilder =
          (c, l, g) => iconBuilder(l.value, l.iconSize, l.foreground);
    return (context, global) {
      if (customIconBuilder == null) return SizedBox();
      double distance = global.dif + global.indicatorSize.width;
      double angleDistance =
          transitionType == ForegroundIndicatorTransitionType.rolling
              ? distance /
                  iconSize.longestSide *
                  2 *
                  (global.textDirection == TextDirection.rtl ? -1.0 : 1.0)
              : 0.0;
      final pos = global.position;
      int first = pos.floor();
      double transitionValue = pos - first;
      return Stack(
        children: [
          Transform.rotate(
            angle: transitionValue * angleDistance,
            child: Opacity(
                opacity: 1 - transitionValue,
                child: customIconBuilder(
                    context,
                    RollingProperties(
                      iconSize: iconSize,
                      foreground: true,
                      value: values[first],
                      index: first,
                    ),
                    global)),
          ),
          if (first != pos)
            Transform.rotate(
              angle: (transitionValue - 1) * angleDistance,
              child: Opacity(
                  opacity: transitionValue,
                  child: customIconBuilder(
                      context,
                      RollingProperties(
                        iconSize: iconSize,
                        foreground: true,
                        value: values[pos.ceil()],
                        index: first,
                      ),
                      global)),
            ),
        ],
      );
    };
  }

  static AnimatedIconBuilder<T>? _standardIconBuilder<T>(
      SimpleRollingIconBuilder<T>? iconBuilder,
      RollingIconBuilder<T>? customIconBuilder,
      Size iconSize,
      Size selectedIconSize) {
    assert(iconBuilder == null || customIconBuilder == null);
    if (customIconBuilder == null && iconBuilder != null)
      customIconBuilder =
          (c, l, g) => iconBuilder(l.value, l.iconSize, l.foreground);
    return customIconBuilder == null
        ? null
        : (t, local, global) => customIconBuilder!(
              t,
              RollingProperties.fromLocal(
                  iconSize: iconSize, foreground: false, properties: local),
              global,
            );
  }

  /// Defining an rolling animation using the [foregroundIndicatorIconBuilder] of [AnimatedToggleSwitch].
  ///
  /// Maximum one builder of [iconBuilder] and [customIconBuilder] must be provided.
  /// Maximum one builder of [textBuilder] and [customTextBuilder] must be provided.
  AnimatedToggleSwitch.dual({
    Key? key,
    required this.current,
    required T first,
    required T second,
    SimpleIconBuilder<T>? iconBuilder,
    IconBuilder<T>? customIconBuilder,
    SimpleIconBuilder<T>? textBuilder,
    AnimatedIconBuilder<T>? customTextBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.indicatorSize = const Size(46.0, double.infinity),
    this.onChanged,
    this.borderWidth = 2,
    this.borderColor,
    this.innerColor,
    this.indicatorColor,
    this.colorBuilder,
    double iconRadius = 16.1,
    this.borderRadius,
    this.dif = 40.0,
    this.height = 50.0,
    this.iconAnimationDuration = const Duration(milliseconds: 500),
    this.iconAnimationCurve = Curves.easeInOut,
    this.borderColorBuilder,
    this.indicatorAnimationType = AnimationType.onHover,
    this.fittingMode = FittingMode.preventHorizontalOverlapping,
    Function()? onTap,
    this.indicatorBorder,
    this.foregroundBoxShadow = const [],
    this.boxShadow = const [],
    this.minTouchTargetSize = 48.0,
    this.textDirection,
    this.indicatorBorderRadius,
    this.defaultCursor = SystemMouseCursors.click,
    this.draggingCursor = SystemMouseCursors.grabbing,
    this.dragCursor = SystemMouseCursors.grab,
    this.loadingCursor = MouseCursor.defer,
    EdgeInsetsGeometry textMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    Offset animationOffset = const Offset(20.0, 0),
    bool clipAnimation = true,
    bool opacityAnimation = true,
    this.loadingIconBuilder = _defaultLoadingIconBuilder,
    this.loading,
    this.loadingAnimationDuration,
    this.loadingAnimationCurve,
    ForegroundIndicatorTransitionType transitionType =
        ForegroundIndicatorTransitionType.rolling,
    this.innerGradient,
  })  : assert(clipAnimation || opacityAnimation),
        this.iconOpacity = 1.0,
        this.selectedIconOpacity = 1.0,
        this.values = [first, second],
        this.iconAnimationType = AnimationType.onHover,
        this.iconsTappable = false,
        this.onTap = onTap ?? _dualOnTap(onChanged, [first, second], current),
        this.foregroundIndicatorIconBuilder =
            _rollingForegroundIndicatorIconBuilder(
                [first, second],
                iconBuilder == null ? null : (v, s, f) => iconBuilder(v),
                customIconBuilder,
                Size.square(iconRadius * 2),
                transitionType),
        this.animatedIconBuilder = _dualIconBuilder(
          textBuilder,
          customTextBuilder,
          Size.square(iconRadius * 2),
          [first, second],
          textMargin,
          animationOffset,
          clipAnimation,
          opacityAnimation,
        ),
        this._iconArrangement = IconArrangement.overlap,
        this.allowUnlistedValues = false,
        this.indicatorAppearingBuilder = _defaultIndicatorAppearingBuilder,
        this.indicatorAppearingDuration =
            _defaultIndicatorAppearingAnimationDuration,
        this.indicatorAppearingCurve = _defaultIndicatorAppearingAnimationCurve,
        this.separatorBuilder = null,
        this.customSeparatorBuilder = null,
        super(key: key);

  static Function() _dualOnTap<T>(
      Function(T)? onChanged, List<T> values, T? current) {
    return () =>
        onChanged?.call(values.firstWhere((element) => element != current));
  }

  static AnimatedIconBuilder<T>? _dualIconBuilder<T>(
    SimpleIconBuilder<T>? textBuilder,
    AnimatedIconBuilder<T>? customTextBuilder,
    Size iconSize,
    List<T> values,
    EdgeInsetsGeometry textMargin,
    Offset offset,
    bool clipAnimation,
    bool opacityAnimation,
  ) {
    assert(textBuilder == null || customTextBuilder == null);
    return (context, local, global) {
      bool start = local.index == 0;
      bool left = (global.textDirection == TextDirection.rtl) ^ start;
      int index = start ? 1 : 0;
      T value = values[index];
      AlignmentGeometry alignment = start
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd;

      return Align(
        alignment: alignment,
        child: _CustomClipRect(
          clipBehavior: clipAnimation ? Clip.hardEdge : Clip.none,
          child: Align(
            alignment: alignment,
            widthFactor: min(
                1,
                1 -
                    local.animationValue +
                    global.indicatorSize.width /
                        (2 * (global.indicatorSize.width + global.dif))),
            child: Padding(
              padding: textMargin,
              child: Transform.translate(
                offset: offset * local.animationValue * (left ? 1 : -1),
                child: Opacity(
                    opacity: opacityAnimation ? 1 - local.animationValue : 1,
                    child: textBuilder?.call(value) ??
                        customTextBuilder?.call(
                          context,
                          local.copyWith(
                            value: value,
                            index: index,
                          ),
                          global,
                        )),
              ),
            ),
          ),
        ),
      );
    };
  }

  static Widget _defaultLoadingIconBuilder(
          BuildContext context, dynamic properties) =>
      const _MyLoading();

  // END OF CONSTRUCTOR SECTION

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    BorderRadiusGeometry borderRadius =
        this.borderRadius ?? BorderRadius.circular(height / 2);
    Color indicatorColor = this.indicatorColor ?? theme.colorScheme.secondary;

    return CustomAnimatedToggleSwitch<T>(
        animationCurve: animationCurve,
        animationDuration: animationDuration,
        fittingMode: fittingMode,
        dif: dif,
        height: height,
        onTap: onTap,
        current: current,
        values: values,
        onChanged: onChanged,
        indicatorSize: indicatorSize,
        iconArrangement: _iconArrangement,
        iconsTappable: iconsTappable,
        defaultCursor: defaultCursor,
        dragCursor: dragCursor,
        draggingCursor: draggingCursor,
        loadingCursor: loadingCursor,
        minTouchTargetSize: minTouchTargetSize,
        textDirection: textDirection,
        loading: loading,
        loadingAnimationCurve: loadingAnimationCurve,
        loadingAnimationDuration: loadingAnimationDuration,
        allowUnlistedValues: allowUnlistedValues,
        indicatorAppearingBuilder: indicatorAppearingBuilder,
        indicatorAppearingDuration: indicatorAppearingDuration,
        indicatorAppearingCurve: indicatorAppearingCurve,
        separatorBuilder: customSeparatorBuilder ??
            (separatorBuilder == null
                ? null
                : (context, local, global) =>
                    separatorBuilder!(context, local.index)),
        backgroundIndicatorBuilder: foregroundIndicatorIconBuilder != null
            ? null
            : (context, properties) => _indicatorBuilder(context, properties,
                indicatorColor, indicatorBorderRadius ?? borderRadius),
        foregroundIndicatorBuilder: foregroundIndicatorIconBuilder == null
            ? null
            : (context, properties) => _indicatorBuilder(context, properties,
                indicatorColor, indicatorBorderRadius ?? borderRadius),
        iconBuilder: (context, local, global) => _animatedOpacityIcon(
            _animatedSizeIcon(context, local, global), local.value == current),
        padding: EdgeInsets.all(borderWidth),
        wrapperBuilder: (context, properties, child) =>
            TweenAnimationBuilder<Color?>(
              duration: animationDuration,
              tween: ColorTween(
                begin: borderColorBuilder?.call(current) ??
                    borderColor ??
                    theme.colorScheme.secondary,
                end: borderColorBuilder?.call(current) ??
                    borderColor ??
                    theme.colorScheme.secondary,
              ),
              builder: (c, color, _) => Container(
                clipBehavior: Clip.hardEdge,
                foregroundDecoration: BoxDecoration(
                  border: Border.all(color: color!, width: borderWidth),
                  borderRadius: borderRadius,
                ),
                decoration: BoxDecoration(
                  gradient: innerGradient,
                  // Redundant check
                  color: innerGradient != null
                      ? null
                      : (innerColor ?? theme.scaffoldBackgroundColor),
                  borderRadius: borderRadius,
                  boxShadow: boxShadow,
                ),
                child: child,
              ),
            ));
  }

  Widget _indicatorBuilder(
      BuildContext context,
      DetailedGlobalToggleProperties<T> properties,
      Color indicatorColor,
      BorderRadiusGeometry borderRadius) {
    double pos = properties.position;
    switch (iconAnimationType) {
      case AnimationType.onSelected:
        Color currentColor = colorBuilder?.call(current) ?? indicatorColor;
        return TweenAnimationBuilder<Color?>(
            child: foregroundIndicatorIconBuilder?.call(context, properties),
            duration: animationDuration,
            tween: ColorTween(begin: currentColor, end: currentColor),
            builder: (c, color, child) => _customIndicatorBuilder(
                context, color!, borderRadius, child, properties));
      case AnimationType.onHover:
        return _customIndicatorBuilder(
          context,
          Color.lerp(
                  colorBuilder?.call(values[pos.floor()]) ?? indicatorColor,
                  colorBuilder?.call(values[pos.ceil()]) ?? indicatorColor,
                  pos - pos.floor()) ??
              indicatorColor,
          borderRadius,
          foregroundIndicatorIconBuilder?.call(context, properties),
          properties,
        );
    }
  }

  Widget _animatedIcon(BuildContext context, AnimatedToggleProperties<T> local,
      DetailedGlobalToggleProperties<T> global) {
    return Opacity(
        opacity: 1.0 - global.loadingAnimationValue,
        child: animatedIconBuilder!(context, local, global));
  }

  Widget _animatedSizeIcon(BuildContext context, LocalToggleProperties<T> local,
      DetailedGlobalToggleProperties<T> global) {
    if (animatedIconBuilder == null) return const SizedBox();
    switch (iconAnimationType) {
      case AnimationType.onSelected:
        double currentTweenValue = local.value == global.current ? 1.0 : 0.0;
        return TweenAnimationBuilder(
          curve: iconAnimationCurve,
          duration: iconAnimationDuration ?? animationDuration,
          tween:
              Tween<double>(begin: currentTweenValue, end: currentTweenValue),
          builder: (c, value, child) {
            return _animatedIcon(
              c,
              AnimatedToggleProperties.fromLocal(
                  animationValue: value as double, properties: local),
              global,
            );
          },
        );
      case AnimationType.onHover:
        double animationValue = 0.0;
        double localPosition =
            global.position - global.position.floorToDouble();
        if (values[global.position.floor()] == local.value)
          animationValue = 1 - localPosition;
        else if (values[global.position.ceil()] == local.value)
          animationValue = localPosition;
        return _animatedIcon(
          context,
          AnimatedToggleProperties.fromLocal(
              animationValue: animationValue, properties: local),
          global,
        );
    }
  }

  Widget _animatedOpacityIcon(Widget icon, bool active) {
    return iconOpacity >= 1.0 && selectedIconOpacity >= 1.0
        ? icon
        : AnimatedOpacity(
            opacity: active ? selectedIconOpacity : iconOpacity,
            duration: animationDuration,
            child: icon,
          );
  }

  Widget _customIndicatorBuilder(
      BuildContext context,
      Color color,
      BorderRadiusGeometry borderRadius,
      Widget? child,
      DetailedGlobalToggleProperties<T> global) {
    final loadingValue = global.loadingAnimationValue;
    return DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: indicatorBorder,
          boxShadow: foregroundBoxShadow,
        ),
        child: Center(
          child: Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: [
              if (loadingValue < 1.0)
                Opacity(
                    key: ValueKey(0),
                    opacity: 1.0 - loadingValue,
                    child: child),
              if (loadingValue > 0.0)
                Opacity(
                    key: ValueKey(1),
                    opacity: loadingValue,
                    child: loadingIconBuilder(context, global)),
            ],
          ),
        ));
  }
}

class _CustomClipRect extends StatefulWidget {
  final Clip clipBehavior;
  final Widget child;

  const _CustomClipRect({
    Key? key,
    this.clipBehavior = Clip.hardEdge,
    required this.child,
  }) : super(key: key);

  @override
  _CustomClipRectState createState() => _CustomClipRectState();
}

class _CustomClipRectState extends State<_CustomClipRect> {
  final _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Widget child = _WidgetWrapper(key: _childKey, child: widget.child);
    if (widget.clipBehavior == Clip.none) return child;
    return ClipRect(
      clipBehavior: widget.clipBehavior,
      child: child,
    );
  }
}

class _WidgetWrapper extends StatelessWidget {
  final Widget child;

  const _WidgetWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _MyLoading extends StatelessWidget {
  const _MyLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Theme.of(context).platform.isApple
            ? CupertinoActivityIndicator(color: color)
            : CircularProgressIndicator(color: color));
  }
}

extension _XTargetPlatform on TargetPlatform {
  bool get isApple =>
      this == TargetPlatform.iOS || this == TargetPlatform.macOS;
}
