//
//  ContentView.swift
//  Example
//
//  Created by Oleksii Kolomiiets on 11/16/25.
//

import SwiftUI
import MediaBridge
import MediaPlayer

struct ContentView: View {
    @Environment(\.library) var library
    @State var songs: [MPMediaItem] = []
    var body: some View {
        Text(songs.count, format: .number)
            .font(.largeTitle)
            .task {
                do {
                    let songs = try await library.fetchSongs()
                    self.songs = songs
                    print("Fetched: ", songs.count, "songs.")
                } catch {
                    print(error.localizedDescription)
                }
            }
    }
}

#Preview {
    ContentView()
}
