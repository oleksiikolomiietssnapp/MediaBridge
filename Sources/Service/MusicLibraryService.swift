import MediaPlayer

public protocol MusicLibraryServiceProtocol: Sendable {
    associatedtype E: Error
    func fetchSongs() async throws(E) -> [MPMediaItem]
    func song(using predicate: MediaItemPredicateInfo) async throws(E) -> MPMediaItem
}

public final class MusicLibraryService: MusicLibraryServiceProtocol, Sendable {
    public enum MusicLibraryServiceError: Error, LocalizedError {
        case noSongsFound
        case noSongFound(MediaItemPredicateInfo)
        public var errorDescription: String? {
            switch self {
            case .noSongsFound:
                "No songs found"
            case .noSongFound(predicate: let predicate):
                "There is no song for property(\(predicate.property)) with value `\(String(describing: predicate.value))`"
            }
        }
    }

    public init() {}

    public func song(using predicate: MediaItemPredicateInfo) throws(MusicLibraryServiceError) -> MPMediaItem {
        let songFilter = MPMediaPropertyPredicate(
            value: predicate.value,
            forProperty: predicate.property
        )

        let query = MPMediaQuery.songs()
        query.addFilterPredicate(songFilter)

        guard let song = query.items?.first else {
            throw .noSongFound(predicate)
        }

        return song
    }

    public func fetchSongs() async throws(MusicLibraryServiceError) -> [MPMediaItem] {
        if let songs = MPMediaQuery.songs().items {
            return songs
        } else {
            throw .noSongsFound
        }
    }
}

extension MusicLibraryServiceProtocol where Self == MusicLibraryService, E == MusicLibraryService.MusicLibraryServiceError {
    public static var live: MusicLibraryService {
        MusicLibraryService()
    }
}

public enum MediaItemPredicateInfo: Sendable {
    case persistentID(UInt64)

    public var property: String {
        switch self {
        case .persistentID: MPMediaItemPropertyPersistentID
        }
    }

    public var value: Any? {
        switch self {
        case .persistentID(let uInt64): uInt64
        }
    }

}
