//
//  ContentView.swift
//  MediaBridgeSample
//
//  Created by Oleksii Kolomiiets on 11/16/25.
//

import MediaBridge
import MediaPlayer
import SwiftUI

struct ContentView: View {
    @Environment(\.library) var library
    @State var songs: [MPMediaItem] = []
    @State var filteredSongs: [MPMediaItem] = []
    var body: some View {
        VStack {
            if songs.count == 0 {
                ProgressView().tint(Color.red)
            } else {
                Text(songs.count, format: .number)
                    .font(.largeTitle)
            }

            if !filteredSongs.isEmpty {
                List(filteredSongs, id: \.persistentID) { song in
                    if let uiImage = song.artwork?.image(at: CGSize(width: 64, height: 64)) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 200, height: 200)
                    } else {
                        ProgressView().tint(Color.orange)
                    }
                }
            } else {
                ProgressView().tint(Color.green)
            }
        }
        .task {
            do {
                let date = Date()
                filteredSongs = try await library.fetchSong(with: .title("Time"), comparisonType: .contains)
                let songs = try await library.fetchSongs()
                self.songs = songs
                print("Fetched songs in \(DateInterval(start: date, end: .now).duration)")
                print("Fetched: ", songs.count, "songs.")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
