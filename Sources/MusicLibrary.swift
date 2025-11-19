import Foundation

protocol MusicLibraryProtocol {
    var auth: AuthorizationManagerProtocol { get }
    var cache: MusicCacheProtocol { get }

    func checkIfAuthorized() async -> Bool
    func requestAuthorization() async -> Bool
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

    func checkIfAuthorized() async -> Bool {
        let status = auth.status()

        guard case .authorized = status else {
            log.debug("Unauthorized with status: %@", args: status.description)
            return await requestAuthorization()
        }

        log.info("Access to music library is authorized")
        return true
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await auth.authorize()
        } catch {
            log.error(error)
            return false
        }
    }

    public func fetchSongs() async -> [String] {
        guard await checkIfAuthorized() else {
            return []
        }
        // look into cache
        // if empty fetch from media library and cache it
        return []
    }
}
