import Foundation

public protocol MusicCacheProtocol {
    var songs: [String] { get set }
}

public class MusicCache: MusicCacheProtocol {
    public var songs: [String]
    public init() {
        // extract songs from cace storage
        songs = []
    }
}


extension MusicCacheProtocol where Self == MusicCache {
    public static func empty() -> MusicCache {
        MusicCache()
    }
}
