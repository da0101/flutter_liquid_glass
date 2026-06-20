import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

void main() {
  // A glyph from the bundled Material icon font so the rasteriser has a real
  // codepoint to lay out.
  const heart = IconData(0xe25b, fontFamily: 'MaterialIcons');

  group('rasteriseIconData color parameter', () {
    // [rasteriseIconData] calls `Picture.toImage`, which performs real async
    // GPU work — it must run inside `tester.runAsync`, otherwise the fake
    // async test clock deadlocks the future.
    testWidgets('produces non-empty PNG bytes with the default white colour',
        (tester) async {
      await tester.runAsync(() async {
        final bytes = await rasteriseIconData(heart, size: 60);
        expect(bytes, isA<Uint8List>());
        expect(bytes, isNotEmpty);
      });
    });

    testWidgets('a baked tint produces different bytes than the white default',
        (tester) async {
      await tester.runAsync(() async {
        final white = await rasteriseIconData(heart, size: 60);
        final terracotta = await rasteriseIconData(
          heart,
          size: 60,
          color: const Color(0xFFDC6B4A),
        );

        // Same glyph + size, different colour → encoded pixels must differ.
        expect(terracotta, isNotEmpty);
        expect(terracotta, isNot(equals(white)));
      });
    });

    testWidgets('explicit white colour matches the default', (tester) async {
      await tester.runAsync(() async {
        final defaulted = await rasteriseIconData(heart, size: 60);
        final explicit =
            await rasteriseIconData(heart, size: 60, color: Colors.white);
        expect(explicit, equals(defaulted));
      });
    });
  });
}
