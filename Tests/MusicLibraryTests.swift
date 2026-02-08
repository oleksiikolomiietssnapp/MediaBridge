import Testing
import MediaPlayer

@testable import MediaBridge

@Suite("MusicLibrary")
class MusicLibraryTests {
    @Test func testFetchSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.songs()
        #expect(songs.isEmpty)
    }

    @Test func testFetchSortedSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.songs(sortedBy: \MPMediaItem.skipCount, order: .forward)
        #expect(songs.isEmpty)
    }

    @Test func testFetchByExplicitSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.songs(sortedBy: \MPMediaItem.isExplicitItem, order: .forward)
        #expect(songs.isEmpty)
    }

    @Test func testFetchByDateAddedSongs() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let songs = try await library.songs(sortedBy: \MPMediaItem.releaseDate, order: .forward)
        #expect(songs.isEmpty)
    }

    @Test func testFetchAlbums() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let albums = try await library.albums(matching: .title(""), .equalTo, groupingType: .album)
        #expect(albums.isEmpty)
    }

    @Test func testFetchAlbums_SortedByCount() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let albums = try await library.albums(sortedBy: \MPMediaItemCollection.count, order: .forward)
        #expect(albums.isEmpty)
    }

    @Test func testFetchAlbums_SortedByCountReverse() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let albums = try await library.albums(sortedBy: \MPMediaItemCollection.count, order: .reverse)
        #expect(albums.isEmpty)
    }

    @Test func testFetchAlbums_Unsorted() async throws {
        let library = MusicLibrary.withMocks
        #expect(library.authorizationStatus == .authorized)
        let albums = try await library.albums()
        #expect(albums.isEmpty)
    }

    // Failures

    @Test func testSongs_Unauthorized() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.songs()
        }
    }

    @Test func testSongs_AuthFail() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.songs()
        }
    }

    @Test func testSongs_StatusDenied() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)
        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.songs()
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
            let _ = try await library.songs()
        }
    }

    @Test func testFetchSong_Failure() async throws {
        let service = MockMusicLibraryService(fetchSongError: .noSong)
        let library = MusicLibrary(mockService: service)
        #expect(library.authorizationStatus == .authorized)

        await #expect(throws: MockMusicLibraryService.MockError.noSong) {
            let _ = try await library.songs(matching: .mock)
        }
    }

    @Test func testFetchAlbums_FailingService() async throws {
        let service = MockMusicLibraryService(fetchAlbumsError: .noAlbums)
        let library = MusicLibrary(mockService: service)
        #expect(library.authorizationStatus == .authorized)

        await #expect(throws: MockMusicLibraryService.MockError.noAlbums) {
            let _ = try await library.albums(sortedBy: (KeyPath<MPMediaItemCollection, Never> & Sendable)?.none, order: .forward)
        }
    }

    @Test func testFetchAlbums_MatchingPredicate_Failure() async throws {
        let service = MockMusicLibraryService(albumsError: .noAlbum)
        let library = MusicLibrary(mockService: service)
        #expect(library.authorizationStatus == .authorized)

        await #expect(throws: MockMusicLibraryService.MockError.noAlbum) {
            let _ = try await library.albums(
                matching: .albumArtist("Test Artist"),
                .equalTo,
                groupingType: .album
            )
        }
    }

    @Test func testAlbums_Unauthorized() async throws {
        let library = MusicLibrary(
            mockAuth: .mock(isAuthorized: false, authError: .mockError, authStatus: .denied)
        )
        #expect(library.authorizationStatus == .denied)

        await #expect(throws: MockAuthorizationManager.MockAuthError.mockError) {
            let _ = try await library.albums(sortedBy: (KeyPath<MPMediaItemCollection, Never> & Sendable)?.none, order: .forward)
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
