import Testing

@testable import MediaBridge

@Suite("MusicLibraryService")
struct MusicLibraryServiceTest {
    @Test func testFetchAll_NoItems() async throws {
        let service: any MusicLibraryServiceProtocol = MusicLibraryService<MockMediaQueryWithNoItems>()
        let songs = try await service.fetchAll(.music, groupingType: .album)

        #expect(songs.count == 0)
    }

    @Test func testFetchAll_TwoItems() async throws {
        let service: any MusicLibraryServiceProtocol = MusicLibraryService<MockMediaQueryWithTwoItems>()
        let songs = try await service.fetchAll(.music, groupingType: .album)

        #expect(songs.count == 2)
    }

    @Test func testFetch_NoItems() async throws {
        let service: any MusicLibraryServiceProtocol = MusicLibraryService<MockMediaQueryWithNoItems>()

        let songs = try await service.fetch(
            .music,
            with: .title("Title"),
            comparisonType: .equalTo,
            groupingType: .album
        )

        #expect(songs.count == 0)
    }

    @Test func testFetch_TwoItems() async throws {
        let service: any MusicLibraryServiceProtocol = MusicLibraryService<MockMediaQueryWithTwoItems>()

        let songs = try await service.fetch(
            .music,
            with: .title("Title"),
            comparisonType: .equalTo,
            groupingType: .album
        )

        #expect(songs.count == 2)
    }

    // Failing

    @Test func testFetch_NilItems() async throws {
        let service: any MusicLibraryServiceProtocol = MusicLibraryService<MockMediaQueryWithNilItems>()

        let predicateInfo = MediaItemPredicateInfo.title("Title")
        let expectedError = MusicLibraryService<MockMediaQueryWithNilItems>.E.noSongFound(predicateInfo)

        await #expect(throws: expectedError) {
            let _ = try await service.fetch(
                .music,
                with: predicateInfo,
                comparisonType: .equalTo,
                groupingType: .album
            )
        }
    }
    @Test func testFetchAll_NilItems() async throws {
        let service: any MusicLibraryServiceProtocol = MusicLibraryService<MockMediaQueryWithNilItems>()

        let expectedError = MusicLibraryService<MockMediaQueryWithNilItems>.E.noSongsFound

        await #expect(throws: expectedError) {
            let _ = try await service.fetchAll(.music, groupingType: .album)
        }
    }
}
