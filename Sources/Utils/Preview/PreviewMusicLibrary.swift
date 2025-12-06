import Foundation
import MediaPlayer

#if DEBUG
    public class PreviewMusicLibrary: MusicLibraryProtocol {
        private let status: MPMediaLibraryAuthorizationStatus
        private let statusAfterRequest: MPMediaLibraryAuthorizationStatus
        private let fetchedAllMedia: [MPMediaItem]
        private let fetchedMedia: [MPMediaItem]
        private let fetchedSongs: [MPMediaItem]
        private let filteredSongs: [MPMediaItem]

        init(
            status: MPMediaLibraryAuthorizationStatus,
            statusAfterRequest: MPMediaLibraryAuthorizationStatus,
            fetchedAllMedia: [MPMediaItem],
            fetchedMedia: [MPMediaItem],
            fetchedSongs: [MPMediaItem],
            filteredSongs: [MPMediaItem]
        ) {
            self.status = status
            self.statusAfterRequest = statusAfterRequest
            self.fetchedAllMedia = fetchedAllMedia
            self.fetchedMedia = fetchedMedia
            self.fetchedSongs = fetchedSongs
            self.filteredSongs = filteredSongs
        }

        public var authorizationStatus: MPMediaLibraryAuthorizationStatus { status }
        public func requestAuthorization() async throws -> MPMediaLibraryAuthorizationStatus { statusAfterRequest }
        public func fetchAll(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws -> [MPMediaItem] { fetchedAllMedia }
        public func fetch(
            _ type: MPMediaType,
            with predicate: MediaBridge.MediaItemPredicateInfo,
            _ comparisonType: MPMediaPredicateComparison,
            groupingType: MPMediaGrouping
        ) async throws -> [MPMediaItem] { fetchedMedia }
        public func mediaItems(
            ofType type: MPMediaType,
            matching predicate: MediaBridge.MediaItemPredicateInfo,
            _ comparisonType: MPMediaPredicateComparison,
            groupingType: MPMediaGrouping
        ) async throws -> [MPMediaItem] { fetchedMedia }

        public func fetchSongs<T>(sortedBy sortingKey: (any KeyPath<MPMediaItem, T> & Sendable)?, order: SortOrder) async throws
            -> [MPMediaItem]
        where T: Comparable { fetchedSongs }
        public func songs<T>(sortedBy sortingKey: (any KeyPath<MPMediaItem, T> & Sendable)?, order: SortOrder) async throws
            -> [MPMediaItem]
        where T: Comparable { fetchedSongs }

        public func fetchSong(with predicate: MediaBridge.MediaItemPredicateInfo, comparisonType: MPMediaPredicateComparison) async throws
            -> [MPMediaItem]
        { filteredSongs }
        public func songs(matching predicate: MediaBridge.MediaItemPredicateInfo, comparisonType: MPMediaPredicateComparison) async throws
            -> [MPMediaItem]
        { filteredSongs }
    }
#endif
