import Testing
import MediaPlayer

@testable import MediaBridge

@Suite("MusicLibrary")
class MusicLibraryTests {
    @Test func testFetchSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.fetchSongs()
        #expect(songs.isEmpty)
    }

    @Test func testFetchSortedSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.fetchSongs(sortedBy: \MPMediaItem.skipCount, order: .forward)
        #expect(songs.isEmpty)
    }

    @Test func testFetchByExplicitSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.fetchSongs(sortedBy: \MPMediaItem.isExplicitItem, order: .forward)
        #expect(songs.isEmpty)
    }

    @Test func testFetchByDateAddedSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.fetchSongs(sortedBy: \MPMediaItem.releaseDate, order: .forward)
        #expect(songs.isEmpty)
    }

    // Failures

    @Test func testSongs_Unauthorized() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testSongs_AuthFail() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testSongs_StatusDenied() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testFetchSongs_FailingService() async throws {
        let service = MockMusicLibraryService(fetchSongsError: .noSongs)
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: true, authStatus: .denied),
            mockService: service
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockMusicLibraryService.MockError.noSongs) {
            let _ = try await library.fetchSongs()
        }
    }

    @Test func testFetchSong_Failure() async throws {
        let service = MockMusicLibraryService(fetchSongError: .noSong)
        let library = MusicLibrary(mockService: service)
        #expect(library.authorizationStatus == .authorized)

        await #expect(throws: MockMusicLibraryService.MockError.noSong) {
            let _ = try await library.fetchSong(with: .mock)
        }
    }
}

private extension MusicLibrary {
    convenience init(
        mockAuth: any AuthorizationManagerProtocol = .mock,
        mockService: any MusicLibraryServiceProtocol = .mock
    ) {
        self.init(auth: mockAuth, service: mockService)
    }

    static var withMocks: MusicLibrary { MusicLibrary(mockAuth: .mock) }
}


extension MediaItemPredicateInfo {
    static var mock: Self {
        MediaItemPredicateInfo.persistentID(21)
    }
}
