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

    @Test func testFetchSongs() async throws {
        let song1 = "Boo"
        let song2 = "Foo"
        let cache = MockMusicCache(songs: [song1, song2])
        let library = MusicLibrary(mockCache: cache)
        let songs = try await library.fetchSongs()
        #expect(songs.count == 2)
        let first = try #require(songs.first)
        #expect(first == song1)
        let last = try #require(songs.last)
        #expect(last == song2)
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
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
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
