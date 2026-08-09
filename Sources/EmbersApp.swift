import SwiftUI

@main
struct EmbersApp: App {
    @StateObject private var store = ArticleStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}