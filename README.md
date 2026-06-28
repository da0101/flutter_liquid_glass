# flutter_liquid_glass

A Flutter plugin that renders a native iOS 26 Liquid Glass navigation bar using platform views and method channels. No uncanny valley — it's the actual native `UITabBar`.

Falls back gracefully to a custom Flutter widget on Android and older iOS versions.

## Features

- Native iOS 26 Liquid Glass tab bar via `UITabBar`
- Custom icon bytes support — use any image as a tab icon
- Action button (FAB) with custom icon bytes
- `NativeGlassPill` — standalone pill widget for titles and labels
- Tint color control
- Fallback widget for Android / iOS < 26
- Zero third-party dependencies

## Installation

```yaml
dependencies:
  flutter_liquid_glass:
    git:
      url: https://github.com/da0101/flutter_liquid_glass.git
      ref: main
```

## Usage

```dart
import 'package:flutter_liquid_glass/flutter_liquid_glass.dart';
```

### Basic

```dart
NativeGlassNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  tabs: const [
    NativeGlassNavBarItem(label: 'Home', symbol: 'house'),
    NativeGlassNavBarItem(label: 'Search', symbol: 'magnifyingglass'),
    NativeGlassNavBarItem(label: 'Settings', symbol: 'gear'),
  ],
)
```

### Custom Icon Bytes

```dart
NativeGlassNavBarItem(
  label: 'Home',
  iconBytes: await rootBundle.load('assets/icons/home.png')
      .then((data) => data.buffer.asUint8List()),
)
```

### With Action Button

```dart
NativeGlassNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  actionButton: TabBarActionButton(
    symbol: 'plus',
    onTap: () => print('tapped'),
  ),
  tabs: const [
    NativeGlassNavBarItem(label: 'Home', symbol: 'house'),
    NativeGlassNavBarItem(label: 'Profile', symbol: 'person'),
  ],
)
```

### Fallback for Android / older iOS

```dart
NativeGlassNavBar(
  // ...
  fallback: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (index) => setState(() => _currentIndex = index),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ],
  ),
)
```

## API Reference

### NativeGlassNavBar

| Parameter | Type | Description |
|---|---|---|
| `tabs` | `List<NativeGlassNavBarItem>` | Tabs to display. Max 5 (4 with action button). |
| `currentIndex` | `int` | Selected tab index. |
| `onTap` | `ValueChanged<int>` | Tab selection callback. |
| `actionButton` | `TabBarActionButton?` | Optional FAB. |
| `tintColor` | `Color?` | Selected item color. Defaults to `colorScheme.primary`. |
| `fallback` | `Widget?` | Widget shown on unsupported platforms. |

### NativeGlassNavBarItem

| Parameter | Type | Description |
|---|---|---|
| `label` | `String` | Tab label. |
| `symbol` | `String?` | SF Symbol name (e.g. `'house.fill'`). |
| `iconBytes` | `Uint8List?` | Custom icon image bytes. Takes priority over `symbol`. |

### NativeGlassPill

Standalone pill-shaped label with native Liquid Glass background.

| Parameter | Type | Description |
|---|---|---|
| `child` | `Widget` | Content inside the pill. |
| `width` | `double?` | Optional fixed width. |
