import Flutter
import UIKit
import XCTest


@testable import flutter_liquid_glass

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testLiquidGlassSupportReturnsPlatformAvailability() {
    let plugin = NativeLiquidTabBarPlugin()

    let call = FlutterMethodCall(methodName: "isLiquidGlassSupported", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      if #available(iOS 26.0, *) {
        XCTAssertEqual(result as? Bool, true)
      } else {
        XCTAssertEqual(result as? Bool, false)
      }
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testRichGlassSurfaceConfigParsesLayoutAndStyle() {
    let config = GlassSurfaceConfig(from: [
      "borderRadius": 18.0,
      "maskedCorners": ["topLeft", "topRight"],
      "style": "clear",
      "isDark": true,
    ])
    XCTAssertEqual(config.borderRadius, 18)
    XCTAssertEqual(
      config.maskedCorners,
      [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    )
    XCTAssertEqual(config.style, "clear")
    XCTAssertTrue(config.isDark)
  }

  func testRichGlassSurfaceIsDecorative() {
    let view = NativeGlassSurfaceView(
      frame: CGRect(x: 0, y: 0, width: 300, height: 60),
      config: GlassSurfaceConfig(from: nil)
    )
    XCTAssertFalse(view.isUserInteractionEnabled)
    XCTAssertFalse(view.isAccessibilityElement)
    XCTAssertTrue(view.accessibilityElementsHidden)
  }

  func testRichGlassSurfaceHonorsFlutterBrightness() {
    let view = NativeGlassSurfaceView(
      frame: CGRect(x: 0, y: 0, width: 300, height: 600),
      config: GlassSurfaceConfig(from: ["isDark": true])
    )

    XCTAssertEqual(view.overrideUserInterfaceStyle, .dark)

    view.apply(GlassSurfaceConfig(from: ["isDark": false]))

    XCTAssertEqual(view.overrideUserInterfaceStyle, .light)
  }

  func testActionButtonGlowingDefaultsToFalse() {
    let config = TabBarConfig(from: ["actionButtonSymbol": "plus"])
    XCTAssertFalse(config.actionButtonGlowing)
  }

  func testActionButtonGlowingIsParsedFromArguments() {
    let config = TabBarConfig(from: [
      "actionButtonSymbol": "plus",
      "actionButtonGlowing": true,
    ])
    XCTAssertTrue(config.actionButtonGlowing)
  }

  func testActionButtonGlowingChangeIsNotStructural() {
    // Toggling the glow must take the in-place light-update path, never a
    // destructive full rebuild of the tab bar.
    let resting = TabBarConfig(from: [
      "symbols": ["a", "b"], "labels": ["A", "B"],
      "actionButtonSymbol": "plus", "actionButtonGlowing": false,
    ])
    let glowing = TabBarConfig(from: [
      "symbols": ["a", "b"], "labels": ["A", "B"],
      "actionButtonSymbol": "plus", "actionButtonGlowing": true,
    ])
    XCTAssertFalse(glowing.structuralChange(from: resting))
    XCTAssertNotEqual(resting, glowing)
  }

}
