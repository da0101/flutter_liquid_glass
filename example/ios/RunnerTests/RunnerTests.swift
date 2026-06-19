import Flutter
import UIKit
import XCTest


@testable import native_liquid_tab_bar

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testGetPlatformVersion() {
    let plugin = NativeLiquidTabBarPlugin()

    let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String, "iOS " + UIDevice.current.systemVersion)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
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
