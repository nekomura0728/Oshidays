import SwiftUI

struct OshiEditView: View {
    enum Mode { case create, edit(Oshi) }
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    let onCommit: (Oshi) -> Void

    @State private var name: String = ""
    @State private var color: Color = .pink

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Name", text: $name)
                    ColorPicker("Color", selection: $color, supportsOpacity: false)
                }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty) }
            }
            .onAppear(perform: loadIfNeeded)
        }
    }

    private var modeTitle: String { switch mode { case .create: return "New Oshi"; case .edit: return "Edit Oshi" } }

    private func loadIfNeeded() {
        if case .edit(let o) = mode {
            name = o.name
            color = o.color
        }
    }

    private func save() {
        var oshi = Oshi(id: currentID, name: name, colorHex: color.toHex() ?? "#FF2D55", logoImageID: nil, tags: [])
        onCommit(oshi)
        dismiss()
    }

    private var currentID: UUID {
        if case .edit(let o) = mode { return o.id } else { return UUID() }
    }
}

