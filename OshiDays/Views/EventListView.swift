import SwiftUI

struct EventListView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var purchase: PurchaseManager
    @State private var showingAdd = false
    @State private var editEvent: Event?
    @State private var showPaywall = false
    @State private var showWidgetTutorial = false

    var body: some View {
        NavigationStack {
            List {
                if store.allEvents().isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No Events",
                            systemImage: "calendar.badge.plus",
                            description: Text("Add your first live/release.")
                        )
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No Events").font(.headline)
                            Text("Add your first live/release.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    ForEach(store.allEvents().sorted(by: { $0.startAt < $1.startAt })) { event in
                        Button {
                            editEvent = event
                        } label: {
                            EventRow(event: event, oshi: store.allOshis().first { $0.id == event.oshiID })
                        }
                    }
                    .onDelete { idx in
                        let events = store.allEvents().sorted(by: { $0.startAt < $1.startAt })
                        for i in idx {
                            let id = events[i].id
                            store.deleteEvent(id: id)
                            NotificationManager.cancel(for: id)
                        }
                    }
                }
                Section {
                    Button {
                        showWidgetTutorial = true
                    } label: {
                        Label(NSLocalizedString("How to Add Widget", comment: ""), systemImage: "square.grid.2x2")
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarItems(trailing: addButton)
            .sheet(isPresented: $showingAdd) {
                EventEditView(mode: .create) { new in
                    store.upsert(event: new)
                    Task { await NotificationManager.schedule(for: new) }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $editEvent) { event in
                EventEditView(mode: .edit(event)) { updated in
                    store.upsert(event: updated)
                    NotificationManager.cancel(for: updated.id)
                    Task { await NotificationManager.schedule(for: updated) }
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showWidgetTutorial) { WidgetTutorialView() }
        }
    }

    private var addButton: some View {
        let overQuota = store.allEvents().count >= AppConstants.freeQuota && !purchase.isProUnlocked
        return Button {
            if overQuota { showingPaywall() } else { showingAdd = true }
        } label: { Image(systemName: "plus") }
        .disabled(false)
    }

    private func showingPaywall() { showPaywall = true }
}

private struct EventRow: View {
    let event: Event
    let oshi: Oshi?
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill((oshi?.color ?? .accentColor).opacity(0.2))
                .overlay(Text(String(event.title.prefix(1))).font(.headline))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(event.title).font(.headline)
                Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(remainingTextApp(to: event.startAt))
                .monospacedDigit()
                .font(.headline)
        }
    }
}

private func remainingTextApp(to date: Date) -> String {
    let cal = Calendar.current
    let start = cal.startOfDay(for: Date())
    let dest = cal.startOfDay(for: date)
    let pref = Locale.preferredLanguages.first ?? Locale.current.identifier
    let isJa = pref.hasPrefix("ja")
    if let days = cal.dateComponents([.day], from: start, to: dest).day {
        if days > 0 { return isJa ? "あと\(days)日" : (days == 1 ? "in 1 day" : "in \(days) days") }
        if days == 0 { return isJa ? "今日" : "today" }
        let n = -days
        return isJa ? "\(n)日前" : (n == 1 ? "1 day ago" : "\(n) days ago")
    }
    return ""
}
