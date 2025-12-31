import Foundation
import MediaPlayer

/// Primary interface for accessing the device's music library.
///
/// `MusicLibrary` provides a high-level API for fetching songs and media items from the user's
/// music library. It coordinates authorization requests and service layer queries, handling
/// permission checks automatically before returning results.
///
/// ## Architecture
/// This class acts as a facade over two internal systems:
/// - Authorization management via `AuthorizationManagerProtocol`
/// - Media queries via `MusicLibraryServiceProtocol`
///
/// It ensures users have permission to access the music library before making queries.
///
/// ## Usage
///
/// Create an instance and use it directly:
/// ```swift
/// let library = MusicLibrary()
/// let songs = try await library.songs()
/// let artist = try await library.mediaItems(ofType: .music, matching: .artist("Taylor Swift"), .contains, groupingType: .album)
/// ```
///
/// For SwiftUI apps, inject the library via environment values:
/// ```swift
/// extension EnvironmentValues {
///     @Entry var library: MusicLibraryProtocol = MusicLibrary()
/// }
///
/// struct ContentView: View {
///     @Environment(\.library) var library
///
///     var body: some View {
///         VStack {
///             // Optional: Request authorization if not yet determined
///             if library.authorizationStatus == .notDetermined {
///                 Button("Request Music Library Access") {
///                     Task {
///                         try await library.requestAuthorization()
///                     }
///                 }
///             }
///             // Use library here
///         }
///         .task {
///             let songs = try await library.songs(
///                 sortedBy: \MPMediaItem.skipCount,
///                 order: .reverse
///             )
///         }
///     }
/// }
/// ```
///
/// ## Dependency Injection
/// For testing or custom behavior, inject your implementations:
/// ```swift
/// let yourAuth = YourAuthorizationManager(isAuthorized: true)
/// let yourService = YourMusicLibraryService()
/// let library = MusicLibrary(auth: yourAuth, service: yourService)
/// ```
public final class MusicLibrary: MusicLibraryProtocol {
    private let auth: any AuthorizationManagerProtocol
    private let service: any MusicLibraryServiceProtocol

    public var authorizationStatus: MPMediaLibraryAuthorizationStatus {
        auth.status()
    }

    /// Creates a new music library instance.
    ///
    /// By default, this initializer uses the production implementations (`.live`) for both
    /// authorization management and music library services. Customize via dependency injection
    /// for testing or specialized behavior.
    ///
    /// - Parameters:
    ///   - auth: The authorization manager to handle music library access permissions.
    ///     Defaults to `.live` for production use. Pass a mock implementation for testing.
    ///   - service: The service layer for querying media items.
    ///     Defaults to `.live` for production use. Pass a mock implementation for testing.
    ///
    /// ## Examples
    ///
    /// Create a library for production use with default implementations:
    /// ```swift
    /// let library = MusicLibrary()
    /// ```
    ///
    /// Create a library with only a custom authorization manager:
    /// ```swift
    /// let customAuth = MyCustomAuthorizationManager()
    /// let customService = MyCustomMusicLibraryService()
    /// let library = MusicLibrary(auth: customAuth, service: yourService)
    /// ```
    public init(
        auth: any AuthorizationManagerProtocol = .live,
        service: any MusicLibraryServiceProtocol = .live
    ) {
        self.auth = auth
        self.service = service
    }

    // MARK: - General calls

    @discardableResult
    public func requestAuthorization() async throws -> MPMediaLibraryAuthorizationStatus {
        try await auth.authorize()
    }

    public func fetchAll(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws -> [MPMediaItem] {
        try await checkIfAuthorized()
        return try await service.fetchAll(type, groupingType: groupingType)
    }

    public func mediaItems(
        ofType type: MPMediaType,
        matching predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem] {
        try await checkIfAuthorized()
        return try await service.fetch(type, with: predicate, comparisonType: comparisonType, groupingType: groupingType)
    }

    public func mediaItemCollections(
        ofType type: MPMediaType,
        matching predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItemCollection] {
        try await checkIfAuthorized()
        return try await service.fetchCollections(type, with: predicate, comparisonType: comparisonType, groupingType: groupingType)
    }

    // MARK: - Specific calls

    public func songs<T: Comparable>(
        sortedBy sortingKey: (KeyPath<MPMediaItem, T> & Sendable)?,
        order: SortOrder
    ) async throws -> [MPMediaItem] {
        #if DEBUG
            let start = Date()
            log.debug("Started fetching and sorting")
        #endif

        let songs = try await fetchAll(.music, groupingType: .title)
        #if DEBUG
            log.debug("Fetched \(songs.count) songs in \(Date.now.timeIntervalSince(start)) seconds")
        #endif

        if let sortingKey {
            #if DEBUG
                let startSorting = Date()
            #endif

            let sorted = songs.sorted(using: KeyPathComparator(sortingKey, order: order))

            #if DEBUG
                log.debug("Sorted \(songs.count) songs in \(Date.now.timeIntervalSince(startSorting)) seconds")
                log.debug("Fetched and sorted \(songs.count) songs in \(Date.now.timeIntervalSince(start)) seconds")
            #endif
            return sorted
        }

        return songs
    }

    public func songs(
        matching predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws -> [MPMediaItem] {
        return try await mediaItems(ofType: .music, matching: predicate, comparisonType, groupingType: .title)
    }

    public func albums(
        matching predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItemCollection] {
        return try await mediaItemCollections(ofType: .music, matching: predicate, comparisonType, groupingType: groupingType)
    }

    // MARK: - Private methods

    private func checkIfAuthorized() async throws {
        let status = authorizationStatus

        guard case .authorized = status else {
            log.debug("Unauthorized with status: \(status.description). Requesting authorization...")
            try await requestAuthorization()

            return
        }
    }
}

// MARK: - Deprecated
extension MusicLibrary {
    @available(*, deprecated, renamed: "mediaItems(ofType:matching:_:groupingType:)")
    public func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem] {
        return try await mediaItems(ofType: type, matching: predicate, comparisonType, groupingType: groupingType)
    }

    @available(*, deprecated, renamed: "songs()")
    public func fetchSongs<T: Comparable>(
        sortedBy sortingKey: (KeyPath<MPMediaItem, T> & Sendable)?,
        order: SortOrder
    ) async throws -> [MPMediaItem] {
        return try await songs(sortedBy: sortingKey, order: order)
    }

    @available(*, deprecated, renamed: "songs(matching:comparisonType:)")
    public func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
    ) async throws -> [MPMediaItem] {
        return try await songs(matching: predicate, comparisonType: comparisonType)
    }
}
