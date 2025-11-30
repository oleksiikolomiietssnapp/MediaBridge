import MediaBridge
import MediaPlayer

final class MockMusicLibraryService: MusicLibraryServiceProtocol {
    enum MockError: Error {
        case noSong, noSongs
    }

    init(
        fetchSongError: MockError? = nil,
        fetchSongsError: MockError? = nil,
        song: MPMediaItem = .mock
    ) {
        self.fetchSongError = fetchSongError
        self.fetchSongsError = fetchSongsError
        self.song = song
    }

    @MainActor
    var fetchSongsError: MockError?
    func fetchSongs() async throws(MockError) -> [MPMediaItem] {
        guard let fetchSongsError = await fetchSongsError else {
            return []
        }
        throw fetchSongsError
    }

    @MainActor
    var song: MPMediaItem
    @MainActor
    var fetchSongError: MockError?
    @MainActor
    var noSongError: MockError?
    func song(using predicate: MediaBridge.MediaItemPredicateInfo) async throws(MockError) -> MPMediaItem {
        guard let fetchSongError = await fetchSongError else {
            return await song
        }
        throw fetchSongError
    }

}

extension MusicLibraryServiceProtocol where Self == MockMusicLibraryService, E == MockMusicLibraryService.MockError {
    static var mock: MockMusicLibraryService {
        MockMusicLibraryService()
    }
}

extension MPMediaItem: @unchecked @retroactive Sendable { }
extension MPMediaItem {
    static var mock: MPMediaItem {
        MPMediaItem()
    }
}
