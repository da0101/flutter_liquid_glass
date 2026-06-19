import UIKit

/// A soft, pulsing neon halo drawn around the tab bar's action button while a
/// background task (e.g. an AI generation) is running.
///
/// Visual recipe: a radial `CAGradientLayer` whose centre is fully transparent
/// and whose mid-ring is a translucent neon colour — so it reads as a glowing
/// ring *around* the action-button glyph without obscuring it. The ring
/// breathes (opacity + scale) and slowly cycles through the AI palette
/// (pink → purple → cyan) to match the app's generation loader.
///
/// Purely decorative: `isUserInteractionEnabled` is false so it never
/// intercepts taps meant for the underlying action button.
final class ActionGlowView: UIView {
	private let gradient = CAGradientLayer()

	/// The AI palette, matching the Flutter `GenerateFab` / generation loader.
	private static let neon: [UIColor] = [
		UIColor(red: 1.00, green: 0.18, blue: 0.58, alpha: 1.0), // pink   #FF2D95
		UIColor(red: 0.75, green: 0.00, blue: 1.00, alpha: 1.0), // purple #BF00FF
		UIColor(red: 0.00, green: 0.94, blue: 1.00, alpha: 1.0), // cyan   #00F0FF
	]

	/// True while the glow animations are attached. Lets `startGlowing()` be
	/// called idempotently from layout passes without restarting the pulse.
	private(set) var isGlowing = false

	override init(frame: CGRect) {
		super.init(frame: frame)
		isUserInteractionEnabled = false
		gradient.type = .radial
		gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
		gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
		gradient.locations = [0.0, 0.55, 1.0]
		gradient.colors = Self.ring(Self.neon[0])
		layer.addSublayer(gradient)
		isHidden = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		gradient.frame = bounds
	}

	/// clear centre → translucent neon ring → clear edge.
	private static func ring(_ color: UIColor) -> [CGColor] {
		return [
			UIColor.clear.cgColor,
			color.withAlphaComponent(0.85).cgColor,
			UIColor.clear.cgColor,
		]
	}

	func startGlowing() {
		if isGlowing { return }
		isGlowing = true
		isHidden = false

		let pulse = CABasicAnimation(keyPath: "opacity")
		pulse.fromValue = 0.45
		pulse.toValue = 1.0
		pulse.duration = 1.4
		pulse.autoreverses = true
		pulse.repeatCount = .infinity
		pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		layer.add(pulse, forKey: "glow.pulse")

		let scale = CABasicAnimation(keyPath: "transform.scale")
		scale.fromValue = 0.9
		scale.toValue = 1.18
		scale.duration = 1.4
		scale.autoreverses = true
		scale.repeatCount = .infinity
		scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		layer.add(scale, forKey: "glow.scale")

		let colorCycle = CAKeyframeAnimation(keyPath: "colors")
		colorCycle.values = [
			Self.ring(Self.neon[0]),
			Self.ring(Self.neon[1]),
			Self.ring(Self.neon[2]),
			Self.ring(Self.neon[0]),
		]
		colorCycle.keyTimes = [0.0, 0.33, 0.66, 1.0]
		colorCycle.duration = 6.0
		colorCycle.repeatCount = .infinity
		gradient.add(colorCycle, forKey: "glow.colorCycle")
	}

	func stopGlowing() {
		if !isGlowing { return }
		isGlowing = false
		layer.removeAllAnimations()
		gradient.removeAllAnimations()
		isHidden = true
	}
}
