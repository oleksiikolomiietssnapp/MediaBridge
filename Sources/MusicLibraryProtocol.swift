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
    ///     let songs = try await library.songs()
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
    /// let songs = try await library.songs()
    /// ```
    ///
    /// Fetch songs sorted by play count:
    /// ```swift
    /// @Environment(\.library) var library
    /// let sorted = try await library.songs(
    ///     sortedBy: \MPMediaItem.playCount,
    ///     order: .forward
    /// )
    /// ```
    ///
    /// Fetch songs sorted by skip count:
    /// ```swift
    /// @Environment(\.library) var library
    /// let frequent = try await library.songs(
    ///     sortedBy: \MPMediaItem.skipCount,
    ///     order: .reverse
    /// )
    /// ```
    func songs<T: Comparable>(
        sortedBy sortingKey: (KeyPath<MPMediaItem, T> & Sendable)?,
        order: SortOrder
    ) async throws -> [MPMediaItem]

    /// Fetches songs matching a predicate.
    ///
    /// Queries the music library for songs matching the provided predicate using the specified comparison type.
    /// Useful for filtering by artist, title, genre, or other properties.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter songs (e.g., `.persistentID(12345)`, `.artist("Beatles")`)
    ///   - comparisonType: How to compare the predicate value (`.equalTo`, `.contains`, etc.)
    /// - Returns: Array of matching songs
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let songs = try await library.songs(
    ///     matching: .artist("Taylor Swift"),
    ///     comparisonType: .contains
    /// )
    /// ```
    func songs(
        matching predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws -> [MPMediaItem]

    /// Fetches media items of a specific type matching a predicate.
    ///
    /// Queries the music library for items matching the provided type and predicate.
    /// This is the most flexible method, allowing you to fetch any media type (music, podcasts, audiobooks)
    /// with custom filtering and grouping.
    ///
    /// - Parameters:
    ///   - type: The type of media to fetch (`.music`, `.podcast`, etc.)
    ///   - predicate: The predicate to filter items
    ///   - comparisonType: How to compare the predicate value
    ///   - groupingType: How to group the returned items
    /// - Returns: Array of media items matching the criteria
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let items = try await library.mediaItems(
    ///     ofType: .music,
    ///     matching: .genre("Rock"),
    ///     .contains,
    ///     groupingType: .album
    /// )
    /// ```
    func mediaItems(
        ofType type: MPMediaType,
        matching predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem]

    func mediaItemCollections(
        ofType type: MPMediaType,
        matching predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItemCollection]

    /// Return albums item collection
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter songs (e.g., `.persistentID(12345)`, `.artist("Beatles")`)
    ///   - comparisonType: How to compare the predicate value (`.equalTo`, `.contains`, etc.)
    ///   - groupingType: How to group the returned items
    /// - Returns: Array of matching songs
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    func albums(
        matching predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItemCollection]

    // MARK: - Deprecated
    @available(*, deprecated, renamed: "songs(sortedBy:order:)")
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
    /// let songs = try await library.songs()
    /// ```
    ///
    /// Fetch songs sorted by play count:
    /// ```swift
    /// @Environment(\.library) var library
    /// let sorted = try await library.songs(
    ///     sortedBy: \MPMediaItem.playCount,
    ///     order: .forward
    /// )
    /// ```
    ///
    /// Fetch songs sorted by skip count:
    /// ```swift
    /// @Environment(\.library) var library
    /// let frequent = try await library.songs(
    ///     sortedBy: \MPMediaItem.skipCount,
    ///     order: .reverse
    /// )
    /// ```
    func fetchSongs<T: Comparable>(
        sortedBy sortingKey: (KeyPath<MPMediaItem, T> & Sendable)?,
        order: SortOrder
    ) async throws -> [MPMediaItem]

    @available(*, deprecated, renamed: "songs(matching:comparisonType:)")
    /// Fetches songs matching a predicate.
    ///
    /// Queries the music library for songs matching the provided predicate.
    /// Useful for filtering by artist, title, genre, or other properties.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter songs (e.g., `.persistentID(12345)`, `.artist("Beatles")`)
    ///   - comparisonType: How to compare the predicate value (defaults to `.equalTo`)
    /// - Returns: Array of matching songs
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let songs = try await library.songs(
    ///     matching: .persistentID(12345),
    ///     comparisonType: .equalTo
    /// )
    /// ```
    func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws -> [MPMediaItem]

    @available(*, deprecated, renamed: "mediaItems(ofType:matching:_:groupingType:)")
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
}

extension MusicLibraryProtocol where Self == MusicLibrary {
    /// Fetches all songs without sorting.
    ///
    /// Convenience method that fetches all songs with default behavior (unsorted, forward order).
    /// Equivalent to calling `songs(sortedBy: nil, order: .forward)`.
    ///
    /// - Returns: Array of all songs in the library, unsorted
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let allSongs = try await library.songs()
    /// ```
    public func songs() async throws -> [MPMediaItem] {
        return try await songs(sortedBy: (KeyPath<MPMediaItem, Never> & Sendable)?.none, order: .forward)
    }

    /// Fetches songs matching a predicate with default comparison type.
    ///
    /// Convenience method that uses `.equalTo` as the default comparison type.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to filter songs
    ///   - comparisonType: How to compare the predicate value (defaults to `.equalTo`)
    /// - Returns: Array of matching songs
    /// - Throws: ``AuthorizationManagerError/unauthorized(_:)`` if music library access is not authorized
    ///
    /// ## Example
    /// ```swift
    /// @Environment(\.library) var library
    /// let song = try await library.songs(matching: .persistentID(12345))
    /// ```
    public func songs(
        matching predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo
    ) async throws -> [MPMediaItem] {
        return try await songs(matching: predicate, comparisonType: comparisonType)
    }
    
    // MARK: - Deprecated
    @available(*, deprecated, renamed: "songs()")
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
        return try await songs()
    }

    @available(*, deprecated, renamed: "songs(matching:comparisonType:)")
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
        return try await songs(matching: predicate, comparisonType: comparisonType)
    }
}
