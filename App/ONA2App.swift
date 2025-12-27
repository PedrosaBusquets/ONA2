import SwiftUI

@main
struct ONA2App: App {
    @StateObject private var appVM = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appVM)
        }
    }
}