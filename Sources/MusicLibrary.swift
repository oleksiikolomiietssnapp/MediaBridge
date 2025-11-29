import Foundation
import MediaPlayer

public protocol MusicLibraryProtocol {
    func fetchSongs() async throws -> [MPMediaItem]
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

    func checkIfAuthorized() async throws {
        let status = auth.status()

        guard case .authorized = status else {
            log.debug("Unauthorized with status: \(status.description). Requesting authorization...")
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
        return try await service.fetchSongs()
    }
}
