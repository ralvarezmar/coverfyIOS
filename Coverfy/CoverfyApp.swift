import SwiftUI
import SwiftData

@main
struct CoverfyApp: App {
    var body: some Scene {
        WindowGroup {
            WarrantyListView()
                .task {
                    await ExpiryNotifier.requestAuthorization()
                }
        }
        .modelContainer(for: Warranty.self)
    }
}
