import SwiftUI

/// The exact day count stays in AnniversaryProgress. Thirty-six visual additions
/// give the photographic jar a readable, steadily growing silhouette.
enum PhotographicJarStages {
    static let maximumStage = 36
    static let exactDays = 8

    static func stage(for day: Int, capacity: Int) -> Int {
        let day = min(max(day, 0), max(capacity - 1, 0))
        guard day > exactDays else { return day }
        let remainingDays = max(capacity - exactDays - 1, 1)
        let remainingStages = maximumStage - exactDays
        return min(
            exactDays + 1 + (day - exactDays - 1) * remainingStages / remainingDays,
            maximumStage
        )
    }

    struct Placement: Equatable {
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let size: CGFloat
        let angle: Double
        let variant: Int
        let depth: CGFloat
    }

    // Drop differently sized disks into a shallow curved jar floor. Each disk
    // rests on the floor or a previously settled disk, rather than a fixed row.
    // The glass is 941 × 1672; all coordinates use that artboard.
    static let placements: [Placement] = {
        var result: [Placement] = []
        for index in 0..<maximumStage {
            // The PNGs include soft transparent edges. Their visible bodies are
            // smaller than their frames, so a tighter collision hull lets the
            // silhouettes touch like objects in a real pile.
            let radius = 36 + noise(index, salt: 29) * 4
            let preferredX = 470 + noise(index, salt: 11) * 225
            var bestX: CGFloat = 470
            var bestY: CGFloat = 0
            var bestScore = -CGFloat.infinity

            for step in 0...102 {
                let x = CGFloat(215 + step * 5)
                let distanceFromCenter = x - 470
                let floorY = 1290 - 0.00065 * distanceFromCenter * distanceFromCenter
                var y = floorY - radius

                for previous in result {
                    let dx = x - previous.x
                    let clearance = radius + previous.radius
                    if abs(dx) < clearance {
                        let contactRise = sqrt(clearance * clearance - dx * dx)
                        y = min(y, previous.y - contactRise)
                    }
                }

                // Gravity dominates, with a small deterministic preference for
                // different landing sides so the pile is not mirror-symmetric.
                let score = y - abs(x - preferredX) * 0.045
                if score > bestScore {
                    bestScore = score
                    bestX = x
                    bestY = y
                }
            }

            let variant = min(Int((noise(index, salt: 153) + 1) * 1.5), 2)
            let depth = noise(index, salt: 79)
            result.append(Placement(
                x: bestX,
                y: bestY,
                radius: radius,
                size: variant == 0 ? 190 : 148,
                angle: Double(noise(index, salt: 83) * 155),
                variant: variant,
                depth: depth
            ))
        }
        return result
    }()

    private static func noise(_ index: Int, salt: UInt64) -> CGFloat {
        var value = UInt64(index + 1) &* 6_364_136_223_846_793_005 &+ salt
        value ^= value >> 30
        value &*= 1_379_878_784_942_060_787
        value ^= value >> 27
        return CGFloat(value % 10_000) / 4_999.5 - 1
    }
}

