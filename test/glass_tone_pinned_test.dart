import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// ⛔ LOCKED: every native glass view pins its light/dark tone.
///
/// iOS 26 glass ADAPTS to whatever is behind it. A control that is dark over
/// a dark page turns white the instant a bright photo scrolls under it, and a
/// light glyph on it disappears with the tone it was drawn for. A host app
/// that has chosen one appearance (`themeMode: ThemeMode.dark`) gets a
/// control that silently contradicts it.
///
/// `overrideUserInterfaceStyle`, driven by the `isDark` creation param, is the
/// fix. `NativeGlassSurface` and `NativeTabBar` always had it; the button and
/// the pill did not, which is how a profile button over a sunlit living room
/// came to be invisible (reported 2026-08-30).
///
/// A SOURCE sweep rather than a widget test: this is UIKit behaviour on a real
/// iOS 26 device, so there is nothing a Dart widget test can observe. What CAN
/// be checked anywhere is that no registered platform view forgets the line.
/// ══════════════════════════════════════════════════════════════════════════
void main() {
  /// The four view types registered in `NativeLiquidTabBarPlugin.register`.
  /// Adding a fifth without adding it here is the gap this guard exists for,
  /// so the registration file itself is checked against this list below.
  const glassViews = <String>[
    'NativeGlassButton',
    'NativeGlassPill',
    'NativeGlassSurface',
    'NativeTabBar',
  ];

  for (final name in glassViews) {
    test('LOCKED: $name pins its interface style', () {
      final file = File('ios/Classes/$name.swift');
      expect(
        file.existsSync(),
        isTrue,
        reason: '$name.swift moved — update this guard, do not delete it',
      );

      final source = file.readAsStringSync();
      expect(
        source,
        contains('overrideUserInterfaceStyle'),
        reason: '$name renders adaptive glass without pinning its tone. It '
            'will turn white over bright content. Set '
            'overrideUserInterfaceStyle from the `isDark` config, the way '
            'NativeGlassSurface.apply does.',
      );
      // Pinned to a CONSTANT is not enough — it has to follow the host app's
      // appearance, or a light-themed app gets dark chrome.
      expect(
        source,
        contains('config.isDark ?'),
        reason: '$name pins a hardcoded tone instead of following the '
            "host app's `isDark`",
      );
    });
  }

  // The list above is only a guard while it stays complete.
  test('LOCKED: no glass view type escapes the list', () {
    final source = File('ios/Classes/NativeLiquidTabBarPlugin.swift')
        .readAsStringSync();
    final registered = RegExp(r'withId:\s*"([^"]+)"')
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toSet();

    expect(
      registered.difference(glassViews.toSet()),
      isEmpty,
      reason: 'A platform view is registered but not tone-checked above. Add '
          'it to `glassViews` and pin its interface style.',
    );
  });
}
