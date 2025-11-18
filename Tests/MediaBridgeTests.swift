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
            mockAuth: .mock(isAuthorized: false)
        )
        let songs = try await library.fetchSongs()
        #expect(songs.isEmpty)
    }

    @Test func testSongs_AuthFail() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        let songs = try await library.fetchSongs()
        #expect(songs.isEmpty)
    }

    @Test func testSongs_StatusDenied() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authStatus: .denied)
        )
        let songs = try await library.fetchSongs()
        #expect(songs.isEmpty)
    }
}

private extension MusicLibrary {
    convenience init(
        mockAuth: AuthorizationManagerProtocol = .mock,
        mockCache: MusicCacheProtocol = .mock
    ) {
        self.init(auth: mockAuth, cache: mockCache)
    }

    static var withMocks: MusicLibrary { MusicLibrary(mockAuth: .mock) }
}
