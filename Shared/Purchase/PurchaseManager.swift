import Foundation
import StoreKit
import WidgetKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isProUnlocked: Bool = false
    @Published var products: [Product] = []
    @Published var proOverride: Bool = false // Debug/testing toggle

    private let groupDefaults = UserDefaults(suiteName: AppConstants.appGroupId)

    private init() {
        proOverride = groupDefaults?.bool(forKey: Keys.proOverride) ?? false
        Task { await updatePurchasedStatus() }
    }

    private enum Keys {
        static let proOverride = "pro_override"
        static let proUnlocked = "pro_unlocked"
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [AppConstants.proProductId])
        } catch {
            print("[Purchase] load error: \(error)")
        }
    }

    func purchasePro() async {
        do {
            guard let product = products.first(where: { $0.id == AppConstants.proProductId }) else { return }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedStatus()
                WidgetCenter.shared.reloadAllTimelines()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("[Purchase] purchase error: \(error)")
        }
    }

    func restore() async {
        do { try await AppStore.sync() } catch { print("[Purchase] restore error: \(error)") }
        await updatePurchasedStatus()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updatePurchasedStatus() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == AppConstants.proProductId {
                unlocked = true
                break
            }
        }
        // Debug/testing override
        if groupDefaults?.bool(forKey: Keys.proOverride) == true { unlocked = true }
        isProUnlocked = unlocked
        groupDefaults?.set(unlocked, forKey: Keys.proUnlocked)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(domain: "Purchase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unverified transaction"])
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Debug helpers
extension PurchaseManager {
    func setProOverride(_ enabled: Bool) {
        groupDefaults?.set(enabled, forKey: Keys.proOverride)
        proOverride = enabled
        Task { await updatePurchasedStatus() }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
