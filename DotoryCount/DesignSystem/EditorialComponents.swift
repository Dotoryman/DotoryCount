import SwiftUI

struct PaperBackdrop: View {
    var body: some View {
        AppTheme.background
            .overlay(alignment: .top) {
                LinearGradient(colors: [AppTheme.surface.opacity(0.65), .clear],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 460)
            }
            .ignoresSafeArea()
    }
}

struct BrandWordmark: View {
    var body: some View {
        HStack(spacing: 7) {
            Image("AcornSprite").resizable().scaledToFit().frame(width: 24, height: 24)
                .accessibilityHidden(true)
            Text("DOTORY COUNT")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(2.3)
                .foregroundStyle(AppTheme.accent)
        }
        .accessibilityLabel("도토리 카운트")
    }
}

struct EditorialEyebrow: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(AppTheme.secondaryText)
    }
}

struct PaperSurface: ViewModifier {
    var cornerRadius: CGFloat = 24
    func body(content: Content) -> some View {
        content
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(AppTheme.divider.opacity(0.55), lineWidth: 0.5)
            }
    }
}

/// Glass is a functional layer. The photograph and reading surfaces remain matte.
struct GlassControlGroup<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 16) { content() }
        } else {
            content()
        }
    }
}
