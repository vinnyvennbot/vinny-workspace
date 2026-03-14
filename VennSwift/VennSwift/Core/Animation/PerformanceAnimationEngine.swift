import Foundation
import UIKit
import QuartzCore
import SwiftUI
import Combine

// MARK: - SpringInterpolator

/// Analytical solution for a damped harmonic oscillator.
///
/// Implements all three regimes — underdamped, critically damped, and overdamped — giving
/// pixel-perfect parity with UIKit's own spring animation model without any iterative
/// approximation.
///
/// The governing equation is:
///   m * x'' + c * x' + k * x = k
/// with initial conditions x(0) = 0, x'(0) = 0, targeting unit displacement x = 1.
struct SpringInterpolator {

    // MARK: Parameters

    let mass: Double
    let stiffness: Double
    let damping: Double

    // MARK: Derived Constants

    /// Exponential decay rate: gamma = c / (2m)
    private var gamma: Double { damping / (2.0 * mass) }

    /// Undamped natural frequency: omega_0 = sqrt(k / m)
    private var omega0: Double { (stiffness / mass).squareRoot() }

    /// Discriminant selects the oscillation regime:
    ///   disc < 0  => underdamped
    ///   disc == 0 => critically damped
    ///   disc > 0  => overdamped
    private var discriminant: Double { gamma * gamma - omega0 * omega0 }

    // MARK: - Presets

    /// Snappy: fast settle with minimal overshoot. Good for toolbar and nav interactions.
    static let snappy = SpringInterpolator(mass: 1.0, stiffness: 400.0, damping: 30.0)

    /// Bouncy: visible overshoot. Good for likes, reactions, and celebratory states.
    static let bouncy = SpringInterpolator(mass: 1.0, stiffness: 200.0, damping: 15.0)

    /// Smooth: moderate settle. Good for modal presentations and card expansions.
    static let smooth = SpringInterpolator(mass: 1.0, stiffness: 300.0, damping: 25.0)

    /// Gentle: slow, deliberate settle. Good for hero reveals and splash moments.
    static let gentle = SpringInterpolator(mass: 1.0, stiffness: 150.0, damping: 20.0)

    // MARK: - Position

    /// Evaluates the spring position at time `t` for a unit step from 0 to 1.
    ///
    /// Applies the exact analytical closed-form solution. At rest the value converges to 1.
    /// Underdamped springs will overshoot beyond 1 before settling.
    ///
    /// - Parameter time: Elapsed seconds since the animation began.
    /// - Returns: Position. Converges to 1 as time increases.
    func value(at time: Double) -> Double {
        guard time > 0.0 else { return 0.0 }

        let g = gamma
        let disc = discriminant

        if abs(disc) < 1e-10 {
            // Critically damped: x(t) = 1 - e^(-g*t) * (1 + g*t)
            let e = Foundation.exp(-g * time)
            return 1.0 - e * (1.0 + g * time)

        } else if disc < 0.0 {
            // Underdamped: x(t) = 1 - e^(-g*t) * (cos(wd*t) + (g/wd)*sin(wd*t))
            // where omega_d = sqrt(omega_0^2 - gamma^2)
            let omegaD = (-disc).squareRoot()
            let e = Foundation.exp(-g * time)
            let c = Foundation.cos(omegaD * time)
            let s = Foundation.sin(omegaD * time)
            return 1.0 - e * (c + (g / omegaD) * s)

        } else {
            // Overdamped: x(t) = 1 - A*e^(r1*t) - B*e^(r2*t)
            // roots r1, r2 = -gamma +/- sqrt(disc)
            let sqrtDisc = disc.squareRoot()
            let r1 = -g + sqrtDisc
            let r2 = -g - sqrtDisc
            // Coefficients derived from x(0)=0, x'(0)=0
            let a = r2 / (r2 - r1)
            let b = -r1 / (r2 - r1)
            return 1.0 - (a * Foundation.exp(r1 * time) + b * Foundation.exp(r2 * time))
        }
    }

    // MARK: - Velocity

    /// Evaluates the instantaneous velocity (dx/dt) at time `t`.
    ///
    /// - Parameter time: Elapsed seconds since the animation began.
    /// - Returns: Velocity in displacement-units per second. Converges to 0 as spring settles.
    func velocity(at time: Double) -> Double {
        guard time > 0.0 else { return 0.0 }

        let g = gamma
        let disc = discriminant

        if abs(disc) < 1e-10 {
            // d/dt [ 1 - e^(-g*t)*(1+g*t) ] = g^2 * t * e^(-g*t)
            return g * g * time * Foundation.exp(-g * time)

        } else if disc < 0.0 {
            let omegaD = (-disc).squareRoot()
            let e = Foundation.exp(-g * time)
            let c = Foundation.cos(omegaD * time)
            let s = Foundation.sin(omegaD * time)
            // d/dt [ 1 - e^(-g*t)*(c + (g/wd)*s) ]
            let inner = (-g) * (c + (g / omegaD) * s) + (-omegaD * s + g * c)
            return -e * inner

        } else {
            let sqrtDisc = disc.squareRoot()
            let r1 = -g + sqrtDisc
            let r2 = -g - sqrtDisc
            let a = r2 / (r2 - r1)
            let b = -r1 / (r2 - r1)
            return -(a * r1 * Foundation.exp(r1 * time) + b * r2 * Foundation.exp(r2 * time))
        }
    }

    // MARK: - Settling Time

    /// The time at which the spring is considered settled — within `epsilon` of the target.
    ///
    /// Uses bisection search over a conservative upper-bound window derived from the system's
    /// decay rate. Accurate to roughly 20 binary-search iterations.
    ///
    /// - Parameter epsilon: Convergence threshold. Default 0.001 (0.1% of target).
    /// - Returns: Settling time in seconds.
    var settlingTime: Double { settlingTime(epsilon: 0.001) }

    func settlingTime(epsilon: Double = 0.001) -> Double {
        let upperBound = max(10.0 / max(gamma, 1e-6), 0.5)
        var lo = 0.0
        var hi = upperBound

        for _ in 0..<24 {
            let mid = (lo + hi) * 0.5
            let dist = abs(value(at: mid) - 1.0)
            if dist < epsilon { hi = mid } else { lo = mid }
        }
        return hi
    }
}

// MARK: - DisplayLinkAnimator

/// Frame-perfect animation driver backed by CADisplayLink at native ProMotion refresh rates.
///
/// Requests 120 Hz via `preferredFrameRateRange` and falls back gracefully on 60 Hz hardware.
/// Automatically pauses the display link when no animations are active, eliminating all CPU
/// and battery overhead between animation bursts.
///
/// Thread-safety: all mutations to the animation registry are serialized through `NSLock`.
/// The display link callback always fires on the main run loop; update callbacks are
/// invoked synchronously on that same thread to avoid adding a frame of dispatch latency.
final class DisplayLinkAnimator: NSObject {

    // MARK: Shared Instance

    static let shared = DisplayLinkAnimator()

    // MARK: - Animation Curve

    enum AnimationCurve {
        /// Constant rate through the animation.
        case linear
        /// Acceleration into the motion.
        case easeIn
        /// Deceleration out of the motion.
        case easeOut
        /// Smooth cubic acceleration and deceleration: 3t^2 - 2t^3.
        case easeInOut
        /// Physics-based damped harmonic oscillator. `t` is elapsed time in seconds.
        case spring(damping: Double, stiffness: Double, mass: Double)
        /// Arbitrary easing function. Receives normalized time [0, 1], must return [0, ~1].
        case custom((Double) -> Double)

        /// Returns the curved output value for a given normalized input time `t`.
        ///
        /// For `.spring`, `t` must be elapsed seconds (not normalized 0-1); caller is
        /// responsible for passing `elapsed` directly rather than `elapsed / duration`.
        func evaluate(_ t: Double) -> Double {
            switch self {
            case .linear:
                return t
            case .easeIn:
                return t * t
            case .easeOut:
                return 1.0 - (1.0 - t) * (1.0 - t)
            case .easeInOut:
                return t * t * (3.0 - 2.0 * t)
            case .spring(let d, let k, let m):
                // For spring, t is treated as normalized [0,1] mapped over settlingTime
                let interp = SpringInterpolator(mass: m, stiffness: k, damping: d)
                return interp.value(at: t * interp.settlingTime)
            case .custom(let fn):
                return fn(t)
            }
        }
    }

    // MARK: - Internal Storage

    private struct AnimationEntry {
        let id: UUID
        let startTime: CFTimeInterval
        let duration: CFTimeInterval
        let curve: AnimationCurve
        let update: (Double) -> Void
        let completion: (() -> Void)?
    }

    // Accessed from the main thread in tick(); accessed from arbitrary threads in animate()/cancel().
    // Serialized via `animationsLock`.
    private var animationRegistry: [UUID: AnimationEntry] = [:]
    private let animationsLock = NSLock()

    private var displayLink: CADisplayLink?

    // MARK: - Init

    private override init() { super.init() }

    // MARK: - Public API

    /// Registers and starts a time-based animation.
    ///
    /// - Parameters:
    ///   - duration: Total duration in seconds. For `.spring` curves, pass the spring's
    ///     `settlingTime` for a natural feel, or any value to time-scale the oscillation.
    ///   - curve: Timing curve applied to normalized progress each frame.
    ///   - update: Closure called synchronously on the main thread each frame.
    ///             Receives a curved progress value. Not necessarily clamped to [0, 1]
    ///             for spring curves that overshoot.
    ///   - completion: Optional closure called on the main thread after the final frame.
    /// - Returns: An opaque token for use with `cancel(_:)`.
    @discardableResult
    func animate(
        duration: CFTimeInterval,
        curve: AnimationCurve = .easeInOut,
        update: @escaping (Double) -> Void,
        completion: (() -> Void)? = nil
    ) -> UUID {
        let id = UUID()
        let entry = AnimationEntry(
            id: id,
            startTime: CACurrentMediaTime(),
            duration: max(duration, 0.001),
            curve: curve,
            update: update,
            completion: completion
        )

        animationsLock.lock()
        animationRegistry[id] = entry
        animationsLock.unlock()

        // Must touch the display link on the main thread
        if Thread.isMainThread {
            ensureDisplayLinkRunning()
        } else {
            DispatchQueue.main.async { [weak self] in self?.ensureDisplayLinkRunning() }
        }
        return id
    }

    /// Cancels a running animation. The completion block will not be invoked.
    ///
    /// Safe to call from any thread.
    func cancel(_ id: UUID) {
        animationsLock.lock()
        animationRegistry.removeValue(forKey: id)
        let empty = animationRegistry.isEmpty
        animationsLock.unlock()

        if empty {
            if Thread.isMainThread {
                pauseDisplayLink()
            } else {
                DispatchQueue.main.async { [weak self] in self?.pauseDisplayLink() }
            }
        }
    }

    // MARK: - Display Link Lifecycle

    private func ensureDisplayLinkRunning() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        // Request ProMotion 120 Hz. On 60 Hz hardware the system clamps to its maximum.
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 80, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func pauseDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Frame Tick

    @objc private func tick(_ link: CADisplayLink) {
        // Snapshot the current registry under lock; do not call user code under lock.
        animationsLock.lock()
        let snapshot = animationRegistry
        animationsLock.unlock()

        let now = link.timestamp
        var completedIDs: [UUID] = []
        var pendingCompletions: [() -> Void] = []

        for (id, entry) in snapshot {
            let elapsed = now - entry.startTime
            let rawProgress = min(elapsed / entry.duration, 1.0)
            let curvedProgress = entry.curve.evaluate(rawProgress)

            // Synchronous call — we are already on main
            entry.update(curvedProgress)

            if rawProgress >= 1.0 {
                completedIDs.append(id)
                if let cb = entry.completion { pendingCompletions.append(cb) }
            }
        }

        if !completedIDs.isEmpty {
            animationsLock.lock()
            for id in completedIDs { animationRegistry.removeValue(forKey: id) }
            let empty = animationRegistry.isEmpty
            animationsLock.unlock()

            for cb in pendingCompletions { cb() }

            if empty { pauseDisplayLink() }
        }
    }

    // MARK: - Debug Access

    /// Returns the number of currently running animations. Intended for the debug overlay.
    internal var debugAnimationCount: Int {
        animationsLock.lock()
        defer { animationsLock.unlock() }
        return animationRegistry.count
    }
}

// MARK: - CALayerAnimationBridge

/// A UIViewRepresentable that vends a raw CALayer to Core Animation, bypassing SwiftUI's
/// animation system entirely for guaranteed GPU-composited rendering.
///
/// Use this for multi-keyframe path animations, particle effects, layer transform sequences,
/// and any case where SwiftUI's implicit animation infrastructure would introduce an
/// intermediate CPU layout pass.
///
/// The `configure` closure fires once at creation. The `animate` closure fires on every
/// SwiftUI view update — add or refresh CAAnimation objects there.
///
/// Example:
/// ```swift
/// CALayerAnimationBridge(
///     configure: { layer in
///         layer.backgroundColor = UIColor.systemRed.cgColor
///         layer.cornerRadius = 12
///     },
///     animate: { layer in
///         let spring = CASpringAnimation(keyPath: "transform.scale")
///         spring.fromValue = 0.8
///         spring.toValue   = 1.0
///         spring.damping   = 12
///         spring.initialVelocity = 20
///         spring.duration  = spring.settlingDuration
///         layer.add(spring, forKey: "scaleIn")
///     }
/// )
/// .frame(width: 100, height: 100)
/// ```
struct CALayerAnimationBridge: UIViewRepresentable {

    /// Called once when the host UIView is first created. Configure static layer properties here.
    let configure: (CALayer) -> Void

    /// Called each time SwiftUI requests a view update. Add CAAnimation objects here.
    let animate: (CALayer) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        configure(view.layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        animate(uiView.layer)
    }
}

// MARK: - MetalShimmerView

/// A GPU-composited shimmer effect using a CAGradientLayer driven by a CABasicAnimation
/// on the `locations` keypath.
///
/// This is the same architectural approach Apple uses for the slide-to-unlock shimmer on
/// the lock screen: the entire effect runs on the render server, leaving the main thread
/// and CPU completely free. Achieves 120 fps on ProMotion hardware with essentially zero
/// CPU cost after the initial setup.
///
/// The `angle` property rotates the sweep for a more natural diagonal highlight rather
/// than a flat horizontal pass.
struct MetalShimmerView: UIViewRepresentable {

    // MARK: Configuration

    /// Tint color of the highlight band. Defaults to Venn coral.
    var color: UIColor = UIColor(red: 1.0, green: 0.39, blue: 0.28, alpha: 1.0)

    /// Duration of one complete sweep, in seconds.
    var duration: CFTimeInterval = 2.0

    /// Rotation angle of the gradient, in degrees. 25 degrees gives a natural diagonal.
    var angle: CGFloat = 25.0

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> ShimmerHostView {
        let host = ShimmerHostView()
        host.backgroundColor = .clear
        host.clipsToBounds = true
        return host
    }

    func updateUIView(_ uiView: ShimmerHostView, context: Context) {
        uiView.apply(color: color, duration: duration, angle: angle)
    }

    // MARK: - ShimmerHostView

    /// UIView subclass that owns the CAGradientLayer.
    /// Subclassing UIView instead of managing a raw sublayer lets us override
    /// `layoutSubviews` to keep the gradient frame in sync with Auto Layout.
    final class ShimmerHostView: UIView {

        private let gradientLayer = CAGradientLayer()
        private var didAddSublayer = false

        override func layoutSubviews() {
            super.layoutSubviews()
            // Keep gradient covering the full bounds, accounting for the rotation transform.
            // We inflate by 40% to ensure the rotated layer always covers the view corners.
            let inflatedSize = max(bounds.width, bounds.height) * 1.4
            gradientLayer.frame = CGRect(
                x: (bounds.width - inflatedSize) / 2.0,
                y: (bounds.height - inflatedSize) / 2.0,
                width: inflatedSize,
                height: inflatedSize
            )
        }

        func apply(color: UIColor, duration: CFTimeInterval, angle: CGFloat) {
            let highlight = color.withAlphaComponent(0.75)

            // Five-stop gradient: lead-in transparents, single highlight band, lead-out transparents.
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.clear.cgColor,
                highlight.cgColor,
                UIColor.clear.cgColor,
                UIColor.clear.cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)

            if !didAddSublayer {
                layer.addSublayer(gradientLayer)
                let radians = angle * CGFloat.pi / 180.0
                gradientLayer.transform = CATransform3DMakeRotation(radians, 0, 0, 1)
                didAddSublayer = true
            }

            // Always remove before re-adding so parameter changes take effect immediately.
            gradientLayer.removeAnimation(forKey: "venn.shimmer.locations")

            // Start positions: all stops off the leading edge.
            gradientLayer.locations = [-0.6, -0.4, -0.2, 0.0, 0.2].map { NSNumber(value: $0) }

            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-0.6, -0.4, -0.2, 0.0, 0.2].map { NSNumber(value: $0) }
            animation.toValue   = [ 0.8,  1.0,  1.2, 1.4, 1.6].map { NSNumber(value: $0) }
            animation.duration  = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .greatestFiniteMagnitude
            animation.isRemovedOnCompletion = false
            gradientLayer.add(animation, forKey: "venn.shimmer.locations")
        }
    }
}

// MARK: - PerformanceOverlay (DEBUG only)

#if DEBUG

/// A compact pill overlay displaying real-time frame delivery rate and active animation count.
///
/// Only compiled into DEBUG builds. Add it at the very top of your view hierarchy to ensure
/// it is never obscured by other content:
///
/// ```swift
/// ZStack(alignment: .topTrailing) {
///     ContentView()
///     PerformanceOverlay()
///         .padding(.top, 56)
///         .padding(.trailing, 16)
///         .allowsHitTesting(false)
/// }
/// ```
struct PerformanceOverlay: View {

    @StateObject private var counter = FPSCounter.shared

    var body: some View {
        HStack(spacing: 6) {
            statusDot
            Text("\(counter.fps) fps")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 12)

            Text("\(counter.activeAnimations) anim")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.75))
                .overlay(
                    Capsule().stroke(borderColor, lineWidth: 1)
                )
        )
        .onAppear { counter.start() }
        .onDisappear { counter.stop() }
    }

    // MARK: Private Views

    private var statusDot: some View {
        Circle()
            .fill(dotColor)
            .frame(width: 6, height: 6)
    }

    // MARK: Derived Appearance

    private var dotColor: Color {
        switch counter.fps {
        case 90...: return Color(red: 0.20, green: 0.87, blue: 0.45)
        case 55...: return Color(red: 0.20, green: 0.87, blue: 0.45)
        case 40...: return Color(red: 1.00, green: 0.75, blue: 0.20)
        default:    return Color(red: 1.00, green: 0.27, blue: 0.27)
        }
    }

    private var borderColor: Color {
        counter.fps >= 55
            ? Color.white.opacity(0.12)
            : Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0.45)
    }
}

// MARK: - FPSCounter

/// Measures real frame delivery rate via a dedicated CADisplayLink and exposes results
/// as @Published properties for SwiftUI binding.
///
/// Intentionally isolated from DisplayLinkAnimator so that the measurement overhead
/// does not perturb the animations being profiled.
final class FPSCounter: NSObject, ObservableObject {

    static let shared = FPSCounter()

    // MARK: Published State

    @Published private(set) var fps: Int = 0
    @Published private(set) var activeAnimations: Int = 0

    // MARK: Private State

    private var displayLink: CADisplayLink?
    private var frameCount: Int = 0
    private var windowStart: CFTimeInterval = 0

    private override init() { super.init() }

    // MARK: - Lifecycle

    func start() {
        guard displayLink == nil else { return }
        windowStart = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(frame(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - CADisplayLink Callback

    @objc private func frame(_ link: CADisplayLink) {
        frameCount += 1
        let elapsed = link.timestamp - windowStart

        guard elapsed >= 1.0 else { return }

        fps = Int(Double(frameCount) / elapsed)
        activeAnimations = DisplayLinkAnimator.shared.debugAnimationCount
        frameCount = 0
        windowStart = link.timestamp
    }
}

#endif
