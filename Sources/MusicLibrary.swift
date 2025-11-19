import Foundation

protocol MusicLibraryProtocol {
    var auth: AuthorizationManagerProtocol { get }
    var cache: MusicCacheProtocol { get }

    func checkIfAuthorized() async throws
    func requestAuthorization() async throws
}

public final class MusicLibrary: MusicLibraryProtocol {
    public let auth: AuthorizationManagerProtocol
    public let cache: MusicCacheProtocol

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

    public func fetchSongs() async throws -> [String] {
        try await checkIfAuthorized()
        // look into cache
        // if empty fetch from media library and cache it
        return []
    }
}
