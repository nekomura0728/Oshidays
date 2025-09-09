import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DataStore
    @State private var deepLinkEditEvent: Event?

    var body: some View {
        TabView {
            EventListView()
                .tabItem { Label("Events", systemImage: "calendar") }
            OshiListView()
                .tabItem { Label("Oshi", systemImage: "heart.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .onOpenURL { url in
            guard url.scheme == "oshidays" else { return }
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if url.host == "edit",
               let idStr = comps?.queryItems?.first(where: { $0.name == "eventId" })?.value,
               let uuid = UUID(uuidString: idStr),
               let ev = store.allEvents().first(where: { $0.id == uuid }) {
                deepLinkEditEvent = ev
            }
        }
        .sheet(item: $deepLinkEditEvent) { ev in
            EventEditView(mode: .edit(ev)) { updated in
                store.upsert(event: updated)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView() }
}
