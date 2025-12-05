import Foundation
import MediaPlayer

/// Protocol for fetching media items from the device's music library.
///
/// This protocol provides methods to query and retrieve music library items with flexible filtering and sorting options.
/// All methods require music library access authorization before use.
public protocol MusicLibraryProtocol {
    /// Returns the current authorization status for music library access.
    ///
    /// Queries the system for the current authorization status without triggering any user prompts or permission dialogs.
    /// Use this property to check if the app has permission to access the user's music library.
    ///
    /// The authorization status can be one of the following:
    /// - `.authorized`: The app has permission to access the music library
    /// - `.denied`: The user has denied permission for music library access
    /// - `.notDetermined`: The user has not yet responded to the authorization prompt
    /// - `.restricted`: The app is restricted from accessing the music library (e.g., parental controls)
    ///
    /// - Returns: The current ``MediaPlayer/MPMediaLibraryAuthorizationStatus``
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// switch library.authorizationStatus {
    /// case .authorized:
    ///     // Safe to fetch music library items
    /// case .denied, .restricted:
    ///     // Show error message to user
    /// case .notDetermined:
    ///     // Prompt user for authorization
    /// @unknown default:
    ///     // Handle future status values
    /// }
    /// ```
    var authorizationStatus: MPMediaLibraryAuthorizationStatus { get }

    /// Requests music library access authorization from the user.
    ///
    /// Presents the system authorization prompt if the user hasn't yet decided.
    /// If authorization is already determined, returns the current status without prompting.
    ///
    /// - Returns: The authorization status after the request
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if the request fails
    ///
    /// ## Example
    /// ```swift
    /// let library = MusicLibrary()
    /// let status = try await library.requestAuthorization()
    /// if case .authorized = status {
    ///     let songs = try await library.fetchSongs()
    /// }
    /// ```
    @discardableResult
    func requestAuthorization() async throws -> MPMediaLibraryAuthorizationStatus

    /// Fetches all media items of a specific type.
    ///
    /// Retrieves all media items matching the specified type from the device's music library.
    /// Grouping determines how results are organized (by title, album, artist, etc.).
    ///
    /// - Parameters:
    ///   - type: The type of media to fetch (typically `.music`)
    ///   - groupingType: How to group the returned items
    /// - Returns: Array of all media items matching the specified type
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let allSongs = try await library.fetchAll(.music, groupingType: .title)
    /// ```
    func fetchAll(
        _ type: MPMediaType,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem]

    /// Fetches media items matching a specific predicate.
    ///
    /// Queries the music library for items that match the provided predicate condition.
    /// The comparison type determines how the predicate value is matched (exact match, contains, etc.).
    ///
    /// - Parameters:
    ///   - type: The type of media to fetch (typically `.music`)
    ///   - predicate: The predicate to filter items (e.g., `.artist("Taylor Swift")`)
    ///   - comparisonType: How to compare the predicate value (`.equalTo`, `.contains`, etc.)
    ///   - groupingType: How to group the returned items
    /// - Returns: Array of media items matching the predicate
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let songs = try await library.fetch(
    ///     .music,
    ///     with: .artist("Taylor Swift"),
    ///     .contains,
    ///     groupingType: .album
    /// )
    /// ```
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem]

    /// Fetches all songs with optional sorting.
    ///
    /// Retrieves all songs from the music library and optionally sorts them by a specified key path.
    /// If no sort key is provided, songs are returned unsorted.
    ///
    /// - Parameters:
    ///   - sortingKey: Optional key path to sort by (e.g., `\MPMediaItem.dateAdded`, `\MPMediaItem.skipCount`).
    ///     If `nil`, results are not sorted.
    ///   - order: The sort order (`.forward` for ascending, `.reverse` for descending)
    /// - Returns: Array of songs, sorted if a key is provided
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Examples
    /// Fetch unsorted songs:
    /// ```swift
    /// @Environment(\.library) var library
    /// let songs = try await library.fetchSongs()
    /// ```
    ///
    /// Fetch songs sorted by play count:
    /// ```swift
    /// @Environment(\.library) var library
    /// let sorted = try await library.fetchSongs(
    ///     sortedBy: \MPMediaItem.playCount,
    ///     order: .forward
    /// )
    /// ```
    ///
    /// Fetch songs sorted by skip count:
    /// ```swift
    /// @Environment(\.library) var library
    /// let frequent = try await library.fetchSongs(
    ///     sortedBy: \MPMediaItem.skipCount,
    ///     order: .reverse
    /// )
    /// ```
    func fetchSongs<T: Comparable>(
        sortedBy sortingKey: (KeyPath<MPMediaItem, T> & Sendable)?,
        order: SortOrder
    ) async throws -> [MPMediaItem]

    /// Fetches a specific song matching a predicate.
    ///
    /// Queries the music library for songs matching the provided predicate.
    /// Typically used to fetch a single song by persistent ID or unique identifier.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to identify the song (e.g., `.persistentID(12345)`)
    ///   - comparisonType: How to compare the predicate value (defaults to `.equalTo`)
    /// - Returns: Array of matching songs (typically contains 0 or 1 item)
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let songs = try await library.fetchSong(
    ///     with: .persistentID(12345),
    ///     comparisonType: .equalTo
    /// )
    /// ```
    func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws -> [MPMediaItem]
}

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
/// let songs = try await library.fetchSongs()
/// let artist = try await library.fetch(.music, with: .artist("Taylor Swift"), .contains, groupingType: .album)
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
///             // Use library here
///         }
///         .task {
///             let songs = try await library.fetchSongs(
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

    public func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem] {
        try await checkIfAuthorized()
        return try await service.fetch(type, with: predicate, comparisonType: comparisonType, groupingType: groupingType)
    }

    // MARK: - Specific calls

    public func fetchSongs<T: Comparable>(
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

    public func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
    ) async throws -> [MPMediaItem] {
        return try await fetch(.music, with: predicate, comparisonType, groupingType: .title)
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

extension MusicLibraryProtocol where Self == MusicLibrary {
    /// Fetches all songs without sorting.
    ///
    /// Convenience method that fetches all songs with default behavior (unsorted, forward order).
    /// Equivalent to calling `fetchSongs(sortedBy: nil, order: .forward)`.
    ///
    /// - Returns: Array of all songs in the library, unsorted
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let allSongs = try await library.fetchSongs()
    /// ```
    public func fetchSongs() async throws -> [MPMediaItem] {
        return try await fetchSongs(sortedBy: (KeyPath<MPMediaItem, Never> & Sendable)?.none, order: .forward)
    }

    /// Fetches a specific song with a default comparison type.
    ///
    /// Convenience method that fetches a song matching the provided predicate,
    /// using `.equalTo` as the default comparison type.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to identify the song (e.g., `.persistentID(12345)`, `.artist("Beatles")`)
    ///   - comparisonType: How to compare the predicate value (defaults to `.equalTo`)
    /// - Returns: Array of matching songs (typically contains 0 or 1 item)
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// // Using default .equalTo comparison
    /// let songs = try await library.fetchSong(with: .persistentID(12345))
    /// ```
    public func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo
    ) async throws -> [MPMediaItem] {
        return try await fetchSong(with: predicate, comparisonType: comparisonType)
    }
}
