import SwiftUI

struct AcornJarView: View {
    let acornCount: Int
    let capacity: Int
    var latestAcornPresentation: LatestAcornPresentation = .static

    var body: some View {
        GeometryReader { proxy in
            let placements = AcornJarLayout.placements(count: acornCount)
            let latestPlacement = placements.last?.resolved(in: proxy.size)
            let staticPlacements = latestAcornPresentation == .static
                ? placements[...]
                : placements.dropLast()

            ZStack {
                GlassJarShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.glass.opacity(0.10),
                                AppTheme.glass.opacity(0.24),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Canvas { context, size in
                    for placement in staticPlacements {
                        AcornRenderer.draw(
                            in: &context,
                            placement: placement.resolved(in: size)
                        )
                    }
                }

                if latestAcornPresentation == .falling, let latestPlacement {
                    FallingAcornView(placement: latestPlacement)
                }

                jarHighlights
            }
            .clipShape(GlassJarShape())
            .overlay {
                GlassJarShape()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white, AppTheme.glass, AppTheme.glass.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                    )
            }
            .overlay(alignment: .top) {
                jarRim
            }
            .shadow(color: AppTheme.accent.opacity(0.12), radius: 12, y: 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("유리병")
        .accessibilityValue("도토리 \(acornCount)개, 최대 \(capacity)개")
        .accessibilityIdentifier("acorn-jar")
    }

    private var jarHighlights: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(Color.white.opacity(0.34))
                .frame(width: proxy.size.width * 0.035, height: proxy.size.height * 0.50)
                .blur(radius: 0.7)
                .position(x: proxy.size.width * 0.19, y: proxy.size.height * 0.52)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var jarRim: some View {
        GeometryReader { proxy in
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [Color.white, AppTheme.glass, Color.white.opacity(0.75)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 5
                )
                .frame(width: proxy.size.width * 0.51, height: proxy.size.height * 0.055)
                .position(x: proxy.size.width / 2, y: 4)
        }
        .accessibilityHidden(true)
    }
}

enum LatestAcornPresentation: Equatable {
    case hidden
    case falling
    case `static`
}

nonisolated struct AcornPlacement: Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let rotation: Double

    func resolved(in size: CGSize) -> ResolvedAcornPlacement {
        ResolvedAcornPlacement(
            center: CGPoint(x: size.width * x, y: size.height * y),
            size: CGSize(width: size.width * width, height: size.height * height),
            rotation: .degrees(rotation)
        )
    }
}

struct ResolvedAcornPlacement {
    let center: CGPoint
    let size: CGSize
    let rotation: Angle
}

enum AcornJarLayout {
    private static let columns = 13
    private static let rows = 29
    private static let columnOrder = [6, 5, 7, 4, 8, 3, 9, 2, 10, 1, 11, 0, 12]

    static var maximumVisibleCount: Int {
        columns * rows
    }

    static func placements(count: Int) -> [AcornPlacement] {
        let visibleCount = min(max(count, 0), maximumVisibleCount)
        let cellWidth = 0.72 / Double(columns)
        let cellHeight = 0.66 / Double(rows)

        return (0..<visibleCount).map { index in
            let row = index / columns
            let orderedColumn = columnOrder[index % columns]
            let stagger = row.isMultiple(of: 2) ? -cellWidth * 0.12 : cellWidth * 0.12
            let jitterX = centeredNoise(index: index, salt: 17) * cellWidth * 0.15
            let jitterY = centeredNoise(index: index, salt: 43) * cellHeight * 0.18
            let scale = 0.92 + unitNoise(index: index, salt: 71) * 0.14

            return AcornPlacement(
                x: 0.14 + (Double(orderedColumn) + 0.5) * cellWidth + stagger + jitterX,
                y: 0.91 - (Double(row) + 0.5) * cellHeight + jitterY,
                width: 0.046 * scale,
                height: 0.032 * scale,
                rotation: centeredNoise(index: index, salt: 101) * 18
            )
        }
    }

    private static func centeredNoise(index: Int, salt: UInt64) -> Double {
        unitNoise(index: index, salt: salt) * 2 - 1
    }

    private static func unitNoise(index: Int, salt: UInt64) -> Double {
        var value = UInt64(index) &* 6_364_136_223_846_793_005 &+ salt
        value ^= value >> 30
        value &*= 1_379_878_784_942_060_787
        value ^= value >> 27
        return Double(value % 10_000) / 9_999
    }
}

private struct FallingAcornView: View {
    let placement: ResolvedAcornPlacement

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSettled = false

    var body: some View {
        Canvas { context, size in
            AcornRenderer.draw(
                in: &context,
                placement: ResolvedAcornPlacement(
                    center: CGPoint(x: size.width / 2, y: size.height / 2),
                    size: placement.size,
                    rotation: .zero
                )
            )
        }
        .frame(width: placement.size.width * 2.4, height: placement.size.height * 2.4)
        .position(placement.center)
        .offset(y: reduceMotion || isSettled ? 0 : -(placement.center.y + placement.size.height * 3))
        .rotationEffect(isSettled ? placement.rotation : placement.rotation - .degrees(95))
        .scaleEffect(isSettled ? 1 : (reduceMotion ? 0.9 : 1.08))
        .opacity(isSettled ? 1 : (reduceMotion ? 0 : 1))
        .task {
            await Task.yield()

            if reduceMotion {
                withAnimation(.easeOut(duration: 0.24)) {
                    isSettled = true
                }
            } else {
                withAnimation(.spring(response: 0.82, dampingFraction: 0.68)) {
                    isSettled = true
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private enum AcornRenderer {
    static func draw(
        in context: inout GraphicsContext,
        placement: ResolvedAcornPlacement
    ) {
        context.drawLayer { layer in
            layer.translateBy(x: placement.center.x, y: placement.center.y)
            layer.rotate(by: placement.rotation)

            let width = placement.size.width
            let height = placement.size.height
            let bodyRect = CGRect(
                x: -width / 2,
                y: -height * 0.30,
                width: width,
                height: height * 0.86
            )

            var body = Path()
            body.move(to: CGPoint(x: bodyRect.midX, y: bodyRect.maxY))
            body.addCurve(
                to: CGPoint(x: bodyRect.minX, y: bodyRect.minY + bodyRect.height * 0.35),
                control1: CGPoint(x: bodyRect.minX + width * 0.20, y: bodyRect.maxY),
                control2: CGPoint(x: bodyRect.minX, y: bodyRect.midY)
            )
            body.addQuadCurve(
                to: CGPoint(x: bodyRect.maxX, y: bodyRect.minY + bodyRect.height * 0.35),
                control: CGPoint(x: bodyRect.midX, y: bodyRect.minY - height * 0.10)
            )
            body.addCurve(
                to: CGPoint(x: bodyRect.midX, y: bodyRect.maxY),
                control1: CGPoint(x: bodyRect.maxX, y: bodyRect.midY),
                control2: CGPoint(x: bodyRect.maxX - width * 0.20, y: bodyRect.maxY)
            )

            layer.fill(
                body,
                with: .linearGradient(
                    Gradient(colors: [AppTheme.acornLight, AppTheme.acorn, AppTheme.acornDark]),
                    startPoint: CGPoint(x: bodyRect.minX, y: bodyRect.minY),
                    endPoint: CGPoint(x: bodyRect.maxX, y: bodyRect.maxY)
                )
            )

            let capRect = CGRect(
                x: -width * 0.52,
                y: -height * 0.42,
                width: width * 1.04,
                height: height * 0.34
            )
            layer.fill(
                Path(roundedRect: capRect, cornerRadius: height * 0.12),
                with: .linearGradient(
                    Gradient(colors: [AppTheme.acornCapLight, AppTheme.acornCap]),
                    startPoint: CGPoint(x: capRect.minX, y: capRect.minY),
                    endPoint: CGPoint(x: capRect.maxX, y: capRect.maxY)
                )
            )

            var stem = Path()
            stem.move(to: CGPoint(x: 0, y: capRect.minY + 1))
            stem.addQuadCurve(
                to: CGPoint(x: width * 0.12, y: capRect.minY - height * 0.18),
                control: CGPoint(x: width * 0.02, y: capRect.minY - height * 0.12)
            )
            layer.stroke(stem, with: .color(AppTheme.acornCap), lineWidth: max(width * 0.10, 0.8))
        }
    }
}

private struct GlassJarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let neckWidth = rect.width * 0.48
        let neckLeft = rect.midX - neckWidth / 2
        let neckRight = rect.midX + neckWidth / 2
        let shoulderY = rect.height * 0.23

        path.move(to: CGPoint(x: neckLeft, y: rect.minY + 4))
        path.addLine(to: CGPoint(x: neckRight, y: rect.minY + 4))
        path.addLine(to: CGPoint(x: neckRight, y: rect.height * 0.12))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 8, y: shoulderY),
            control1: CGPoint(x: neckRight, y: rect.height * 0.17),
            control2: CGPoint(x: rect.maxX - 8, y: rect.height * 0.16)
        )
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.maxY - 24))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 30, y: rect.maxY - 4),
            control: CGPoint(x: rect.maxX - 8, y: rect.maxY - 4)
        )
        path.addLine(to: CGPoint(x: rect.minX + 30, y: rect.maxY - 4))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 8, y: rect.maxY - 24),
            control: CGPoint(x: rect.minX + 8, y: rect.maxY - 4)
        )
        path.addLine(to: CGPoint(x: rect.minX + 8, y: shoulderY))
        path.addCurve(
            to: CGPoint(x: neckLeft, y: rect.height * 0.12),
            control1: CGPoint(x: rect.minX + 8, y: rect.height * 0.16),
            control2: CGPoint(x: neckLeft, y: rect.height * 0.17)
        )
        path.closeSubpath()
        return path
    }
}

#Preview("오늘의 도토리") {
    AcornJarView(acornCount: 116, capacity: 365, latestAcornPresentation: .falling)
        .frame(width: 230, height: 300)
        .padding()
        .background(AppTheme.background)
}

#Preview("가득 찬 병") {
    AcornJarView(acornCount: 366, capacity: 366)
        .frame(width: 230, height: 300)
        .padding()
        .background(AppTheme.background)
}
