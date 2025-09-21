import SwiftUI

@main
struct WeightTrackerApp: App {
    @StateObject private var store = WeightStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
