import SwiftUI

struct AcornJarView: View {
    let acornCount: Int
    let capacity: Int

    var body: some View {
        Canvas { context, size in
            let jarPath = GlassJarShape().path(in: CGRect(origin: .zero, size: size))
            context.fill(jarPath, with: .color(AppTheme.glass.opacity(0.18)))
            drawAcorns(in: &context, size: size)
        }
        .overlay {
            GlassJarShape()
                .stroke(
                    AppTheme.glass.opacity(0.95),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: .white.opacity(0.9), radius: 2, x: -1, y: -1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("유리병")
        .accessibilityValue("도토리 \(acornCount)개, 최대 \(capacity)개")
    }

    private func drawAcorns(in context: inout GraphicsContext, size: CGSize) {
        let columns = 13
        let rows = 29
        let visibleCount = min(max(acornCount, 0), columns * rows)
        let bodyRect = CGRect(
            x: size.width * 0.12,
            y: size.height * 0.27,
            width: size.width * 0.76,
            height: size.height * 0.64
        )
        let cellWidth = bodyRect.width / CGFloat(columns)
        let cellHeight = bodyRect.height / CGFloat(rows)

        for index in 0..<visibleCount {
            let row = index / columns
            let column = index % columns
            let stagger = row.isMultiple(of: 2) ? 0.0 : cellWidth * 0.32
            let x = bodyRect.minX + CGFloat(column) * cellWidth + stagger
            let y = bodyRect.maxY - CGFloat(row + 1) * cellHeight
            let acornRect = CGRect(
                x: x,
                y: y,
                width: cellWidth * 0.74,
                height: cellHeight * 0.84
            )

            context.fill(Path(ellipseIn: acornRect), with: .color(AppTheme.acorn))
            let capRect = CGRect(
                x: acornRect.minX,
                y: acornRect.minY,
                width: acornRect.width,
                height: acornRect.height * 0.3
            )
            context.fill(Path(roundedRect: capRect, cornerRadius: 2), with: .color(AppTheme.acornCap))
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

#Preview {
    AcornJarView(acornCount: 116, capacity: 365)
        .frame(width: 230, height: 300)
        .padding()
        .background(AppTheme.background)
}
