import Flutter
import UIKit

final class NativeGlassSurfaceFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeGlassSurfacePlatformView(
      frame: frame,
      viewId: viewId,
      args: args,
      messenger: messenger
    )
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

struct GlassSurfaceConfig {
  var borderRadius: CGFloat = 24
  var maskedCorners: CACornerMask = [
    .layerMinXMinYCorner,
    .layerMaxXMinYCorner,
    .layerMinXMaxYCorner,
    .layerMaxXMaxYCorner,
  ]
  var style = "regular"
  var tintColor: UIColor?
  var isDark = false

  init(from dict: [String: Any]?) {
    guard let dict else { return }
    if let value = dict["borderRadius"] as? NSNumber {
      borderRadius = max(0, CGFloat(value.doubleValue))
    }
    if let values = dict["maskedCorners"] as? [String] {
      var corners: CACornerMask = []
      if values.contains("topLeft") { corners.insert(.layerMinXMinYCorner) }
      if values.contains("topRight") { corners.insert(.layerMaxXMinYCorner) }
      if values.contains("bottomLeft") { corners.insert(.layerMinXMaxYCorner) }
      if values.contains("bottomRight") { corners.insert(.layerMaxXMaxYCorner) }
      maskedCorners = corners
    }
    if let value = dict["style"] as? String { style = value }
    if let value = dict["tintColor"] as? NSNumber {
      tintColor = IconResolver.uiColorFromARGB(value.intValue)
    }
    if let value = dict["isDark"] as? Bool { isDark = value }
  }
}

final class NativeGlassSurfaceView: UIView {
  private let effectView = UIVisualEffectView()
  private var config: GlassSurfaceConfig

  init(frame: CGRect, config: GlassSurfaceConfig) {
    self.config = config
    super.init(frame: frame)

    backgroundColor = .clear
    isUserInteractionEnabled = false
    isAccessibilityElement = false
    accessibilityElementsHidden = true

    effectView.translatesAutoresizingMaskIntoConstraints = false
    effectView.isUserInteractionEnabled = false
    addSubview(effectView)
    NSLayoutConstraint.activate([
      effectView.topAnchor.constraint(equalTo: topAnchor),
      effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    apply(config)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  func apply(_ config: GlassSurfaceConfig) {
    self.config = config
    let interfaceStyle: UIUserInterfaceStyle = config.isDark ? .dark : .light
    overrideUserInterfaceStyle = interfaceStyle
    effectView.overrideUserInterfaceStyle = interfaceStyle
    if #available(iOS 26.0, *) {
      let style: UIGlassEffect.Style = config.style == "clear" ? .clear : .regular
      let effect = UIGlassEffect(style: style)
      effect.isInteractive = false
      effect.tintColor = config.tintColor
      effectView.effect = effect
    } else {
      let style: UIBlurEffect.Style =
        config.isDark ? .systemMaterialDark : .systemMaterialLight
      effectView.effect = UIBlurEffect(style: style)
    }
    setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    effectView.layer.cornerCurve = .continuous
    effectView.layer.maskedCorners = config.maskedCorners
    effectView.layer.cornerRadius = min(
      config.borderRadius,
      min(bounds.width, bounds.height) / 2
    )
    effectView.layer.masksToBounds = true
  }
}

private final class NativeGlassSurfacePlatformView: NSObject, FlutterPlatformView {
  private let hostView: NativeGlassSurfaceView
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    let config = GlassSurfaceConfig(from: args as? [String: Any])
    hostView = NativeGlassSurfaceView(frame: frame, config: config)
    channel = FlutterMethodChannel(
      name: "NativeGlassSurface_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "update" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.hostView.apply(
        GlassSurfaceConfig(from: call.arguments as? [String: Any])
      )
      result(nil)
    }
  }

  func view() -> UIView { hostView }
}
