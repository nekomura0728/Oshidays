import SwiftUI
import PhotosUI
import UIKit

struct EventEditView: View {
    enum Mode {
        case create
        case edit(Event)
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: DataStore

    let mode: Mode
    let onCommit: (Event) -> Void

    @State private var title: String = ""
    @State private var type: EventType = .live
    @State private var startAt: Date = .init()
    // End time removed (Start only)
    // Venue removed – keep only memo
    @State private var memo: String = ""
    @State private var oshiID: UUID?
    @State private var imageID: String? = nil
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $type) {
                        ForEach(EventType.allCases) { t in Text(t.displayName).tag(t) }
                    }
                    Picker("Oshi", selection: Binding(get: {
                        oshiID ?? store.allOshis().first?.id
                    }, set: { oshiID = $0 })) {
                        ForEach(store.allOshis()) { o in Text(o.name).tag(Optional.some(o.id)) }
                    }
                }
                Section("Date") {
                    DatePicker("Start", selection: $startAt, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Photo") {
                    ZStack {
                        Rectangle().fill(Color.secondary.opacity(0.08)).frame(height: 140).cornerRadius(12)
                        if let ui = pickedImage {
                            Image(uiImage: ui).resizable().scaledToFill().frame(height: 140).clipped().cornerRadius(12)
                        } else {
                            Text("No Image").foregroundStyle(.secondary)
                        }
                    }
                    HStack {
                        PhotosPicker(selection: $pickerItem, matching: .images) { Label("Choose Photo", systemImage: "photo") }
                        Spacer()
                        if imageID != nil || pickedImage != nil {
                            Button(role: .destructive) { removeImage() } label: { Label("Remove", systemImage: "trash") }
                        }
                    }
                }
                Section("Memo") { TextField("Memo", text: $memo, axis: .vertical) }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(!isValid) }
            }
            .onAppear(perform: loadIfNeeded)
            .onChange(of: pickerItem) { _ in loadPickedImage() }
        }
    }

    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && (oshiID != nil || !store.allOshis().isEmpty) }
    private var modeTitle: String { switch mode { case .create: return "New Event"; case .edit: return "Edit Event" } }

    private func loadIfNeeded() {
        if case .edit(let e) = mode {
            title = e.title
            type = e.type
            startAt = e.startAt
            memo = e.memo ?? ""
            oshiID = e.oshiID
            imageID = e.imageID
            if let id = e.imageID, let ui = ImageStore.load(id: id) { pickedImage = ui }
        } else {
            oshiID = store.allOshis().first?.id
        }
    }

    private func save() {
        var finalImageID = imageID
        if let img = pickedImage {
            // Always generate a new id to avoid widget/image cache issues, and remove old file
            if let old = finalImageID { ImageStore.delete(id: old) }
            let id = UUID().uuidString
            ImageStore.save(image: img, id: id)
            finalImageID = id
        }
        let event = Event(
            id: (modeEvent?.id ?? UUID()),
            title: title, type: type, startAt: startAt, endAt: nil,
            venue: nil,
            memo: memo.isEmpty ? nil : memo,
            imageID: finalImageID,
            oshiID: oshiID ?? store.allOshis().first?.id ?? UUID(),
            pinned: false
        )
        onCommit(event)
        dismiss()
    }

    private var modeEvent: Event? { if case .edit(let e) = mode { return e } else { return nil } }

    private func removeImage() {
        if let id = imageID { ImageStore.delete(id: id) }
        imageID = nil
        pickedImage = nil
    }
}

extension EventEditView {
    // Load picked image
    func loadPickedImage() {
        guard let item = pickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                await MainActor.run {
                    pickedImage = img
                }
            }
        }
    }
}
