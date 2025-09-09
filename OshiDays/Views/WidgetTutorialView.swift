import SwiftUI

struct WidgetTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("Add a Widget to Home", comment: "")).font(.headline)
                            StepRow(index: 1, text: NSLocalizedString("Long‑press empty area on Home, tap the + button.", comment: ""), symbol: "plus.circle")
                            StepRow(index: 2, text: NSLocalizedString("Search and select OshiDays (推し待ち).", comment: ""), symbol: "magnifyingglass")
                            StepRow(index: 3, text: NSLocalizedString("Choose Photo Card or List, pick a size, then Add Widget.", comment: ""), symbol: "square.grid.2x2")
                            StepRow(index: 4, text: NSLocalizedString("Tap the widget to edit the event.", comment: ""), symbol: "hand.tap")
                        }
                    }
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("Tips", comment: "")).font(.headline)
                            Text(NSLocalizedString("Photos show on Photo Card with Pro. Free shows color band.", comment: ""))
                            Text(NSLocalizedString("If it doesn't refresh, re‑add or resize the widget.", comment: ""))
                        }
                    }
                    if let url = URL(string: "https://nekomura0728.github.io/Oshidays/") {
                        Link(NSLocalizedString("Open Help Page", comment: ""), destination: url)
                            .buttonStyle(.bordered)
                    }
                }
                .padding(16)
            }
            .navigationTitle(NSLocalizedString("Widget Tutorial", comment: ""))
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(NSLocalizedString("Close", comment: "")) { dismiss() } } }
        }
    }
}

private struct StepRow: View {
    let index: Int
    let text: String
    let symbol: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.15)).frame(width: 26, height: 26)
                Text("\(index)").font(.footnote).bold()
            }
            Image(systemName: symbol).frame(width: 18)
            Text(text)
            Spacer(minLength: 0)
        }
    }
}

