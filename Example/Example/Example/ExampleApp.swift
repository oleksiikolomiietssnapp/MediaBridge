//
//  ExampleApp.swift
//  Example
//
//  Created by Oleksii Kolomiiets on 11/16/25.
//

import MediaBridge
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension EnvironmentValues {
    @Entry var library: MusicLibrary = MusicLibrary(
        auth: AuthorizationManager(),
        cache: .empty()
    )
}
