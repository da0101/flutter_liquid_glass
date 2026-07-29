import 'package:flutter/material.dart';

import 'native_glass_container.dart';

/// Presents arbitrary Flutter content over native iOS 26 Liquid Glass.
///
/// Flutter retains ownership of the modal route, drag and dismissal behavior,
/// focus, semantics, and the complete [builder] subtree. UIKit paints only the
/// decorative material through [NativeGlassContainer].
Future<T?> showNativeGlassBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  NativeGlassFallbackBuilder? fallbackBuilder,
  NativeGlassStyle style = NativeGlassStyle.regular,
  Color? tintColor,
  double topCornerRadius = 28,
  double? heightFactor,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  bool showDragHandle = true,
  bool useSafeArea = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
}) {
  assert(topCornerRadius >= 0);
  assert(heightFactor == null || (heightFactor > 0 && heightFactor <= 1));

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    showDragHandle: false,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    builder: (sheetContext) {
      final sheet = NativeGlassBottomSheet(
        fallbackBuilder: fallbackBuilder,
        style: style,
        tintColor: tintColor,
        topCornerRadius: topCornerRadius,
        showDragHandle: showDragHandle,
        useSafeArea: useSafeArea,
        child: builder(sheetContext),
      );
      if (heightFactor == null) return sheet;
      return FractionallySizedBox(heightFactor: heightFactor, child: sheet);
    },
  );
}

/// The reusable surface used by [showNativeGlassBottomSheet].
///
/// This widget is public so applications with a custom route can reuse the
/// same native/fallback material contract without using Flutter's stock modal
/// presenter.
class NativeGlassBottomSheet extends StatelessWidget {
  /// Creates a bottom-attached glass surface around live Flutter [child].
  const NativeGlassBottomSheet({
    super.key,
    required this.child,
    this.fallbackBuilder,
    this.style = NativeGlassStyle.regular,
    this.tintColor,
    this.topCornerRadius = 28,
    this.showDragHandle = true,
    this.useSafeArea = true,
  }) : assert(topCornerRadius >= 0);

  /// Live Flutter content displayed by the sheet.
  final Widget child;

  /// Optional Android and older-iOS surface painter.
  final NativeGlassFallbackBuilder? fallbackBuilder;

  /// Native iOS 26 material style.
  final NativeGlassStyle style;

  /// Optional native material tint.
  final Color? tintColor;

  /// Radius applied only to the two top corners.
  final double topCornerRadius;

  /// Whether to paint a Flutter drag-handle affordance.
  final bool showDragHandle;

  /// Whether content avoids the device's bottom system inset.
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    return NativeGlassContainer(
      key: const Key('native-glass-bottom-sheet'),
      borderRadius: topCornerRadius,
      maskedCorners: const {
        NativeGlassCorner.topLeft,
        NativeGlassCorner.topRight,
      },
      style: style,
      tintColor: tintColor,
      fallbackBuilder: fallbackBuilder ?? _defaultFallback(topCornerRadius),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          bottom: useSafeArea,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: showDragHandle ? 24 : 0),
                child: child,
              ),
              if (showDragHandle)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ExcludeSemantics(
                      child: Container(
                        key: const Key('native-glass-sheet-drag-handle'),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  NativeGlassFallbackBuilder _defaultFallback(double radius) {
    return (context, paddedChild) {
      final theme = Theme.of(context);
      return Material(
        color:
            theme.bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        clipBehavior: Clip.antiAlias,
        child: paddedChild,
      );
    };
  }
}
