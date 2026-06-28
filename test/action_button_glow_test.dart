import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass/flutter_liquid_glass.dart';

void main() {
  group('TabBarActionButton.glowing', () {
    test('defaults to false (resting state)', () {
      final button = TabBarActionButton(onTap: () {}, symbol: 'plus');
      expect(button.glowing, isFalse);
    });

    test('can be enabled', () {
      final button =
          TabBarActionButton(onTap: () {}, symbol: 'plus', glowing: true);
      expect(button.glowing, isTrue);
    });

    test('works with an IconData icon', () {
      const icon = IconData(0xe000, fontFamily: 'MaterialIcons');
      final button =
          TabBarActionButton(onTap: () {}, iconData: icon, glowing: true);
      expect(button.glowing, isTrue);
      expect(button.iconData, icon);
    });

    test('still requires a symbol or iconData', () {
      expect(
        () => TabBarActionButton(onTap: () {}),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
