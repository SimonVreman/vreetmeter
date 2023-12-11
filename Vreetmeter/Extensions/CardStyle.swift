
import SwiftUI

extension View {
    @inlinable public func cardBackgroundAndShadow() -> some View {
        return self.backgroundStyle(.background.secondary)
            .compositingGroup()
            .shadow(color: .black.opacity(0.1), radius: 10)
    }
}
