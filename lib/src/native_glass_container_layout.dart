import 'package:flutter/widgets.dart';

/// Internal composition seam used by [NativeGlassContainer].
///
/// The non-positioned child determines the surface size. The native view is
/// decorative only, so Flutter keeps exclusive ownership of gestures and
/// accessibility for every nested control.
class NativeGlassContainerLayout extends StatelessWidget {
  /// Creates the internal background/child stack.
  const NativeGlassContainerLayout({
    super.key,
    required this.background,
    required this.child,
    required this.padding,
  });

  /// Decorative native or test background.
  final Widget background;

  /// Interactive Flutter content.
  final Widget child;

  /// Space between the glass edge and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(child: IgnorePointer(child: background)),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}
