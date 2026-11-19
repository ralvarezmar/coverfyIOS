import SwiftUI
import SwiftData
import UIKit

struct WarrantyDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let warranty: Warranty

    @State private var showClaimSheet = false
    @State private var defect = ""
    @State private var claimText: String?
    @State private var showDeleteConfirm = false

    var body: some View {
        List {
            Section {
                LabeledContent("Producto", value: warranty.productName)
                if !warranty.store.isEmpty {
                    LabeledContent("Tienda", value: warranty.store)
                }
                LabeledContent("Compra", value: warranty.purchaseDate.formatted(date: .numeric, time: .omitted))
                LabeledContent("Garantía", value: "\(warranty.warrantyMonths) meses")
                LabeledContent("Caduca", value: warranty.expiryDate.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(warranty.isExpired ? .red : .primary)
                if !warranty.notes.isEmpty {
                    LabeledContent("Notas", value: warranty.notes)
                }
            }

            if let path = warranty.receiptImagePath,
               let image = UIImage(contentsOfFile: path) {
                Section("Ticket") {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }

            Section {
                Button {
                    showClaimSheet = true
                } label: {
                    Label("Preparar reclamación", systemImage: "doc.plaintext")
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Eliminar garantía", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Garantía")
        .sheet(isPresented: $showClaimSheet) {
            NavigationStack {
                Form {
                    if let claimText {
                        Section("Reclamación generada") {
                            Text(claimText)
                                .font(.caption)
                            ShareLink(item: claimText) {
                                Label("Compartir", systemImage: "square.and.arrow.up")
                            }
                            Button("Editar avería") { self.claimText = nil }
                        }
                    } else {
                        Section("Describe la avería") {
                            TextEditor(text: $defect)
                                .frame(minHeight: 100)
                            Button("Generar reclamación") {
                                claimText = ClaimGenerator.buildClaim(for: warranty, defect: defect)
                            }
                            .disabled(defect.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .navigationTitle("Reclamación")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cerrar") { showClaimSheet = false }
                    }
                }
            }
        }
        .confirmationDialog(
            "¿Eliminar \"\(warranty.productName)\"?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                ExpiryNotifier.cancelAlerts(for: warranty)
                context.delete(warranty)
                dismiss()
            }
        }
    }
}
