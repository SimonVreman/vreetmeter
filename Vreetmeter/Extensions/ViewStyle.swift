
import SwiftUI

struct AdaptiveBackgroundStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            return AnyView(content.backgroundStyle(.background))
        } else {
            return AnyView(content.backgroundStyle(.windowBackground))
        }
    }
}

extension GroupBox {
    public func cardBackgroundAndShadow() -> some View {
        return self.modifier(AdaptiveBackgroundStyleModifier())
            .compositingGroup()
            .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

extension ProgressView {
    @inlinable public func centered() -> some View {
        return self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
