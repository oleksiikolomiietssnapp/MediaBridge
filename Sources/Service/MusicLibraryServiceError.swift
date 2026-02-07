//
//  MusicLibraryServiceError.swift
//  MediaBridge
//
//  Created by Oleksii Kolomiiets on 2/7/26.
//

import Foundation

/// Errors that can occur during music library service operations.
///
/// These errors are thrown by ``MusicLibraryService`` when queries to the device's music library
/// return no results. Each error provides context about the specific operation that failed.
public enum MusicLibraryServiceError: Error, LocalizedError, Equatable {

    // MARK: - Unfiltered Query Errors

    /// No media items were found when fetching all items of a specific type.
    ///
    /// **Thrown by:** ``MusicLibraryServiceProtocol/fetchAll(_:groupingType:)``
    ///
    /// **When:** The `MPMediaQuery.items` property returns `nil`, indicating the library
    /// contains no items matching the specified media type.
    ///
    /// **Why:** This typically occurs when:
    /// - The user's music library is empty
    /// - The specified media type (e.g., `.music`) has no items
    /// - The user hasn't authorized media library access
    ///
    /// **Example:**
    /// ```swift
    /// do {
    ///     let items = try await service.fetchAll(.music, groupingType: .title)
    /// } catch MusicLibraryServiceError.noItemsFound {
    ///     print("No media items in the library")
    /// }
    /// ```
    case noItemsFound

    /// No media collections were found when fetching all collections of a specific type.
    ///
    /// **Thrown by:** ``MusicLibraryServiceProtocol/fetchAllCollections(_:groupingType:)``
    ///
    /// **When:** The `MPMediaQuery.collections` property returns `nil`, indicating the library
    /// contains no collections matching the specified media type and grouping.
    ///
    /// **Why:** This typically occurs when:
    /// - The user's music library is empty
    /// - The specified media type has no items to group into collections
    /// - The grouping type (e.g., `.album`) produces no results
    ///
    /// **Example:**
    /// ```swift
    /// do {
    ///     let albums = try await service.fetchAllCollections(.music, groupingType: .album)
    /// } catch MusicLibraryServiceError.noCollectionsFound {
    ///     print("No albums in the music library")
    /// }
    /// ```
    case noCollectionsFound

    // MARK: - Filtered Query Errors

    /// No media collections were found matching the specified predicate.
    ///
    /// **Thrown by:** ``MusicLibraryServiceProtocol/fetchCollections(_:with:comparisonType:groupingType:)``
    ///
    /// **When:** The `MPMediaQuery.collections` property returns `nil` after applying
    /// the specified predicate filter.
    ///
    /// **Why:** This typically occurs when:
    /// - No collections match the predicate criteria (e.g., artist name, album title)
    /// - The comparison type is too strict (e.g., `.equalTo` instead of `.contains`)
    /// - The predicate value doesn't exist in the library
    ///
    /// **Associated Value:** The `MediaItemPredicateInfo` that was used to filter the query.
    ///
    /// **Example:**
    /// ```swift
    /// do {
    ///     let albums = try await service.fetchCollections(
    ///         .music,
    ///         with: .albumArtist("The Beatles"),
    ///         comparisonType: .equalTo,
    ///         groupingType: .album
    ///     )
    /// } catch MusicLibraryServiceError.noCollectionFound(let predicate) {
    ///     print("No collections found for: \(predicate)")
    /// }
    /// ```
    case noCollectionFound(MediaItemPredicateInfo)

    /// No media items were found matching the specified predicate.
    ///
    /// **Thrown by:** ``MusicLibraryServiceProtocol/fetch(_:with:comparisonType:groupingType:)``
    ///
    /// **When:** The `MPMediaQuery.items` property returns `nil` after applying
    /// the specified predicate filter.
    ///
    /// **Why:** This typically occurs when:
    /// - No items match the predicate criteria (e.g., title, artist name, album)
    /// - The comparison type is too strict (e.g., `.equalTo` instead of `.contains`)
    /// - The predicate value doesn't exist in the library
    /// - The media type filter excludes the desired items
    ///
    /// **Associated Value:** The `MediaItemPredicateInfo` that was used to filter the query.
    ///
    /// **Example:**
    /// ```swift
    /// do {
    ///     let items = try await service.fetch(
    ///         .music,
    ///         with: .artist("Taylor Swift"),
    ///         comparisonType: .contains,
    ///         groupingType: .title
    ///     )
    /// } catch MusicLibraryServiceError.noItemFound(let predicate) {
    ///     print("No media items found for: \(predicate)")
    /// }
    /// ```
    case noItemFound(MediaItemPredicateInfo)

    // MARK: - LocalizedError Conformance

    /// A human-readable error description suitable for displaying to users.
    ///
    /// Provides user-friendly messages that explain what went wrong and suggest corrective actions.
    public var errorDescription: String? {
        switch self {
        case .noItemsFound:
            "No media items found in your library. Try adding music to your library and try again."
        case .noCollectionsFound:
            "No media collections found in your library. Try adding music to your library and try again."
        case .noCollectionFound(let predicate):
            "Couldn't find any collections matching \(predicate.description). Check your filters and try again."
        case .noItemFound(let predicate):
            "Couldn't find any media items matching \(predicate.description). Check your filters and try again."
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
