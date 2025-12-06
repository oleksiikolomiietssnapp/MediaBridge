import MediaBridge
import MediaPlayer
import SwiftUI

struct ContentView: View {
    @Environment(\.library) var library
    @State private var songs: [MPMediaItem] = []
    @State private var order: SortOrder = .forward
    @State private var isLoading = false
    @State private var showError: Bool = false
    @State private var errorMessage: Error?

    var body: some View {
        NavigationStack {
            ZStack {
                if songs.isEmpty && !isLoading {
                    ContentUnavailableView("No Songs", systemImage: "music.note")
                } else {
                    List(songs, id: \.persistentID) { song in
                        SongRow(song: song)
                    }
                }

                if isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Skipped Songs")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: toggleSort) {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage?.localizedDescription ?? "Unknown error")
            }
        }
        .task {
            await loadSongs()
        }
    }

    private func toggleSort() {
        order.toggle()
        Task {
            await loadSongs()
        }
    }

    private func loadSongs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            songs = try await library.songs(sortedBy: \MPMediaItem.skipCount, order: order)
            errorMessage = nil
        } catch {
            errorMessage = error
            showError = true
        }
    }
}

extension SortOrder {
    mutating func toggle() {
        self = self == .forward ? .reverse : .forward
    }
}

#Preview {
    ContentView()
        .environment(\.library, .accessDenied)
}
