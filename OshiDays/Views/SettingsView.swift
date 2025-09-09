import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var purchase: PurchaseManager

    var body: some View {
        NavigationStack {
            Form {
                Section("Status") {
                    HStack { Text("Events"); Spacer(); Text("\(store.allEvents().count)") }
                    HStack { Text("Oshi"); Spacer(); Text("\(store.allOshis().count)") }
                    HStack { Text("Pro"); Spacer(); Text(purchase.isProUnlocked ? "Unlocked" : "Free") }
                }
                Section("Pro") {
                    if purchase.isProUnlocked {
                        Label("Thanks for supporting!", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                    } else {
                        Button(action: { Task { await purchase.purchasePro() } }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Upgrade to Pro")
                                    Text("Photos on widgets + unlimited events").font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("¥500").bold()
                            }
                        }
                        Button("Restore Purchases") { Task { await purchase.restore() } }
                    }
                }
                Section("Notifications") {
                    Button("Request Permission") { Task { _ = await NotificationManager.requestAuthorization() } }
                }
                Section("About") {
                    Text("Bundle: \(AppConstants.bundleId)")
                }
                Section("Legal") {
                    if let termsURL = URL(string: "https://nekomura0728.github.io/Oshidays/terms.html"),
                       let privacyURL = URL(string: "https://nekomura0728.github.io/Oshidays/privacy.html") {
                        Link(NSLocalizedString("Terms of Service", comment: ""), destination: termsURL)
                        Link(NSLocalizedString("Privacy Policy", comment: ""), destination: privacyURL)
                    }
                }
                #if DEBUG
                Section("Debug") {
                    Toggle("Force Pro (Debug)", isOn: Binding(get: {
                        purchase.proOverride
                    }, set: { v in
                        purchase.setProOverride(v)
                    }))
                    Picker("Widget Demo Image", selection: Binding(get: {
                        UserDefaults(suiteName: AppConstants.appGroupId)?.integer(forKey: "debug_widget_image_index") ?? 0
                    }, set: { v in
                        let d = UserDefaults(suiteName: AppConstants.appGroupId)
                        d?.set(v, forKey: "debug_widget_image_index")
                        WidgetCenter.shared.reloadAllTimelines()
                    })) {
                        Text("None").tag(0)
                        Text("image1.png").tag(1)
                        Text("image2.png").tag(2)
                    }
                    Button("Import demo images to App Group") {
                        importDemoImages()
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
        }
    }
}

#if DEBUG
private func importDemoImages() {
    #if canImport(UIKit)
    if let img1 = UIImage(contentsOfFile: AppConstants.debugImagePath1) {
        ImageStore.save(image: img1, id: "demo1")
    }
    if let img2 = UIImage(contentsOfFile: AppConstants.debugImagePath2) {
        ImageStore.save(image: img2, id: "demo2")
    }
    WidgetCenter.shared.reloadAllTimelines()
    #endif
}
#endif
