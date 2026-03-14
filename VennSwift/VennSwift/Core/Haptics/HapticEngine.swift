import CoreHaptics
import UIKit

// MARK: - VennHapticEngine

/// Premium CoreHaptics engine for Venn.
/// Delivers Apple Showcase-quality tactile experiences using CHHapticEngine,
/// with hand-tuned parameter curves for each distinct interaction moment.
///
/// Usage:
///   await VennHapticEngine.shared.playReveal()
///
/// All methods are safe to call on unsupported hardware — they silently no-op
/// when haptics are unavailable.
@MainActor
final class VennHapticEngine {

    // MARK: - Singleton

    static let shared = VennHapticEngine()
    private init() {}

    // MARK: - Private State

    private var engine: CHHapticEngine?
    private var engineNeedsStart = true

    // MARK: - Engine Lifecycle

    /// Returns a running CHHapticEngine, lazily creating and starting it on
    /// first access. Handles reset callbacks so the engine restarts itself
    /// automatically after an audio session interruption or system termination.
    private func preparedEngine() throws -> CHHapticEngine {
        if let existing = engine, !engineNeedsStart {
            return existing
        }

        let fresh = try CHHapticEngine()

        fresh.resetHandler = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.engineNeedsStart = true
                do {
                    try self.engine?.start()
                    self.engineNeedsStart = false
                } catch {
                    // Engine could not restart; next play call will recreate it
                    self.engine = nil
                }
            }
        }

        fresh.stoppedHandler = { [weak self] reason in
            guard let self else { return }
            Task { @MainActor in
                self.engineNeedsStart = true
            }
        }

        try fresh.start()
        engine = fresh
        engineNeedsStart = false
        return fresh
    }

    /// Convenience: compile and play a pattern, swallowing errors gracefully.
    private func play(_ pattern: CHHapticPattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try preparedEngine()
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Non-fatal: haptics are an enhancement, never a requirement
        }
    }
}

// MARK: - Reveal

extension VennHapticEngine {

    /// Personality reveal moment. A building crescendo of gentle transient taps
    /// that accelerates over 0.7 s, followed by a full-intensity "bloom" burst
    /// backed by a decaying continuous event. The arc is shaped with parameter
    /// curves so the intensity rises non-linearly, matching the visual reveal.
    func playReveal() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        // Crescendo taps: 6 transients with increasing intensity and tightening gaps
        let tapTimes:     [Double] = [0.00, 0.12, 0.22, 0.30, 0.37, 0.43]
        let tapIntensity: [Float]  = [0.15, 0.22, 0.32, 0.45, 0.62, 0.82]
        let tapSharpness: [Float]  = [0.30, 0.40, 0.50, 0.60, 0.70, 0.80]

        var events: [CHHapticEvent] = []

        for (index, time) in tapTimes.enumerated() {
            let intensityParam = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: tapIntensity[index]
            )
            let sharpnessParam = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: tapSharpness[index]
            )
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensityParam, sharpnessParam],
                relativeTime: time
            ))
        }

        // Bloom: high-intensity transient hit at the climax
        events.append(CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0.50
        ))

        // Bloom tail: continuous event that blooms then decays
        events.append(CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
            ],
            relativeTime: 0.50,
            duration: 0.40
        ))

        // Intensity curve: ramp the continuous bloom up then down
        let bloomCurvePoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.0),
            .init(relativeTime: 0.08, value: 1.0),
            .init(relativeTime: 0.25, value: 0.6),
            .init(relativeTime: 0.40, value: 0.0)
        ]
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: bloomCurvePoints,
            relativeTime: 0.50
        )

        // Sharpness curve: crisp at the hit, mellow as it fades
        let sharpnessCurvePoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.5),
            .init(relativeTime: 0.10, value: 0.2),
            .init(relativeTime: 0.40, value: 0.0)
        ]
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: sharpnessCurvePoints,
            relativeTime: 0.50
        )

        do {
            let pattern = try CHHapticPattern(
                events: events,
                parameterCurves: [intensityCurve, sharpnessCurve]
            )
            play(pattern)
        } catch {}
    }
}

// MARK: - Success

extension VennHapticEngine {

    /// Crisp double-tap confirmation, modelled after Apple Pay.
    /// Two transient events with maximum sharpness and a short gap.
    func playSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.85),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.12
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            play(pattern)
        } catch {}
    }
}

// MARK: - Location Found

extension VennHapticEngine {

    /// Warm "landing" feel for arriving at a location.
    /// A soft continuous buzz fades in over 0.25 s, then a medium transient
    /// hits like setting down something solid.
    func playLocationFound() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            // Approach hum
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.05)
                ],
                relativeTime: 0.0,
                duration: 0.30
            ),
            // Landing hit
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.45)
                ],
                relativeTime: 0.28
            )
        ]

        // Fade the approach hum in
        let fadeCurvePoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.0),
            .init(relativeTime: 0.20, value: 1.0),
            .init(relativeTime: 0.28, value: 0.6)
        ]
        let fadeCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: fadeCurvePoints,
            relativeTime: 0.0
        )

        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: [fadeCurve])
            play(pattern)
        } catch {}
    }
}

// MARK: - Waitlist Join

extension VennHapticEngine {

    /// Celebratory ascending triple-tap. Each tap is progressively more
    /// intense, giving a sense of elevation and excitement without being loud.
    func playWaitlistJoin() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.55)
                ],
                relativeTime: 0.00
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.65),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.65)
                ],
                relativeTime: 0.10
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.90),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.80)
                ],
                relativeTime: 0.20
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            play(pattern)
        } catch {}
    }
}

// MARK: - Message Sent

extension VennHapticEngine {

    /// Ultra-light single tap on message send. Barely there, but satisfying —
    /// acknowledges the action without interrupting the conversation flow.
    func playMessageSent() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.28),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.85)
                ],
                relativeTime: 0.0
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            play(pattern)
        } catch {}
    }
}

// MARK: - Message Received

extension VennHapticEngine {

    /// Slightly heavier than sent — a soft, low thud that draws attention
    /// without jarring. Lower sharpness gives it a rounder, warmer character.
    func playMessageReceived() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.20)
                ],
                relativeTime: 0.0
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            play(pattern)
        } catch {}
    }
}

// MARK: - Transition

extension VennHapticEngine {

    /// Phase-transition sweep. A single continuous event at medium intensity
    /// with a gentle sharpness arc, giving the sense of one surface sliding
    /// away and another arriving underneath.
    func playTransition() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.50),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
                ],
                relativeTime: 0.0,
                duration: 0.35
            )
        ]

        // Smooth bell-curve intensity: rises to peak then fades
        let sweepPoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.0),
            .init(relativeTime: 0.12, value: 1.0),
            .init(relativeTime: 0.25, value: 0.8),
            .init(relativeTime: 0.35, value: 0.0)
        ]
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: sweepPoints,
            relativeTime: 0.0
        )

        // Sharpness glides from soft to slightly crisper mid-transition
        let sharpnessPoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 0.1),
            .init(relativeTime: 0.18, value: 0.45),
            .init(relativeTime: 0.35, value: 0.1)
        ]
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: sharpnessPoints,
            relativeTime: 0.0
        )

        do {
            let pattern = try CHHapticPattern(
                events: events,
                parameterCurves: [intensityCurve, sharpnessCurve]
            )
            play(pattern)
        } catch {}
    }
}

// MARK: - Confetti

extension VennHapticEngine {

    /// Confetti scatter. A cluster of light transient events distributed
    /// pseudo-randomly over 0.5 s, simulating individual pieces of confetti
    /// making contact. The intensity varies per tap to avoid uniformity.
    func playConfetti() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        // Hand-designed scatter: irregular timing and intensity variation
        // create the "handful of confetti" texture without true randomness
        // (true randomness can feel broken; this feels organic on replay).
        let taps: [(time: Double, intensity: Float, sharpness: Float)] = [
            (0.000, 0.30, 0.80),
            (0.035, 0.20, 0.90),
            (0.065, 0.40, 0.75),
            (0.095, 0.15, 1.00),
            (0.120, 0.35, 0.85),
            (0.155, 0.25, 0.90),
            (0.185, 0.45, 0.70),
            (0.225, 0.18, 0.95),
            (0.255, 0.30, 0.80),
            (0.300, 0.22, 0.85),
            (0.335, 0.38, 0.75),
            (0.365, 0.20, 0.90),
            (0.400, 0.28, 0.80),
            (0.435, 0.15, 0.95),
            (0.465, 0.32, 0.70),
            (0.495, 0.10, 1.00)
        ]

        let events: [CHHapticEvent] = taps.map { tap in
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: tap.intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: tap.sharpness)
                ],
                relativeTime: tap.time
            )
        }

        // Gentle overall decay so the tail of the confetti feels like it's
        // settling rather than cutting off abruptly.
        let decayPoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.00, value: 1.0),
            .init(relativeTime: 0.30, value: 0.85),
            .init(relativeTime: 0.50, value: 0.50)
        ]
        let decayCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: decayPoints,
            relativeTime: 0.0
        )

        do {
            let pattern = try CHHapticPattern(
                events: events,
                parameterCurves: [decayCurve]
            )
            play(pattern)
        } catch {}
    }
}

// MARK: - Counter Tick

extension VennHapticEngine {

    /// Ultra-subtle tick for animated counter increments. Minimal intensity
    /// with maximum sharpness produces a precise, watch-like click that does
    /// not fatigue the user across many increments.
    func playCounterTick() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.18),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.0
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            play(pattern)
        } catch {}
    }
}

// MARK: - Button Press

extension VennHapticEngine {

    /// Premium button feedback. A medium-intensity transient with a very short
    /// continuous tail gives buttons a tactile "depth" — you feel the press
    /// and the slight spring-back, not just a flat click.
    func playButtonPress() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let events: [CHHapticEvent] = [
            // Initial press impact
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.65),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.70)
                ],
                relativeTime: 0.0
            ),
            // Spring-back tail
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.20)
                ],
                relativeTime: 0.01,
                duration: 0.08
            )
        ]

        // Tail decays quickly so it doesn't linger
        let tailDecayPoints: [CHHapticParameterCurve.ControlPoint] = [
            .init(relativeTime: 0.01, value: 1.0),
            .init(relativeTime: 0.09, value: 0.0)
        ]
        let tailCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: tailDecayPoints,
            relativeTime: 0.01
        )

        do {
            let pattern = try CHHapticPattern(
                events: events,
                parameterCurves: [tailCurve]
            )
            play(pattern)
        } catch {}
    }
}
