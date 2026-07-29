import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass/flutter_liquid_glass.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fallback sheet preserves live nested Flutter actions', (
    tester,
  ) async {
    var nestedTaps = 0;
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showNativeGlassBottomSheet<String>(
                  context: context,
                  heightFactor: 0.8,
                  fallbackBuilder: (_, child) => ColoredBox(
                    key: const Key('sheet-fallback'),
                    color: Colors.black,
                    child: child,
                  ),
                  builder: (sheetContext) => Column(
                    children: [
                      IconButton(
                        key: const Key('nested-action'),
                        onPressed: () => nestedTaps++,
                        icon: const Icon(Icons.play_arrow),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext, 'closed'),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(NativeGlassBottomSheet), findsOneWidget);
    expect(find.byType(NativeGlassContainer), findsOneWidget);
    expect(find.byKey(const Key('sheet-fallback')), findsOneWidget);
    expect(
      find.byKey(const Key('native-glass-sheet-drag-handle')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('nested-action')));
    expect(nestedTaps, 1);
    expect(find.byType(NativeGlassBottomSheet), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(result, 'closed');
    expect(find.byType(NativeGlassBottomSheet), findsNothing);
  });

  testWidgets('surface uses top-only native corners and one safe area', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NativeGlassBottomSheet(
          topCornerRadius: 31,
          child: SizedBox(width: 200, height: 100),
        ),
      ),
    );
    await tester.pump();

    final surface = tester.widget<NativeGlassContainer>(
      find.byType(NativeGlassContainer),
    );
    expect(surface.borderRadius, 31);
    expect(surface.maskedCorners, {
      NativeGlassCorner.topLeft,
      NativeGlassCorner.topRight,
    });
    expect(
      find.descendant(
        of: find.byType(NativeGlassBottomSheet),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets('drag handle and content safe area can be disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NativeGlassBottomSheet(
          showDragHandle: false,
          useSafeArea: false,
          child: Text('Content'),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('native-glass-sheet-drag-handle')),
      findsNothing,
    );
    final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
    expect(safeArea.top, isFalse);
    expect(safeArea.bottom, isFalse);
    expect(find.text('Content'), findsOneWidget);
  });
}
