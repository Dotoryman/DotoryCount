import SwiftUI

/// Crops transparent source margins, while preserving the artwork's aspect ratio.
enum JarViewport {
    case exhibit
    case widget

    var crop: CGRect {
        switch self {
        case .exhibit: CGRect(x: 70, y: 410, width: 800, height: 1040)
        case .widget: CGRect(x: 100, y: 500, width: 740, height: 950)
        }
    }
}

struct JarArtworkView: View {
    let progress: AnniversaryProgress
    var viewport: JarViewport = .exhibit
    var latestOffset: CGSize = .zero
    var latestRotation: Double = 0

    private var stage: Int {
        PhotographicJarStages.stage(for: progress.acornsInCurrentJar,
                                   capacity: progress.currentJarCapacity)
    }

    var body: some View {
        GeometryReader { geometry in
            let crop = viewport.crop
            let scale = min(geometry.size.width / crop.width, geometry.size.height / crop.height)
            let width = 941 * scale
            let height = 1672 * scale

            artboard(scale: scale)
                .frame(width: width, height: height)
                .position(x: geometry.size.width / 2 + (470.5 - crop.midX) * scale,
                          y: geometry.size.height / 2 + (836 - crop.midY) * scale)
        }
        .clipped()
        .accessibilityHidden(true)
    }

    private func artboard(scale: CGFloat) -> some View {
        let width = 941 * scale
        let height = 1672 * scale
        let settled = (0..<max(stage - 1, 0)).sorted {
            PhotographicJarStages.placements[$0].depth < PhotographicJarStages.placements[$1].depth
        }
        let golden = Set(progress.jarMilestones.map {
            PhotographicJarStages.stage(for: $0.dayInJar, capacity: progress.currentJarCapacity) - 1
        })

        return ZStack(alignment: .topLeading) {
            Image("JarEmptyBase").resizable().frame(width: width, height: height)

            Ellipse()
                .fill(.black.opacity(stage > 0 ? 0.28 : 0.09))
                .frame(width: 510 * scale, height: 82 * scale)
                .blur(radius: 18 * scale)
                .position(x: 470 * scale, y: 1282 * scale)

            ForEach(settled, id: \.self) { index in
                acorn(index: index, golden: golden.contains(index), scale: scale)
            }
            if stage > 0 {
                acorn(index: stage - 1, golden: golden.contains(stage - 1), scale: scale,
                      offset: latestOffset, rotation: latestRotation)
            }

            Image("JarGlassFront")
                .resizable().frame(width: width, height: height)
                .mask {
                    JarForegroundGlassMask()
                        .fill(style: FillStyle(eoFill: true))
                        .blur(radius: 14 * scale)
                }

            LinearGradient(colors: [.clear, .white.opacity(0.035), .cyan.opacity(0.06)],
                           startPoint: .top, endPoint: .bottom)
                .frame(width: 625 * scale, height: 570 * scale)
                .clipShape(RoundedRectangle(cornerRadius: 72 * scale))
                .position(x: 470 * scale, y: 1000 * scale)
        }
        .frame(width: width, height: height)
    }

    private func acorn(index: Int, golden: Bool, scale: CGFloat,
                       offset: CGSize = .zero, rotation: Double = 0) -> some View {
        let placement = PhotographicJarStages.placements[index]
        let x = (placement.x + offset.width) * scale
        let y = (placement.y + offset.height) * scale
        let name = golden ? "GoldenAcornSprite" :
            (placement.variant == 0 ? "AcornSprite" : placement.variant == 1 ? "AcornSide" : "AcornBack")
        let size = (golden ? 160 : placement.size) * scale

        return ZStack(alignment: .topLeading) {
            Ellipse().fill(.black.opacity(0.22))
                .frame(width: placement.radius * 2.3 * scale, height: placement.radius * 0.9 * scale)
                .blur(radius: 9 * scale)
                .position(x: x + 6 * scale, y: y + 24 * scale)
            Image(name).resizable().scaledToFit()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(placement.angle + rotation))
                .brightness(Double(placement.depth) * 0.045)
                .shadow(color: .black.opacity(0.27), radius: 5 * scale, x: 3 * scale, y: 6 * scale)
                .position(x: x, y: y)
        }
    }
}

private struct JarForegroundGlassMask: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.width / 941
        var path = Path()
        path.addRect(rect)
        path.addEllipse(in: CGRect(x: 165 * scale, y: 1215 * scale,
                                  width: 610 * scale, height: 170 * scale))
        return path
    }
}
