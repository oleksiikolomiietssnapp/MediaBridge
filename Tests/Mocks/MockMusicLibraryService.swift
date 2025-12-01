import MediaBridge
import MediaPlayer

final class MockMusicLibraryService: MusicLibraryServiceProtocol {
    enum MockError: Error {
        case noSong, noSongs
    }

    init(
        fetchSongError: MockError? = nil,
        fetchSongsError: MockError? = nil,
        songs: [MPMediaItem] = [.mock]
    ) {
        self.fetchSongError = fetchSongError
        self.fetchSongsError = fetchSongsError
        self.songs = songs
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

}

extension MusicLibraryServiceProtocol where Self == MockMusicLibraryService, E == MockMusicLibraryService.MockError {
    static var mock: MockMusicLibraryService {
        MockMusicLibraryService()
    }
}

extension MPMediaItem: @unchecked @retroactive Sendable {}
extension MPMediaItem {
    static var mock: MPMediaItem {
        MPMediaItem()
    }
}
