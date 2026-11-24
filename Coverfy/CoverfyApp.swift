import SwiftUI
import SwiftData

@main
struct CoverfyApp: App {
    @AppStorage("onboardingDone") private var onboardingDone = false

    var body: some Scene {
        WindowGroup {
            if onboardingDone {
                WarrantyListView()
                    .task {
                        await ExpiryNotifier.requestAuthorization()
                    }
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: Warranty.self)
    }
}
