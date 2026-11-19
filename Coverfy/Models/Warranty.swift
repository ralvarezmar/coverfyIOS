import Foundation
import SwiftData

@Model
final class Warranty {
    var productName: String
    var store: String
    var purchaseDate: Date
    var warrantyMonths: Int
    var expiryDate: Date
    var receiptImagePath: String?
    var receiptText: String?
    var notes: String
    var category: String

    init(
        productName: String,
        store: String = "",
        purchaseDate: Date = .now,
        warrantyMonths: Int = 24,
        receiptImagePath: String? = nil,
        receiptText: String? = nil,
        notes: String = "",
        category: String = "General"
    ) {
        self.productName = productName
        self.store = store
        self.purchaseDate = purchaseDate
        self.warrantyMonths = warrantyMonths
        self.expiryDate = Calendar.current.date(
            byAdding: .month, value: warrantyMonths, to: purchaseDate
        ) ?? purchaseDate
        self.receiptImagePath = receiptImagePath
        self.receiptText = receiptText
        self.notes = notes
        self.category = category
    }

    var daysUntilExpiry: Int {
        Calendar.current.dateComponents(
            [.day], from: Calendar.current.startOfDay(for: .now),
            to: Calendar.current.startOfDay(for: expiryDate)
        ).day ?? 0
    }

    var isExpired: Bool { daysUntilExpiry < 0 }
}
