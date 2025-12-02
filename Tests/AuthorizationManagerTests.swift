import MediaBridge
import MediaPlayer
import Testing

@Suite("AuthorizationManager")
struct AuthorizationManagerTests {
    @Test func authorize_whenAlreadyAuthorized_returnsAuthorizedImmediately() async throws {
        let manager: any AuthorizationManagerProtocol = AuthorizationManager<MockMediaLibraryAuthorized>()
        let status = try await manager.authorize()

        #expect(status == .authorized)
    }

    @Test func authorize_whenDenied_Authorize() async throws {
        let manager: any AuthorizationManagerProtocol = AuthorizationManager<MockMediaLibraryDenied_Authorized>()
        let status = try await manager.authorize()

        #expect(status == .authorized)
    }

    @Test func authorize_whenDenied_throwsUnauthorizedError() async throws {
        let expectedStatus = MPMediaLibraryAuthorizationStatus.denied
        await #expect(throws: AuthorizationManagerError.unauthorized(expectedStatus.description)) {
            let manager: any AuthorizationManagerProtocol = AuthorizationManager<MockMediaLibraryDenied_Denied>()
            try await manager.authorize()
        }
    }

    @Test func authorize_whenRestricted_throwsUnauthorizedError() async throws {
        let expectedStatus = MPMediaLibraryAuthorizationStatus.restricted
        await #expect(throws: AuthorizationManagerError.unauthorized(expectedStatus.description)) {
            let manager: any AuthorizationManagerProtocol = AuthorizationManager<MockMediaLibraryRestricted>()
            try await manager.authorize()
        }
    }

    @Test func authorize_whenNotDetermined_throwsUnauthorizedError() async throws {
        let expectedStatus = MPMediaLibraryAuthorizationStatus.notDetermined
        await #expect(throws: AuthorizationManagerError.unauthorized(expectedStatus.description)) {
            let manager: any AuthorizationManagerProtocol = AuthorizationManager<MockMediaLibraryNotDetermined>()
            try await manager.authorize()
        }
    }
}
