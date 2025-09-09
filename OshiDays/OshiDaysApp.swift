import SwiftUI

@main
struct OshiDaysApp: App {
    @StateObject private var store = DataStore.shared
    @StateObject private var purchase = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchase)
                .task { await purchase.loadProducts() }
        }
    }
}

