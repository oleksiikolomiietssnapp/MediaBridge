import MediaPlayer

@testable import MediaBridge

final class MockAuthorizationManager: AuthorizationManagerProtocol {
    init(isAuthorized: Bool, authStatus: MPMediaLibraryAuthorizationStatus, authError: MockAuthError?) {
        self.isAuthorized = isAuthorized
        self.authStatus = authStatus
        self.authError = authError
    }

    var isAuthorized: Bool
    var authError: MockAuthError?
    func authorize() async throws -> Bool {
        guard let authError else { return isAuthorized }
        throw authError
    }

    var authStatus: MPMediaLibraryAuthorizationStatus
    func status() -> MPMediaLibraryAuthorizationStatus { authStatus }

    enum MockAuthError: Error {
        case mockError
    }
}

extension AuthorizationManagerProtocol where Self == MockAuthorizationManager {
    static var mock: Self { .mock() }
    static func mock(
        isAuthorized: Bool = true,
        authError: MockAuthorizationManager.MockAuthError? = nil,
        authStatus: MPMediaLibraryAuthorizationStatus = .authorized
    ) -> Self {
        MockAuthorizationManager(isAuthorized: isAuthorized, authStatus: authStatus, authError: authError)
    }
}
