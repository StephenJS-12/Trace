//
//  Theme.swift
//  Trace
//
//  Design system: Dark theme with neon green accents
//

import SwiftUI

// MARK: - App Colors
extension Color {
    static let traceBackground = Color(red: 0.07, green: 0.07, blue: 0.09)
    static let traceCard = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let traceCardLight = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let traceAccent = Color(red: 0.76, green: 1.0, blue: 0.0) // Neon lime green
    static let traceAccentDim = Color(red: 0.76, green: 1.0, blue: 0.0).opacity(0.2)
    static let traceTextPrimary = Color.white
    static let traceTextSecondary = Color(white: 0.6)
    static let traceTextTertiary = Color(white: 0.4)
    static let traceRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let traceOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let traceBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    static let tracePurple = Color(red: 0.6, green: 0.3, blue: 1.0)
}

// MARK: - Reusable Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.traceCard)
            .cornerRadius(16)
    }
}

struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.traceAccent)
            .cornerRadius(14)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.traceAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.traceAccent.opacity(0.15))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.traceAccent.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
