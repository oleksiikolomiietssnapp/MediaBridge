import MediaBridge
import MediaPlayer
import SwiftUI

struct ContentView: View {
    @Environment(\.library) var library
    @State var songs: [MPMediaItem] = []
    @State var filteredSongs: [MPMediaItem] = []
    @State var order: SortOrder = .forward
    @State var isOrderEnabled: Bool = true
    var body: some View {
        NavigationStack {
            VStack {
                if !filteredSongs.isEmpty {
                    List(filteredSongs, id: \.persistentID) { song in
                        HStack {
                            if let uiImage = song.artwork?.image(at: CGSize(width: 24, height: 24)) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            } else {
                                ProgressView().tint(Color.orange)
                            }
                            Text(song.title ?? "Unknown")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(song.skipCount, format: .number)
                        }
                    }
                } else {
                    ProgressView().tint(Color.green)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isOrderEnabled = false
                        order.toggle()
                        Task {
                            filteredSongs = try await fetchSkippedSongs(order: order)
                            isOrderEnabled = true
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .disabled(!isOrderEnabled)
                }
            }
        }
        .task {
            do {
                filteredSongs = try await fetchSkippedSongs(order: order)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func fetchSkippedSongs(order: SortOrder) async throws -> [MPMediaItem] {
        try await library.fetchSongs(sortedBy: \MPMediaItem.skipCount, order: order)
    }
}

extension SortOrder {
    mutating func toggle() {
        self = self == .forward ? .reverse : .forward
    }
}
