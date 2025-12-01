import MediaPlayer

public protocol MusicLibraryServiceProtocol: Sendable {
    associatedtype E: Error
    func fetchAll(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws(E) -> [MPMediaItem]
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
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
            case .noSongFound(let predicate):
                "There is no song for predicate: \(predicate.description)"
            }
        }
    }

    public init() {}

    public func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo,
        groupingType: MPMediaGrouping = .title
    ) throws(MusicLibraryServiceError) -> [MPMediaItem] {
        let typePredicate = MediaItemPredicateInfo.mediaType(type)
        let typeFilter = typePredicate.predicate(using: comparisonType)
        let additionalFilter = predicate.predicate(using: comparisonType)

        let query = prepareQuery(with: [typeFilter, additionalFilter], groupingType: groupingType)

        guard let songs = query.items else {
            throw .noSongFound(predicate)
        }
        return songs
    }

    public func fetchAll(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws(MusicLibraryServiceError) -> [MPMediaItem] {
        let typePredicate = MediaItemPredicateInfo.mediaType(type)
        let typeFilter = typePredicate.predicate()

        let query = prepareQuery(with: [typeFilter], groupingType: groupingType)

        guard let songs = query.items else {
            throw .noSongsFound
        }
        return songs
    }

    private func prepareQuery(with predicates: Set<MPMediaPredicate>?, groupingType: MPMediaGrouping) -> MPMediaQuery {
        let query = MPMediaQuery(filterPredicates: predicates)
        query.groupingType = groupingType
        return query
    }
}

extension MusicLibraryServiceProtocol where Self == MusicLibraryService, E == MusicLibraryService.MusicLibraryServiceError {
    public static var live: MusicLibraryService {
        MusicLibraryService()
    }
}
