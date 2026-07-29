import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_helper.dart';
import 'src/native_glass_container_layout.dart';

/// Builds the non-native version of a [NativeGlassContainer].
///
/// [child] already includes the container's requested padding, so the
/// fallback only needs to paint its surface around it.
typedef NativeGlassFallbackBuilder =
    Widget Function(BuildContext context, Widget child);

/// Native iOS 26 glass material styles.
enum NativeGlassStyle {
  /// Standard adaptive glass with stronger refraction and depth.
  regular,

  /// Clearer glass for image-heavy backgrounds.
  clear,
}

/// Corners that can be rounded by a native glass surface.
enum NativeGlassCorner {
  /// The top-leading corner in a left-to-right coordinate system.
  topLeft,

  /// The top-trailing corner in a left-to-right coordinate system.
  topRight,

  /// The bottom-leading corner in a left-to-right coordinate system.
  bottomLeft,

  /// The bottom-trailing corner in a left-to-right coordinate system.
  bottomRight,
}

/// A native Liquid Glass background with arbitrary live Flutter content.
///
/// On iOS 26+, UIKit paints the material using [UIGlassEffect] while [child]
/// remains in Flutter. This keeps images, text, animations, gestures, and
/// accessibility fully composable. The native background never receives
/// touches and is hidden from assistive technologies.
///
/// On Android and older iOS versions, [fallbackBuilder] paints the surface.
/// When no fallback is supplied the padded child remains visible without a
/// background.
class NativeGlassContainer extends StatefulWidget {
  /// Creates a native glass surface around arbitrary Flutter [child] content.
  const NativeGlassContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 24,
    this.maskedCorners = const {
      NativeGlassCorner.topLeft,
      NativeGlassCorner.topRight,
      NativeGlassCorner.bottomLeft,
      NativeGlassCorner.bottomRight,
    },
    this.style = NativeGlassStyle.regular,
    this.tintColor,
    this.fallbackBuilder,
  }) : assert(borderRadius >= 0);

  /// Live Flutter content painted above the native material.
  final Widget child;

  /// Space between the glass edge and [child].
  final EdgeInsetsGeometry padding;

  /// Uniform native corner radius in logical pixels.
  final double borderRadius;

  /// Corners to which [borderRadius] is applied by the native surface.
  final Set<NativeGlassCorner> maskedCorners;

  /// Native iOS 26 material style.
  final NativeGlassStyle style;

  /// Optional tint applied to the iOS 26 glass material.
  final Color? tintColor;

  /// Builds the Android and older-iOS surface around the padded child.
  final NativeGlassFallbackBuilder? fallbackBuilder;

  @override
  State<NativeGlassContainer> createState() => _NativeGlassContainerState();
}

class _NativeGlassContainerState extends State<NativeGlassContainer> {
  late final Future<bool> _supportFuture;
  MethodChannel? _channel;

  @override
  void initState() {
    super.initState();
    _supportFuture = _checkSupport();
  }

  Future<bool> _checkSupport() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    return LiquidGlassHelper.isLiquidGlassSupported();
  }

  Map<String, Object?> _creationParams() {
    return {
      'borderRadius': widget.borderRadius,
      'maskedCorners': widget.maskedCorners
          .map((corner) => corner.name)
          .toList(),
      'style': widget.style.name,
      'tintColor': widget.tintColor?.toARGB32(),
      'isDark': Theme.of(context).brightness == Brightness.dark,
    };
  }

  void _updateNative() {
    unawaited(_channel?.invokeMethod<void>('update', _creationParams()));
  }

  @override
  void didUpdateWidget(NativeGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.borderRadius != widget.borderRadius ||
        !setEquals(oldWidget.maskedCorners, widget.maskedCorners) ||
        oldWidget.style != widget.style ||
        oldWidget.tintColor != widget.tintColor) {
      _updateNative();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNative();
  }

  Widget _fallback(BuildContext context) {
    final padded = Padding(padding: widget.padding, child: widget.child);
    return widget.fallbackBuilder?.call(context, padded) ?? padded;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _supportFuture,
      builder: (context, snapshot) {
        if (snapshot.data != true) return _fallback(context);

        return NativeGlassContainerLayout(
          padding: widget.padding,
          background: UiKitView(
            viewType: 'NativeGlassSurface',
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            creationParams: _creationParams(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (id) {
              _channel = MethodChannel('NativeGlassSurface_$id');
              _updateNative();
            },
          ),
          child: widget.child,
        );
      },
    );
  }
}
