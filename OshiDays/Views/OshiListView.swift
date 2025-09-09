import SwiftUI

struct OshiListView: View {
    @EnvironmentObject private var store: DataStore
    @State private var showingAdd = false
    @State private var editOshi: Oshi?

    var body: some View {
        NavigationStack {
            List {
                if store.allOshis().isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No Oshi",
                            systemImage: "heart.slash",
                            description: Text("Add your first artist/idol")
                        )
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "heart.slash")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No Oshi").font(.headline)
                            Text("Add your first artist/idol")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    ForEach(store.allOshis()) { o in
                        Button { editOshi = o } label: {
                            HStack {
                                Circle().fill(o.color.opacity(0.2)).frame(width: 28, height: 28)
                                Text(o.name).font(.headline)
                                Spacer()
                                let count = store.allEvents().filter { $0.oshiID == o.id }.count
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { idx in
                        let arr = store.allOshis()
                        for i in idx { store.deleteOshi(id: arr[i].id) }
                    }
                }
            }
            .navigationTitle("Oshi")
            .navigationBarItems(trailing:
                Button(action: { showingAdd = true }) { Image(systemName: "plus") }
            )
            .sheet(isPresented: $showingAdd) {
                OshiEditView(mode: .create) { store.upsert(oshi: $0) }
                    .presentationDetents([.medium])
            }
            .sheet(item: $editOshi) { oshi in
                OshiEditView(mode: .edit(oshi)) { store.upsert(oshi: $0) }
            }
        }
    }
}
