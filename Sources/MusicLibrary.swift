import Foundation
import MediaPlayer

public protocol MusicLibraryProtocol {
    func fetchSongs() async throws -> [MPMediaItem]
    func fetchSong(with predicate: MediaItemPredicateInfo, comparisonType: MPMediaPredicateComparison) async throws -> [MPMediaItem]

    func fetchAll(_ type: MPMediaType) async throws -> [MPMediaItem]
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison
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

    public func fetchAll(_ type: MPMediaType) async throws -> [MPMediaItem] {
        try await checkIfAuthorized()
        return try await service.fetchAll(type)
    }

    public func fetchSongs() async throws -> [MPMediaItem] {
        try await fetchAll(.music)
    }

    public func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        _ comparisonType: MPMediaPredicateComparison
    ) async throws -> [MPMediaItem] {
        try await checkIfAuthorized()
        return try await service.fetch(type, with: predicate, comparisonType: comparisonType)
    }

    public func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo
    ) async throws -> [MPMediaItem] {
        return try await fetch(.music, with: predicate, comparisonType)
    }

    func checkIfAuthorized() async throws {
        let status = auth.status()

        guard case .authorized = status else {
            log.debug("Unauthorized with status: \(status.description). Requesting authorization...")
            try await requestAuthorization()

            return
        }
    }

    func requestAuthorization() async throws {
        try await auth.authorize()
    }

}

extension MusicLibraryProtocol {
    public func fetchSong(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison = .equalTo
    ) async throws -> [MPMediaItem] {
        return try await fetchSong(with: predicate, comparisonType: comparisonType)
    }
}
