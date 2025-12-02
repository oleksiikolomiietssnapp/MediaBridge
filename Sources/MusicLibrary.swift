import Foundation
import MediaPlayer

public protocol MusicLibraryProtocol {
    func fetchAll(
        _ type: MPMediaType,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem]

    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItem]

    func fetchSongs<T: Comparable>(
        sortedBy key: (KeyPath<MPMediaItem, T> & Sendable)?,
        order: SortOrder
    ) async throws -> [MPMediaItem]

    func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws -> [MPMediaItem]
}

public final class MusicLibrary: MusicLibraryProtocol {
    private let auth: AuthorizationManagerProtocol
    private let service: any MusicLibraryServiceProtocol

    public init(
        auth: AuthorizationManagerProtocol = AuthorizationManager(),
        service: any MusicLibraryServiceProtocol = MusicLibraryService()
    ) {
        self.auth = auth
        self.service = service
    }

    // MARK: - General calls

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
        let status = auth.status()

        guard case .authorized = status else {
            log.debug("Unauthorized with status: \(status.description). Requesting authorization...")
            try await requestAuthorization()

            return
        }
    }

    private func requestAuthorization() async throws {
        try await auth.authorize()
    }

}

extension MusicLibraryProtocol where Self == MusicLibrary {
    public func fetchSongs() async throws -> [MPMediaItem] {
        return try await fetchSongs(sortedBy: (KeyPath<MPMediaItem, Never> & Sendable)?.none, order: .forward)
    }

    public func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo
    ) async throws -> [MPMediaItem] {
        return try await fetchSong(with: predicate, comparisonType: comparisonType)
    }
}
