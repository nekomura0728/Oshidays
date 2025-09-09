import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchase: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill").font(.system(size: 56)).foregroundStyle(.pink)
                Text("OshiDays Pro").font(.title2).bold()
                Text("写真がウィジェットに表示 + イベント無制限")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    Label("ホームのPhoto Cardに写真を表示", systemImage: "photo")
                    Label("イベント無制限で追加可能", systemImage: "infinity")
                    Label("将来のテーマ/機能アップデート", systemImage: "sparkles")
                }.frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    Task { await purchase.purchasePro() }
                } label: {
                    HStack { Spacer(); Text("¥500で購入").bold(); Spacer() }
                }
                .buttonStyle(.borderedProminent)

                Button("購入を復元") { Task { await purchase.restore() } }
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Proのご案内")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("閉じる") { dismiss() } } }
        }
    }
}
