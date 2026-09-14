import SwiftUI
import UIKit

enum AppTheme {
    static let background = adaptive(
        light: UIColor(red: 0.97, green: 0.95, blue: 0.90, alpha: 1),
        dark: UIColor(red: 0.10, green: 0.085, blue: 0.07, alpha: 1)
    )
    static let surface = adaptive(
        light: UIColor(white: 1, alpha: 0.72),
        dark: UIColor(red: 0.18, green: 0.16, blue: 0.13, alpha: 0.92)
    )
    static let accent = adaptive(
        light: UIColor(red: 0.43, green: 0.27, blue: 0.13, alpha: 1),
        dark: UIColor(red: 0.83, green: 0.64, blue: 0.40, alpha: 1)
    )
    static let acorn = adaptive(
        light: UIColor(red: 0.55, green: 0.32, blue: 0.13, alpha: 1),
        dark: UIColor(red: 0.66, green: 0.40, blue: 0.19, alpha: 1)
    )
    static let acornLight = adaptive(
        light: UIColor(red: 0.72, green: 0.45, blue: 0.21, alpha: 1),
        dark: UIColor(red: 0.79, green: 0.53, blue: 0.27, alpha: 1)
    )
    static let acornDark = Color(red: 0.40, green: 0.21, blue: 0.08)
    static let acornCap = adaptive(
        light: UIColor(red: 0.32, green: 0.20, blue: 0.10, alpha: 1),
        dark: UIColor(red: 0.45, green: 0.29, blue: 0.15, alpha: 1)
    )
    static let acornCapLight = adaptive(
        light: UIColor(red: 0.47, green: 0.30, blue: 0.15, alpha: 1),
        dark: UIColor(red: 0.58, green: 0.39, blue: 0.20, alpha: 1)
    )
    static let glass = adaptive(
        light: UIColor(red: 0.78, green: 0.90, blue: 0.90, alpha: 1),
        dark: UIColor(red: 0.43, green: 0.62, blue: 0.64, alpha: 1)
    )
    static let secondaryText = Color.primary.opacity(0.62)

    static let cardCornerRadius: CGFloat = 24
    static let horizontalPadding: CGFloat = 20

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
