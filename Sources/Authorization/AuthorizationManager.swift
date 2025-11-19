import Foundation
import MediaPlayer

public protocol AuthorizationManagerProtocol {
    @discardableResult
    func authorize() async throws -> MPMediaLibraryAuthorizationStatus
    func status() -> MPMediaLibraryAuthorizationStatus
}

public class AuthorizationManager: AuthorizationManagerProtocol {
    public init() {}

    @discardableResult
    public func authorize() async throws -> MPMediaLibraryAuthorizationStatus {
        guard status() != .authorized else {
            log.debug("Access to music library is already authorized")
            return .authorized
        }

        let status = await MPMediaLibrary.requestAuthorization()

        guard case .authorized = status else {
            throw AuthorizationManagerError.unauthorized(status.description)
        }

        log.debug("Access to music library is authorized")
        return .authorized
    }

    public func status() -> MPMediaLibraryAuthorizationStatus {
        MPMediaLibrary.authorizationStatus()
    }
}
