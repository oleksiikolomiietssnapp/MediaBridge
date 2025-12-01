//
//  MediaBridgeSampleApp.swift
//  MediaBridgeSample
//
//  Created by Oleksii Kolomiiets on 11/16/25.
//

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
    @Entry var library: MusicLibrary = MusicLibrary(
        auth: AuthorizationManager()
    )
}
