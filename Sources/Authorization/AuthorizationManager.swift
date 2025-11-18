import Foundation
import MediaPlayer

public protocol AuthorizationManagerProtocol {
    func authorize() async throws -> Bool
    func status() -> MPMediaLibraryAuthorizationStatus
}

public class AuthorizationManager: AuthorizationManagerProtocol {
    public init() {}

    public func authorize() async throws -> Bool {
        guard status() != .authorized else {
            print("Authorized")
            return true
        }

        let status = await MPMediaLibrary.requestAuthorization()

        guard case .authorized = status else {
            throw AuthorizationManagerError.unauthorized(status.description)
        }

        print("Authorized")
        return true
    }

    public func status() -> MPMediaLibraryAuthorizationStatus {
        MPMediaLibrary.authorizationStatus()
    }
}
