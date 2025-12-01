import MediaPlayer

public protocol MusicLibraryServiceProtocol: Sendable {
    associatedtype E: Error
    func fetchAll(_ type: MPMediaType) async throws(E) -> [MPMediaItem]
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws(E) -> [MPMediaItem]
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
                "There is no song for predicate: \(predicate.description)"
            }
        }
    }

    public init() {}

    public func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo
    ) throws(MusicLibraryServiceError) -> [MPMediaItem] {
        let typePredicate = MediaItemPredicateInfo.mediaType(type)
        let typeFilter = typePredicate.predicate(using: comparisonType)
        let additionalFilter = predicate.predicate(using: comparisonType)

        let query = MPMediaQuery(filterPredicates: [typeFilter, additionalFilter])

        guard let songs = query.items else {
            throw .noSongFound(predicate)
        }

        return songs
    }

    public func fetchAll(_ type: MPMediaType) async throws(MusicLibraryServiceError) -> [MPMediaItem] {
        let typePredicate = MediaItemPredicateInfo.mediaType(type)
        let typeFilter = typePredicate.predicate()
        let query = MPMediaQuery(filterPredicates: [typeFilter])

        if let songs = query.items {
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
