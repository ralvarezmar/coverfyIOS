import SwiftUI
import SwiftData
import UIKit

struct AddWarrantyView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var productName = ""
    @State private var store = ""
    @State private var purchaseDate = Date()
    @State private var warrantyMonths = 24
    @State private var notes = ""

    @State private var showCamera = false
    @State private var showProductCamera = false
    @State private var productImage: UIImage?
    @State private var scanning = false
    @State private var receiptImage: UIImage?
    @State private var parsedReceipt: ReceiptParser.ParsedReceipt?

    var body: some View {
        NavigationStack {
            Form {
                Section("Ticket") {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Escanear ticket", systemImage: "camera")
                    }
                    if scanning {
                        HStack {
                            ProgressView()
                            Text("Leyendo ticket…")
                        }
                    }
                    if let image = receiptImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                }

                Section("Foto del producto") {
                    Button {
                        showProductCamera = true
                    } label: {
                        Label(productImage == nil ? "Añadir foto del producto" : "Cambiar foto",
                              systemImage: "camera.on.rectangle")
                    }
                    if let image = productImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Section("Producto") {
                    TextField("Producto *", text: $productName)
                    TextField("Tienda", text: $store)
                    DatePicker("Fecha de compra", selection: $purchaseDate, displayedComponents: .date)
                    Stepper("Garantía: \(warrantyMonths) meses", value: $warrantyMonths, in: 1...120)
                }

                Section("Notas") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Nueva garantía")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(productName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    receiptImage = image
                    scan(image)
                }
            }
            .sheet(isPresented: $showProductCamera) {
                CameraView { image in productImage = image }
            }
        }
    }

    private func scan(_ image: UIImage) {
        scanning = true
        Task {
            defer { scanning = false }
            guard let parsed = try? await ReceiptScanner.scan(image) else { return }
            parsedReceipt = parsed
            if store.isEmpty, let s = parsed.store { store = s }
            if let d = parsed.purchaseDate { purchaseDate = d }
        }
    }

    private func store(_ image: UIImage?, prefix: String) -> String? {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let name = "\(prefix)_\(UUID().uuidString).jpg"
        let url = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        )[0].appendingPathComponent(name)
        try? data.write(to: url)
        return name
    }

    private func save() {
        let imagePath = store(receiptImage, prefix: "receipt")
        let productPath = store(productImage, prefix: "product")

        let warranty = Warranty(
            productName: productName.trimmingCharacters(in: .whitespaces),
            store: store.trimmingCharacters(in: .whitespaces),
            purchaseDate: purchaseDate,
            warrantyMonths: warrantyMonths,
            receiptImagePath: imagePath,
            productImagePath: productPath,
            receiptText: parsedReceipt?.rawText,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(warranty)
        ExpiryNotifier.scheduleAlerts(for: warranty)
        dismiss()
    }
}
