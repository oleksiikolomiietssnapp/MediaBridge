import Foundation
import MediaPlayer

public protocol MusicCacheProtocol {
    func fetchSongs() async throws -> [MPMediaItem]
}

public class MusicCache: MusicCacheProtocol {
    public let service: any MusicLibraryServiceProtocol

    public init(service: any MusicLibraryServiceProtocol = .live) {
        self.service = service
    }

    public func fetchSongs() async throws -> [MPMediaItem] {
        try await service.fetchSongs()
    }
}

extension MusicCacheProtocol where Self == MusicCache {
    public static func empty() -> MusicCache {
        MusicCache()
    }
}
