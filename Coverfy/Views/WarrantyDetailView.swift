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
    @State private var showShare = false

    private var statusColor: Color {
        if warranty.isExpired { return .red }
        if warranty.daysUntilExpiry <= 30 { return .coverfyOrange }
        return .coverfyTeal
    }

    private var progress: Double {
        let total = warranty.expiryDate.timeIntervalSince(warranty.purchaseDate)
        guard total > 0 else { return 1 }
        return min(max(Date.now.timeIntervalSince(warranty.purchaseDate) / total, 0), 1)
    }

    private var receiptImage: UIImage? {
        warranty.receiptURL.flatMap { UIImage(contentsOfFile: $0.path) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let url = warranty.productURL, let image = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                statusCard
                infoCard

                if !warranty.notes.isEmpty {
                    card {
                        Label("Notas", systemImage: "note.text")
                            .font(.headline).foregroundStyle(Color.coverfyPurple)
                        Text(warranty.notes)
                    }
                }

                if let image = receiptImage {
                    card {
                        Label("Ticket", systemImage: "receipt")
                            .font(.headline).foregroundStyle(Color.coverfyBlue)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                Button {
                    showClaimSheet = true
                } label: {
                    Label("Preparar reclamación", systemImage: "doc.plaintext")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.coverfyBlue)
                .controlSize(.large)

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Eliminar garantía", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(warranty.productName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.coverfyBlue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showClaimSheet) { claimSheet }
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

    private var statusCard: some View {
        card {
            HStack {
                Image(systemName: warranty.isExpired ? "xmark.shield.fill" : "checkmark.shield.fill")
                    .font(.largeTitle)
                    .foregroundStyle(statusColor)
                VStack(alignment: .leading) {
                    Text(warranty.isExpired
                         ? "Garantía caducada"
                         : "Quedan \(warranty.daysUntilExpiry) días")
                        .font(.title3.bold())
                        .foregroundStyle(statusColor)
                    Text("Caduca el \(warranty.expiryDate.formatted(date: .long, time: .omitted))")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }
            ProgressView(value: progress).tint(statusColor)
        }
        .background(statusColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }

    private var infoCard: some View {
        card {
            infoRow("shippingbox.fill", "Producto", warranty.productName, .coverfyBlue)
            if !warranty.store.isEmpty {
                infoRow("storefront.fill", "Tienda", warranty.store, .coverfyTeal)
            }
            infoRow("tag.fill", "Categoría", warranty.category, .coverfyPurple)
            infoRow("calendar", "Fecha de compra",
                    warranty.purchaseDate.formatted(date: .long, time: .omitted), .coverfyOrange)
            infoRow("clock.fill", "Garantía", "\(warranty.warrantyMonths) meses", .coverfyBlue)
        }
    }

    private func infoRow(_ icon: String, _ label: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(color, in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading) {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.body)
            }
            Spacer()
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var claimSheet: some View {
        NavigationStack {
            Form {
                if let claimText {
                    Section("Reclamación generada") {
                        Text(claimText).font(.caption)
                        Button {
                            showShare = true
                        } label: {
                            Label(receiptImage == nil ? "Compartir" : "Compartir con foto del ticket",
                                  systemImage: "square.and.arrow.up")
                        }
                        Button("Editar avería") { self.claimText = nil }
                    }
                } else {
                    Section("Describe la avería") {
                        TextEditor(text: $defect).frame(minHeight: 100)
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
            .sheet(isPresented: $showShare) {
                ActivityView(items: [claimText ?? ""] + (receiptImage.map { [$0] } ?? []))
            }
        }
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
