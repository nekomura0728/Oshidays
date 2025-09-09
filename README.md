# OshiDays / 推し待ち

推し活に特化した「次の現場/発売」が見えるウィジェットアプリ。App 本体 + Widget Extension を前提に、SwiftUI/WidgetKit/StoreKit2 の雛形コードを配置しています。

- Bundle ID: `com.lizaria.oshidays`
- App Group (想定): `group.com.lizaria.oshidays`
- Pro解放（買い切り）Product ID: `com.lizaria.oshidays.pro`
- 価格: ¥500（App Store Connect で価格帯を設定）

## 使い方（Xcode プロジェクト作成）
1) Xcodeで iOS App（SwiftUI）プロジェクトを新規作成し、Bundle ID を `com.lizaria.oshidays` に設定。
2) Widget Extension を追加（名前例: `OshiDaysWidget`）。
3) Capabilities 設定:
   - App/Widget ともに App Groups を有効化し、`group.com.lizaria.oshidays` を追加。
   - In‑App Purchases を App ターゲットで有効化。
   - Push/Background は不要（v1）
4) このリポジトリの `Shared/` を App と Widget バンドルに追加。`OshiDays/` は App ターゲット、`OshiDaysWidget/` は Widget ターゲットに追加。
5) ローカライズ: `Resources/*` を App ターゲットに追加（`InfoPlist.strings`の表示名で ja=「推し待ち」, Base=「OshiDays」）。
6) ビルド。初回起動時に通知許可ダイアログ、課金のスタブが動作します。

## 実装範囲（雛形）
- データモデル/保存: Codable JSON + App Group 共有（`Shared/Storage/DataStore.swift`）
- 画像保存: App Group 内に保存・読み出し（`Shared/Storage/ImageStore.swift`）
- 購入管理: StoreKit2 の骨子（`Shared/Purchase/PurchaseManager.swift`）
- 通知: 権限・スケジュール骨子（`Shared/Notifications/NotificationManager.swift`）
- 画面: 一覧/編集/推し管理/設定（`OshiDays/Views/*`）
- Widget: Photo Card / List の2テンプレ（`OshiDaysWidget/*`）

## 次の作業候補
- Widget テンプレを4種に拡張（Ring/List 追加）
- AppIntents（ウィジェットから編集へ/操作）
- 通知のフェーズ自動再スケジュール
- 課金UI/非プロ上限3件のUX磨き
- ASO向けテーマ/スクショ自動化
