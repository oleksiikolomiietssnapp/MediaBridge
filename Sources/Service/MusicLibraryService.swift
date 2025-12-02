import MediaPlayer

/// Protocol for querying media items from the music library.
///
/// This protocol defines the service layer interface for fetching media items with flexible filtering and grouping.
/// It is primarily used by `MusicLibrary` for the concrete implementation, but can be injected for testing or custom implementations.
///
/// ## Usage
/// The protocol is designed for dependency injection:
/// - Use `MusicLibraryServiceProtocol.live` in production
/// - Pass mock implementations in tests
/// - Implement your own conforming type for custom behavior
///
/// ## Generic Error Type
/// The associated type `E` allows concrete implementations to define their own error types,
/// enabling type-safe error handling.
public protocol MusicLibraryServiceProtocol: Sendable {
    associatedtype E: Error

    /// Fetches all media items of a specific type with optional grouping.
    ///
    /// Retrieves all media items matching the specified media type from the music library.
    /// Results can be grouped by title, album, artist, or other criteria.
    ///
    /// - Parameters:
    ///   - type: The type of media to fetch (typically `.music`)
    ///   - groupingType: How to organize the returned items
    /// - Returns: Array of media items matching the type
    /// - Throws: An error of type `E` if the query fails
    ///
    /// ## Example
    /// ```swift
    /// let items = try await service.fetchAll(.music, groupingType: .album)
    /// ```
    func fetchAll(
        _ type: MPMediaType,
        groupingType: MPMediaGrouping
    ) async throws(E) -> [MPMediaItem]

    /// Fetches media items matching a predicate with optional filtering.
    ///
    /// Queries the music library for items that match the provided predicate and media type.
    /// The comparison type determines how the predicate is matched.
    ///
    /// - Parameters:
    ///   - type: The type of media to fetch (typically `.music`)
    ///   - predicate: The predicate to filter items
    ///   - comparisonType: How to compare the predicate value (e.g., `.equalTo`, `.contains`)
    ///   - groupingType: How to organize the returned items
    /// - Returns: Array of media items matching the predicate
    /// - Throws: An error of type `E` if the query fails
    ///
    /// ## Example
    /// ```swift
    /// let items = try await service.fetch(
    ///     .music,
    ///     with: .artist("Taylor Swift"),
    ///     comparisonType: .contains,
    ///     groupingType: .album
    /// )
    /// ```
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws(E) -> [MPMediaItem]
}

/// The production implementation of `MusicLibraryServiceProtocol`.
///
/// This class provides the concrete implementation for querying the music library using Apple's `MPMediaQuery` and `MPMediaPredicate` APIs.
/// It is the default service used by `MusicLibrary` for all media item queries.
///
/// ## Instantiation
/// Use the `.live` factory property to get the default implementation:
/// ```swift
/// let library = MusicLibrary(service: .live)
/// ```
///
/// For testing or custom implementations, conform to `MusicLibraryServiceProtocol` and inject your implementation.
public final class MusicLibraryService: MusicLibraryServiceProtocol, Sendable {
    /// Errors that can occur during music library service operations.
    public enum MusicLibraryServiceError: Error, LocalizedError {
        /// No songs were found matching the query.
        case noSongsFound

        /// No song was found matching the specified predicate.
        case noSongFound(MediaItemPredicateInfo)

        /// A human-readable error description suitable for displaying to users.
        public var errorDescription: String? {
            switch self {
            case .noSongsFound:
                "No songs found in your music library. Try adding music to your library and try again."
            case .noSongFound(let predicate):
                "Couldn't find a song matching \(predicate.description). Check your filters and try again."
            }
        }
    }

    // MARK: - MusicLibraryServiceProtocol Implementation

    /// Fetches media items matching a predicate with default parameters.
    ///
    /// Implementation of `MusicLibraryServiceProtocol.fetch(...)` with default comparison type (`.equalTo`)
    /// and default grouping type (`.title`). Combines the media type predicate with the user-provided predicate.
    public func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo,
        groupingType: MPMediaGrouping = .title
    ) async throws(MusicLibraryServiceError) -> [MPMediaItem] {
        let typePredicate = MediaItemPredicateInfo.mediaType(type)
        let typeFilter = typePredicate.predicate(using: comparisonType)
        let additionalFilter = predicate.predicate(using: comparisonType)

        let query = prepareQuery(with: [typeFilter, additionalFilter], groupingType: groupingType)

        guard let songs = query.items else {
            throw .noSongFound(predicate)
        }
        return songs
    }

    /// Fetches all media items of a specific type with grouping.
    ///
    /// Implementation of `MusicLibraryServiceProtocol.fetchAll(...)` that retrieves all items of the specified type
    /// without additional filtering, organized by the specified grouping type.
    public func fetchAll(
        _ type: MPMediaType,
        groupingType: MPMediaGrouping
    ) async throws(MusicLibraryServiceError) -> [MPMediaItem] {
        let typePredicate = MediaItemPredicateInfo.mediaType(type)
        let typeFilter = typePredicate.predicate()

        let query = prepareQuery(with: [typeFilter], groupingType: groupingType)

        guard let songs = query.items else {
            throw .noSongsFound
        }
        return songs
    }

    // MARK: - Private Helpers

    /// Prepares an MPMediaQuery with the given predicates and grouping.
    private func prepareQuery(with predicates: Set<MPMediaPredicate>?, groupingType: MPMediaGrouping) -> MPMediaQuery {
        let query = MPMediaQuery(filterPredicates: predicates)
        query.groupingType = groupingType
        return query
    }
}

/// Factory extension for creating a live instance of `MusicLibraryService`.
extension MusicLibraryServiceProtocol where Self == MusicLibraryService, E == MusicLibraryService.MusicLibraryServiceError {
    /// Returns a live instance of the default `MusicLibraryService` implementation.
    ///
    /// Use this property in production code to get the standard service implementation:
    /// ```swift
    /// let library = MusicLibrary(service: .live)
    /// ```
    ///
    /// For testing, pass mock implementations conforming to `MusicLibraryServiceProtocol` instead.
    public static var live: MusicLibraryService {
        MusicLibraryService()
    }
}
