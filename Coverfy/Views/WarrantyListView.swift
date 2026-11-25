import SwiftUI
import SwiftData
import UIKit

struct WarrantyListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Warranty.expiryDate) private var warranties: [Warranty]
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if warranties.isEmpty {
                    ContentUnavailableView(
                        "Sin garantías",
                        systemImage: "doc.text.viewfinder",
                        description: Text("Pulsa + para escanear tu primer ticket.")
                    )
                } else {
                    List(warranties) { warranty in
                        NavigationLink(value: warranty) {
                            WarrantyRow(warranty: warranty)
                        }
                        .listRowBackground(
                            warranty.isExpired ? Color.red.opacity(0.12)
                            : warranty.daysUntilExpiry <= 30 ? Color.coverfyOrange.opacity(0.15)
                            : Color.clear
                        )
                    }
                }
            }
            .navigationTitle("Coverfy")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Warranty.self) { warranty in
                WarrantyDetailView(warranty: warranty)
            }
            .sheet(isPresented: $showAdd) {
                AddWarrantyView()
            }
        }
    }
}

private struct WarrantyRow: View {
    let warranty: Warranty

    var body: some View {
        HStack(spacing: 12) {
            if let url = warranty.productURL, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "shippingbox.fill")
                    .font(.title2)
                    .foregroundStyle(Color.coverfyBlue)
                    .frame(width: 48, height: 48)
                    .background(Color.coverfyBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(warranty.productName).font(.headline)
                if !warranty.store.isEmpty {
                    Text(warranty.store).font(.caption).foregroundStyle(.secondary)
                }
                Text("Caduca: \(warranty.expiryDate, format: .dateTime.day().month().year())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if warranty.isExpired {
                Label("Caducada", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            } else {
                Text("\(warranty.daysUntilExpiry)d")
                    .foregroundStyle(warranty.daysUntilExpiry <= 30 ? .orange : .secondary)
            }
        }
    }
}
