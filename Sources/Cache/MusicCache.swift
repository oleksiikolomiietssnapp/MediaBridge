import Foundation

public protocol MusicCacheProtocol {

}

public class MusicCache: MusicCacheProtocol {
    public init() { }
}


extension MusicCacheProtocol where Self == MusicCache {
    public static func empty() -> MusicCache {
        MusicCache()
    }
}
