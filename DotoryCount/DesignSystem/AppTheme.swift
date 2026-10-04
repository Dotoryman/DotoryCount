import SwiftUI
import UIKit

enum AppTheme {
    static let background = adaptive(
        light: UIColor(red: 0.982, green: 0.971, blue: 0.947, alpha: 1),
        dark: UIColor(red: 0.105, green: 0.094, blue: 0.081, alpha: 1)
    )
    static let surface = adaptive(
        light: UIColor(red: 1, green: 0.992, blue: 0.977, alpha: 1),
        dark: UIColor(red: 0.17, green: 0.151, blue: 0.125, alpha: 1)
    )
    static let accent = adaptive(
        light: UIColor(red: 0.37, green: 0.25, blue: 0.16, alpha: 1),
        dark: UIColor(red: 0.89, green: 0.73, blue: 0.53, alpha: 1)
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
    static let ink = adaptive(
        light: UIColor(red: 0.24, green: 0.20, blue: 0.16, alpha: 1),
        dark: UIColor(red: 0.95, green: 0.91, blue: 0.85, alpha: 1)
    )
    static let secondaryText = adaptive(
        light: UIColor(red: 0.49, green: 0.44, blue: 0.38, alpha: 1),
        dark: UIColor(red: 0.71, green: 0.66, blue: 0.58, alpha: 1)
    )
    static let divider = ink.opacity(0.10)
    static let gold = Color(red: 0.67, green: 0.47, blue: 0.19)

    static let cardCornerRadius: CGFloat = 24
    static let horizontalPadding: CGFloat = 26

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
