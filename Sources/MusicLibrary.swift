import Foundation
import MediaPlayer

protocol MusicLibraryProtocol {
    var auth: AuthorizationManagerProtocol { get }
    var cache: MusicCacheProtocol { get }
    var service: any MusicLibraryServiceProtocol { get }

    func checkIfAuthorized() async throws
    func requestAuthorization() async throws
}

public final class MusicLibrary: MusicLibraryProtocol {
    public let auth: AuthorizationManagerProtocol
    public let cache: MusicCacheProtocol
    public let service: any MusicLibraryServiceProtocol

    public init(
        auth: AuthorizationManagerProtocol = AuthorizationManager(),
        cache: MusicCacheProtocol = .empty(),
        service: any MusicLibraryServiceProtocol
    ) {
        self.auth = auth
        self.cache = cache
        self.service = service
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

        // cache songs

        return try await service.fetchSongs()
    }
}
