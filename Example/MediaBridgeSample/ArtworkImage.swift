import MediaPlayer
import SwiftUI

struct ArtworkImage: View {
    let song: MPMediaItem
    let size: CGFloat = 44

    var body: some View {
        if let uiImage = song.artwork?.image(at: CGSize(width: size, height: size)) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "music.note")
                        .foregroundStyle(.tertiary)
                }
        }
    }
}
