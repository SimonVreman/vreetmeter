
import SwiftUI

extension GroupBox {
    @inlinable public func cardBackgroundAndShadow() -> some View {
        return self.backgroundStyle(.background.secondary)
            .compositingGroup()
            .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

extension ProgressView {
    @inlinable public func centered() -> some View {
        return self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
