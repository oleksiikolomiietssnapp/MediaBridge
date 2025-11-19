@testable import MediaBridge

final class MockMusicCache: MusicCacheProtocol {
    var songs: [String]

    init(songs: [String] = []) {
        self.songs = songs
    }
}

extension MusicCacheProtocol where Self == MockMusicCache {
    static var mock: MockMusicCache {
        MockMusicCache()
    }
}
