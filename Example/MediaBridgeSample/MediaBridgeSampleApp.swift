import MediaBridge
import SwiftUI

@main
struct MediaBridgeSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension EnvironmentValues {
    @Entry var library: MusicLibraryProtocol = MusicLibrary()
}
