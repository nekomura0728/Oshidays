import SwiftUI

// Safe helper to disable content margins on iOS 17+ without breaking older SDKs
extension View {
    @ViewBuilder
    func contentMarginsDisabledIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            self.contentMarginsDisabled()
        } else {
            self
        }
    }
}

