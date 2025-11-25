import Testing
import MediaPlayer
import MediaBridge

@Suite
class MediaBridgeTests {
    @Test func testLibraryInit() async throws {
        let library = MusicLibrary.withMocks
        let songs = try await library.fetchSongs()
        #expect(songs.isEmpty)
    }

    // Failures

    @Test func testSongs_Unauthorized() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testSongs_AuthFail() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testSongs_StatusDenied() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testFetchSongs_FailingService() async throws {
        let service = MockMusicLibraryService(fetchSongError: .mock)
        let cache = MusicCache(service: service)
        let library = MusicLibrary(mockCache: cache)
        await #expect(throws: MockMusicLibraryService.MockError.mock) {
            let _ = try await library.fetchSongs()
        }
    }
}

private extension MusicLibrary {
    convenience init(
        mockAuth: AuthorizationManagerProtocol = .mock,
        mockCache: MusicCacheProtocol = .mock,
        mockService: any MusicLibraryServiceProtocol = .mock
    ) {
        self.init(auth: mockAuth, cache: mockCache)
    }

    static var withMocks: MusicLibrary { MusicLibrary(mockAuth: .mock) }
}
