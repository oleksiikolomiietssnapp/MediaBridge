import MediaPlayer
import SwiftUI

struct SongRow: View {
    let song: MPMediaItem

    var body: some View {
        HStack(spacing: 12) {
            ArtworkImage(song: song)

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title ?? "Unknown")
                    .font(.body)
                    .lineLimit(1)

                if let artist = song.artist {
                    Text(artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(song.skipCount, format: .number)
                    .font(.headline)
                    .monospacedDigit()

                Text("skips")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
