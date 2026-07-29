import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass/flutter_liquid_glass.dart';
import 'package:flutter_liquid_glass/src/native_glass_container_layout.dart';

void main() {
  testWidgets('unsupported platforms preserve content through the fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: NativeGlassContainer(
            padding: const EdgeInsets.all(12),
            fallbackBuilder: (_, child) => DecoratedBox(
              key: const Key('fallback-surface'),
              decoration: const BoxDecoration(color: Colors.black),
              child: child,
            ),
            child: const Text('Rich content'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('fallback-surface')), findsOneWidget);
    expect(find.text('Rich content'), findsOneWidget);
    expect(tester.getSize(find.text('Rich content')).height, greaterThan(0));
  });

  testWidgets('decorative native background cannot swallow nested taps', (
    tester,
  ) async {
    var backgroundTaps = 0;
    var playTaps = 0;
    var mixerTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: NativeGlassContainerLayout(
            padding: const EdgeInsets.all(8),
            background: GestureDetector(
              onTap: () => backgroundTaps++,
              child: const ColoredBox(color: Colors.blue),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Play',
                  onPressed: () => playTaps++,
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  tooltip: 'Open mixer',
                  onPressed: () => mixerTaps++,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Play'));
    await tester.tap(find.byTooltip('Open mixer'));

    expect(playTaps, 1);
    expect(mixerTaps, 1);
    expect(backgroundTaps, 0);
  });

  testWidgets('background is excluded from child semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NativeGlassContainerLayout(
          padding: EdgeInsets.zero,
          background: Semantics(
            label: 'Decorative glass',
            child: const ColoredBox(color: Colors.blue),
          ),
          child: Semantics(
            button: true,
            label: 'Pause mix',
            child: const SizedBox(width: 100, height: 44),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Decorative glass'), findsNothing);
    expect(find.bySemanticsLabel('Pause mix'), findsOneWidget);
  });

  testWidgets('child drives size and padding remains stable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: NativeGlassContainerLayout(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            background: ColoredBox(color: Colors.blue),
            child: SizedBox(key: Key('content'), width: 120, height: 44),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(NativeGlassContainerLayout)),
      const Size(144, 60),
    );
  });
}
