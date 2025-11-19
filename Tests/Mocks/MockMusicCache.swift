import MediaPlayer

@testable import MediaBridge

final class MockMusicCache: MusicCacheProtocol {
    func fetchSongs() async throws -> [MPMediaItem] {
        []
    }
}

extension MusicCacheProtocol where Self == MockMusicCache {
    static var mock: MockMusicCache {
        MockMusicCache()
    }
}
