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
            ProductThumbnail(url: warranty.productURL)
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

/// Square, downscaled product picture for list rows, with the generic icon as fallback.
struct ProductThumbnail: View {
    let url: URL?
    var side: CGFloat = 48
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.coverfyBlue.opacity(0.12)
            if let image {
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "shippingbox.fill")
                    .font(.title2)
                    .foregroundStyle(Color.coverfyBlue)
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task(id: url) {
            let target = side * 3
            image = await Task.detached { Self.thumbnail(at: url, side: target) }.value
        }
    }

    /// Decodes the stored photo and redraws it as an aspect-filled square, applying EXIF orientation.
    static func thumbnail(at url: URL?, side: CGFloat) -> UIImage? {
        guard let url, let source = UIImage(contentsOfFile: url.path),
              source.size.width > 0, source.size.height > 0 else { return nil }
        let scale = max(side / source.size.width, side / source.size.height)
        let drawn = CGSize(width: source.size.width * scale, height: source.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { _ in
            source.draw(in: CGRect(x: (side - drawn.width) / 2, y: (side - drawn.height) / 2,
                                   width: drawn.width, height: drawn.height))
        }
    }
}
