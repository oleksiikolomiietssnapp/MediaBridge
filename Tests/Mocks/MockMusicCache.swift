@testable import MediaBridge

final class MockMusicCache: MusicCacheProtocol {
    
}

extension MusicCacheProtocol where Self == MockMusicCache {
    static var mock: MockMusicCache {
        MockMusicCache()
    }
}
