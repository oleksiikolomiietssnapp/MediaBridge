import MediaBridge
import MediaPlayer

final class MockMusicLibraryService: MusicLibraryServiceProtocol {
    typealias E = MockError
    typealias Q = MPMediaQuery

    enum MockError: Error {
        case noSong, noSongs, noAlbum, noAlbums
    }

    init(
        fetchSongError: MockError? = nil,
        fetchSongsError: MockError? = nil,
        songs: [MPMediaItem] = [.mock],
        albums: [MPMediaItemCollection] = [.mock],
        albumsError: MockError? = nil,
        fetchAlbumsError: MockError? = nil
    ) {
        self.fetchSongError = fetchSongError
        self.fetchSongsError = fetchSongsError
        self.songs = songs
        self.albums = albums
        self.albumsError = albumsError
        self.fetchAlbumsError = fetchAlbumsError
    }

    @MainActor var fetchSongsError: MockError?
    func fetchAll(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws(MockError) -> [MPMediaItem] {
        guard let fetchSongsError = await fetchSongsError else {
            return []
        }
        throw fetchSongsError
    }

    @MainActor var songs: [MPMediaItem]
    @MainActor var fetchSongError: MockError?
    @MainActor var noSongError: MockError?
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws(MockError) -> [MPMediaItem] {
        guard let fetchSongError = await fetchSongError else {
            return await songs
        }
        throw fetchSongError
    }

    @MainActor var albums: [MPMediaItemCollection]
    @MainActor var albumsError: MockError?
    func fetchCollections(
        _ type: MPMediaType,
        with predicate: MediaBridge.MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItemCollection] {
        guard let albumsError = await albumsError else {
            return await albums
        }
        throw albumsError
    }

    @MainActor var fetchAlbumsError: MockError?
    func fetchAllCollections(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws -> [MPMediaItemCollection] {
        guard let fetchAlbumsError = await fetchAlbumsError else {
            return []
        }
        throw fetchAlbumsError
    }


}

extension MusicLibraryServiceProtocol where Self == MockMusicLibraryService {
    static var mock: MockMusicLibraryService {
        MockMusicLibraryService(albums: [])
    }
}

extension MPMediaItem: @unchecked @retroactive Sendable {}
extension MPMediaItem {
    static var mock: MPMediaItem {
        MPMediaItem()
    }
}
extension MPMediaItemCollection: @unchecked @retroactive Sendable {}
extension MPMediaItemCollection {
    static var mock: MPMediaItemCollection {
        MPMediaItemCollection(items: [])
    }
}
