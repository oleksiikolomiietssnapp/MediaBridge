import Foundation
import MediaPlayer

public protocol MusicLibraryProtocol {
    func fetchSongs() async throws -> [MPMediaItem]
}

public final class MusicLibrary: MusicLibraryProtocol {
    private let auth: AuthorizationManagerProtocol
    private let cache: MusicCacheProtocol

    public init(
        auth: AuthorizationManagerProtocol = AuthorizationManager(),
        cache: MusicCacheProtocol = .empty()
    ) {
        self.auth = auth
        self.cache = cache
    }

    func checkIfAuthorized() async throws {
        let status = auth.status()

        guard case .authorized = status else {
            log.debug("Unauthorized with status: %@. Requesting authorization...", args: status.description)
            try await requestAuthorization()

            return
        }

        log.info("Access to music library is authorized")
    }

    func requestAuthorization() async throws {
        try await auth.authorize()
    }


    public func fetchSongs() async throws -> [MPMediaItem] {
        try await checkIfAuthorized()
        return try await cache.fetchSongs()
    }
}
